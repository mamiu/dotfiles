#!/bin/bash

exit_status=$EX_SUCCESS

TALK=true
SKIP=false
FORCE=false
BATCH=false
VERBOSE=false


# Define some colors
txtdef="\e[0m"    # Revert to default
bldred="\e[1;31m" # Red - error
bldgrn="\e[1;32m" # Green - success
bldylw="\e[1;33m" # Yellow - warning
bldblu="\e[1;34m" # Blue - no action/ignored
bldcyn="\e[1;36m" # Cyan - pending action
bldwht="\e[1;37m" # White - info

function err {
	local exit_status=$1
	local reason="$2"
	shift 2
	if [[ $pending_status ]]; then
		fail
	fi
	status "$bldred" "error" "$reason" >&2
	for line in "$@"; do
		printf "$line\n" >&2
	done
	exit $exit_status
}

function status {
	if $TALK; then
		printf "$1%13s$txtdef %s\n" "$2" "$3"
	fi
}

function warn {
	status "$bldylw" "$1" "$2"
}

function info {
	status "$bldwht" "$1" "$2"
}

pending_status=''
pending_message=''
function pending {
	pending_status="$1"
	pending_message="$2"
	if $TALK; then
		printf "$bldcyn%13s$txtdef %s" "$pending_status" "$pending_message"
	fi
}

function fail {
	[[ $1 ]] && pending_status=$1
	[[ $2 ]] && pending_message=$2
	status "\r$bldred" "$pending_status" "$pending_message"
	unset pending_status pending_message
}

function ignore {
	[[ $1 ]] && pending_status=$1
	[[ $2 ]] && pending_message=$2
	status "\r$bldblu" "$pending_status" "$pending_message"
	unset pending_status pending_message
}

function success {
	[[ $1 ]] && pending_status=$1
	[[ $2 ]] && pending_message=$2
	status "\r$bldgrn" "$pending_status" "$pending_message"
	unset pending_status pending_message
}


# Singleline prompt that stays on the same line even if you press enter.
# Automatically colors the line according to the answer the user gives.
# Currently homeshick only has prompts with "no" as the default,
# so there's no reason to implement prompt_yes right now
function prompt_no {
	local OTALK=$TALK
	# Disable the quiet flag while prompting in interactive mode
	if ! $BATCH; then
		TALK=true
	fi

	local status=$1
	local message=$2
	local prompt=$3
	local result=-1

	status "$bldwht" "$status" "$message"
	if ! $BATCH; then
		pending "$prompt" "[yN] "
		while true; do
			local answer=""
			local char=""
			while true; do
				read -s -n 1 char
				if [[ $char == "" ]]; then
					break
				fi
				printf "%c" $char
				answer="${answer}${char}"
			done
			case $answer in
				Y|y) result=0 ;;
				N|n) result=1 ;;
				"")  result=2 ;;
			esac
			[[ $result -ge 0 ]] && break
			for (( i=0; i<${#answer}; i++ )) ; do
				printf "\b"
			done
			printf "%${#answer}s\r"
			pending "$pending_status" "$pending_message"
		done
	else
		pending "$prompt" "BATCH - No"
		result=2
	fi
	if [[ $result == 0 ]]; then
		success
	else
		fail
	fi
	TALK=$OTALK
	return $result
}


################################ THE SYMLINK PART ######################################

SCRIPT=$(readlink -f $0)
REPO=$(dirname $SCRIPT)
SEARCHPATH=$REPO"/home/"
CASTLE=${REPO##*/}

function symlink {
	local castle=$CASTLE
	local repo="$REPO"
	if [[ ! -d $repo/home ]]; then
		ignore 'ignored' "$castle"
		return $EX_SUCCESS
	fi
	# Run through the repo files using process substitution.
	# The get_repo_files call is at the bottom of this loop.
	# We set the IFS to nothing and the separator for `read' to NUL so that we
	# don't separate files with newlines in their name into two iterations.
	# `read's stdin comes from a third unused file descriptor because we are
	# using the real stdin for prompting the user whether he wants to overwrite or skip
	# on conflicts.
	while IFS= read -d $'\0' -r filename <&3 ; do
		remote="$repo/home/$filename"
		local="$HOME/$filename"

		if [[ -e $local || -L $local ]]; then
			# $local exists (but may be a dead symlink)
			if [[ -L $local && $(readlink "$local") == "$remote" ]]; then
				# $local symlinks to $remote.
				if [[ -d $remote && ! -L $remote ]]; then
					# If $remote is a directory -> legacy handling.
					rm "$local"
				else
					# $local points at $remote and $remote is not a directory
					if $VERBOSE; then
						ignore 'identical' "$filename"
					fi
					continue
				fi
			else
				# $local does not symlink to $remote
				if [[ -d $local && -d $remote && ! -L $remote ]]; then
					# $remote is a real directory while
					# $local is a directory or a symlinked directory
					# we do not take any action regardless of which it is.
					if $VERBOSE; then
						ignore 'identical' "$filename"
					fi
					continue
				fi
                prompt_no 'conflict' "$filename exists" "overwrite?" || continue
				# Delete $local. If $remote is a real directory,
				# $local must be a file (because of all the previous checks)
				rm -rf "$local"
			fi
		fi

		if [[ ! -d $remote || -L $remote ]]; then
			# $remote is not a real directory so we create a symlink to it
			pending 'symlink' "$filename"
			ln -s "$remote" "$local"
		else
			pending 'directory' "$filename"
			mkdir "$local"
		fi

		success
	# Fetch the repo files and redirect the output into file descriptor 3
	done 3< <(get_repo_files "$repo")
	return $EX_SUCCESS
}

# Fetches all files and folders in a repository that are tracked by git
# Works recursively on submodules as well
function get_repo_files {
	# Resolve symbolic links
	# e.g. on osx $TMPDIR is in /var/folders...
	# which is actually /private/var/folders...
	# We do this so that the root part of $toplevel can be replaced
	# git resolves symbolic links before it outputs $toplevel
	local root=$(cd "$1"; pwd -P)
	(
		local path
		while IFS= read -d $'\n' -r path; do
			# Remove quotes from ls-files
			# (used when there are newlines in the path)
			path=${path/#\"/}
			path=${path/%\"/}
			# Check if home/ is a submodule
			[[ $path == 'home' ]] && continue
			# Remove the home/ part
			path=${path/#home\//}
			# Print the file path (NUL separated because \n can be used in filenames)
			printf "$path\0"
			# Get the path of all the parent directories
			# up to the repo root.
			while true; do
				path=$(dirname "$path")
				# If path is '.' we`re done
				[[ $path == '.' ]] && break
				# Print the path
				printf "$path\0"
			done
		# Enter the repo, list the repo root files in home
		# and do the same for any submodules
		done < <(cd "$root" &&
		         git ls-files 'home/' &&
		         git submodule --quiet foreach --recursive \
		         "$homeshick/lib/submodule_files.sh \"$root\" \"\$toplevel\" \"\$path\"")
		# Unfortunately we have to use an external script for `git submodule foreach`
		# because versions prior to ~ 2.0 use `eval` to execute the argument.
		# This somehow messes quite badly with string substitution.
	) | sort -zu # sort the results and make the list unique (-u), NUL is the line separator (-z)
}

symlink

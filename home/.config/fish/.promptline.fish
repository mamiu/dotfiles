# to use this script you need the latest fish version (2.1.x)
begin
    ########## USER CONFIG ########## 
    # enable or disable the different parts of promptline with yes or no
    set show_only_left_prompt           no
    set show_hostname                   no
    set show_virtual_env                yes
    set show_username                   yes
    set show_current_working_directory  yes
    set show_git_branch                 yes
    set show_git_status                 yes
    set show_battery_level              yes
    set show_return_value               yes

    # choose one of the following themes:
    # airline, airline_insert, airline_visual, jelly, promptline,
    # lightline, lightline_insert, lightline_visual
    set promptline_theme "airline"

    set cwd_dir_limit 3
    set cwd_truncation_symbol "⋯"
     
    set battery_threshold 15
    set battery_symbol ""
    set battery_percent_sign "%"

    set return_value_symbol "↯ "

    set vcs_branch_symbol " "
    # set git_added_symbol "❋ "
    set git_added_symbol "*"
    # set git_unmerged_symbol "⧉ "
    set git_unmerged_symbol "x"
    # set git_modified_symbol "✎ "
    set git_modified_symbol "+"
    set git_clean_symbol "✔"
    set git_has_untracked_files_symbol "…"
    set git_ahead_symbol "⇡ "
    set git_behind_symbol "⇣ "

    set sep ""
    set rsep ""
    set alt_sep ""
    set alt_rsep ""
    ########## END USER CONFIG ########## 
    
    set space " "
    set esc "\e["
    set end_esc "m"
    set reset "$esc""0""$end_esc"
    set reset_bg "$esc""49""$end_esc"

    if test $promptline_theme = "airline"
        set a_fg "$esc""38;5;236""$end_esc"; and set a_bg "$esc""48;5;150""$end_esc"; and set a_sep_fg "$esc""38;5;150""$end_esc"; and set b_fg "$esc""38;5;249""$end_esc"; and set b_bg "$esc""48;5;237""$end_esc"; and set b_sep_fg "$esc""38;5;237""$end_esc"; and set c_fg "$esc""38;5;150""$end_esc"; and set c_bg "$esc""48;5;238""$end_esc"; and set c_sep_fg "$esc""38;5;238""$end_esc"; and set warn_fg "$esc""38;5;232""$end_esc"; and set warn_bg "$esc""48;5;166""$end_esc"; and set warn_sep_fg "$esc""38;5;166""$end_esc"; and set y_fg "$esc""38;5;249""$end_esc"; and set y_bg "$esc""48;5;237""$end_esc"; and set y_sep_fg "$esc""38;5;237""$end_esc"
    else if test $promptline_theme = "airline_insert"
        set a_fg "$esc""38;5;238""$end_esc"; and set a_bg "$esc""48;5;110""$end_esc"; and set a_sep_fg "$esc""38;5;110""$end_esc"; and set b_fg "$esc""38;5;249""$end_esc"; and set b_bg "$esc""48;5;237""$end_esc"; and set b_sep_fg "$esc""38;5;237""$end_esc"; and set c_fg "$esc""38;5;110""$end_esc"; and set c_bg "$esc""48;5;238""$end_esc"; and set c_sep_fg "$esc""38;5;238""$end_esc"; and set warn_fg "$esc""38;5;232""$end_esc"; and set warn_bg "$esc""48;5;166""$end_esc"; and set warn_sep_fg "$esc""38;5;166""$end_esc"; and set y_fg "$esc""38;5;249""$end_esc"; and set y_bg "$esc""48;5;237""$end_esc"; and set y_sep_fg "$esc""38;5;237""$end_esc"
    else if test $promptline_theme = "airline_visual"
        set a_fg "$esc""38;5;236""$end_esc"; and set a_bg "$esc""48;5;182""$end_esc"; and set a_sep_fg "$esc""38;5;182""$end_esc"; and set b_fg "$esc""38;5;249""$end_esc"; and set b_bg "$esc""48;5;237""$end_esc"; and set b_sep_fg "$esc""38;5;237""$end_esc"; and set c_fg "$esc""38;5;182""$end_esc"; and set c_bg "$esc""48;5;238""$end_esc"; and set c_sep_fg "$esc""38;5;238""$end_esc"; and set warn_fg "$esc""38;5;232""$end_esc"; and set warn_bg "$esc""48;5;166""$end_esc"; and set warn_sep_fg "$esc""38;5;166""$end_esc"; and set y_fg "$esc""38;5;249""$end_esc"; and set y_bg "$esc""48;5;237""$end_esc"; and set y_sep_fg "$esc""38;5;237""$end_esc"
    else if test $promptline_theme = "jelly"
        set a_fg "$esc""38;5;233""$end_esc"; and set a_bg "$esc""48;5;183""$end_esc"; and set a_sep_fg "$esc""38;5;183""$end_esc"; and set b_fg "$esc""38;5;231""$end_esc"; and set b_bg "$esc""48;5;240""$end_esc"; and set b_sep_fg "$esc""38;5;240""$end_esc"; and set c_fg "$esc""38;5;188""$end_esc"; and set c_bg "$esc""48;5;234""$end_esc"; and set c_sep_fg "$esc""38;5;234""$end_esc"; and set warn_fg "$esc""38;5;232""$end_esc"; and set warn_bg "$esc""48;5;166""$end_esc"; and set warn_sep_fg "$esc""38;5;166""$end_esc"; and set y_fg "$esc""38;5;231""$end_esc"; and set y_bg "$esc""48;5;240""$end_esc"; and set y_sep_fg "$esc""38;5;240""$end_esc"
    else if test $promptline_theme = "lightline"
        set a_fg "$esc""38;5;238""$end_esc"; and set a_bg "$esc""48;5;117""$end_esc"; and set a_sep_fg "$esc""38;5;117""$end_esc"; and set b_fg "$esc""38;5;252""$end_esc"; and set b_bg "$esc""48;5;240""$end_esc"; and set b_sep_fg "$esc""38;5;240""$end_esc"; and set c_fg "$esc""38;5;248""$end_esc"; and set c_bg "$esc""48;5;238""$end_esc"; and set c_sep_fg "$esc""38;5;238""$end_esc"; and set warn_fg "$esc""38;5;236""$end_esc"; and set warn_bg "$esc""48;5;180""$end_esc"; and set warn_sep_fg "$esc""38;5;180""$end_esc"; and set y_fg "$esc""38;5;247""$end_esc"; and set y_bg "$esc""48;5;240""$end_esc"; and set y_sep_fg "$esc""38;5;240""$end_esc"
    else if test $promptline_theme = "lightline_insert"
        set a_fg "$esc""38;5;238""$end_esc"; and set a_bg "$esc""48;5;119""$end_esc"; and set a_sep_fg "$esc""38;5;119""$end_esc"; and set b_fg "$esc""38;5;252""$end_esc"; and set b_bg "$esc""48;5;240""$end_esc"; and set b_sep_fg "$esc""38;5;240""$end_esc"; and set c_fg "$esc""38;5;248""$end_esc"; and set c_bg "$esc""48;5;238""$end_esc"; and set c_sep_fg "$esc""38;5;238""$end_esc"; and set warn_fg "$esc""38;5;236""$end_esc"; and set warn_bg "$esc""48;5;180""$end_esc"; and set warn_sep_fg "$esc""38;5;180""$end_esc"; and set y_fg "$esc""38;5;247""$end_esc"; and set y_bg "$esc""48;5;240""$end_esc"; and set y_sep_fg "$esc""38;5;240""$end_esc"
    else if test $promptline_theme = "lightline_visual"
        set a_fg "$esc""38;5;238""$end_esc"; and set a_bg "$esc""48;5;216""$end_esc"; and set a_sep_fg "$esc""38;5;216""$end_esc"; and set b_fg "$esc""38;5;252""$end_esc"; and set b_bg "$esc""48;5;240""$end_esc"; and set b_sep_fg "$esc""38;5;240""$end_esc"; and set c_fg "$esc""38;5;248""$end_esc"; and set c_bg "$esc""48;5;238""$end_esc"; and set c_sep_fg "$esc""38;5;238""$end_esc"; and set warn_fg "$esc""38;5;236""$end_esc"; and set warn_bg "$esc""48;5;180""$end_esc"; and set warn_sep_fg "$esc""38;5;180""$end_esc"; and set y_fg "$esc""38;5;247""$end_esc"; and set y_bg "$esc""48;5;240""$end_esc"; and set y_sep_fg "$esc""38;5;240""$end_esc"
    else if test $promptline_theme = "powerline"
        set a_fg "$esc""38;5;220""$end_esc"; and set a_bg "$esc""48;5;166""$end_esc"; and set a_sep_fg "$esc""38;5;166""$end_esc"; and set b_fg "$esc""38;5;231""$end_esc"; and set b_bg "$esc""48;5;31""$end_esc"; and set b_sep_fg "$esc""38;5;31""$end_esc"; and set c_fg "$esc""38;5;250""$end_esc"; and set c_bg "$esc""48;5;240""$end_esc"; and set c_sep_fg "$esc""38;5;240""$end_esc"; and set warn_fg "$esc""38;5;231""$end_esc"; and set warn_bg "$esc""48;5;52""$end_esc"; and set warn_sep_fg "$esc""38;5;52""$end_esc"; and set y_fg "$esc""38;5;250""$end_esc"; and set y_bg "$esc""48;5;236""$end_esc"; and set y_sep_fg "$esc""38;5;236""$end_esc"
    end
     
    function fish_prompt -S -d "fish specific function for the prompt on the left side"
        __promptline_left_prompt
    end
 
    function fish_right_prompt -S -d "fish specific function for the prompt on the right side"
        __promptline_right_prompt
        eval "fish $BATTERY_FILE &" 2>&1 >/dev/null
    end
end

function __promptline_cwd -S -d "create current-working-directory string"
    set -l first_char
    set -l formatted_cwd ""
    set -l dir_sep "  "
    set -l tilde "~"
 
    set -l cwd (echo $PWD | sed 's#^'$HOME'#~#')
    # get the first char of the path, i.e. tilde or slash
    # and trim off the tilde if present
    begin
        set -l IFS ''
        set -l rest
        # use `read` with an empty IFS to split the first character
        echo $cwd | read first_char rest
        if test $first_char = '~'
            set cwd $rest
        end
    end
 
    # split the path into components, reverse it, and trim it.
    set -l comps
    set -l IFS '/'
    echo $cwd | read -a comps
 
    # reverse the array
    set comps $comps[-1..1]
    if test (count $comps) -gt $cwd_dir_limit
        # and trim it down to size
        set comps $comps[1..$cwd_dir_limit]
        set first_char $cwd_truncation_symbol
    end
 
    # iterate components array and build the result
    if test (count $comps) -ge 1
        if test (count $comps) -gt 1
            for part in $comps[1..-2]
                set formatted_cwd "$dir_sep$part$formatted_cwd"
            end
        end

        if test "$first_char" != "/"
            set formatted_cwd "$dir_sep$comps[-1..-1]$formatted_cwd"
        else
            set formatted_cwd "$comps[-1..-1]$formatted_cwd"
        end
    end

    echo -n "$first_char$formatted_cwd"
end
 
function __promptline_vcs_branch -S -d "get branch of the current version control system"
    set -l branch
 
    # git
    if begin; test -d .git; or git rev-parse --git-dir >/dev/null 2>&1; end
        set branch (echo (git symbolic-ref --quiet HEAD 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null))
        if test -n "$branch"
            set branch (echo $branch | awk -F'/' '{print $NF}')
            echo -ne (echo $vcs_branch_symbol$branch (test $show_git_status = "yes"; and __promptline_git_status))
            return 0
        end
    end
    return 1
end
 
function __promptline_git_status -d "get status of current git branch"
    if begin; test -d .git; or git rev-parse --git-dir >/dev/null 2>&1; end
        test (git rev-parse --is-inside-work-tree 2>/dev/null) = "true"; or return 1
     
        set -l unmerged_count 0
        set -l modified_count 0
        set -l has_untracked_files 0
        set -l added_count 0
        set -l is_clean ""
     
        set -l behind_count (git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null | awk '{print $1}')
        set -l ahead_count (git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null | awk '{print $2}')
     
        # Added (A), Copied (C), Deleted (D), Modified (M), Renamed (R), changed (T), Unmerged (U), Unknown (X), Broken (B)
        git diff --name-status | while read line
            switch "$line"
                case 'M*'
                    set modified_count (math $modified_count + 1)
                case 'U*'
                    set unmerged_count (math $unmerged_count + 1)
            end
        end
     
        git diff --name-status --cached | while read line
            switch "$line"
                case '*'
                    set added_count (math $added_count + 1)
            end
        end
     
        test -z (git ls-files --others --exclude-standard | head -1); or set has_untracked_files 1
     
        test (math $unmerged_count + $modified_count + $has_untracked_files + $added_count) -eq 0 2>/dev/null; and set is_clean 1
     
        set -l leading_whitespace ""
        test $ahead_count -gt 0 2>/dev/null;         and echo -ne "$leading_whitespace$ahead_count$git_ahead_symbol"; and set leading_whitespace " ";
        test $behind_count -gt 0 2>/dev/null;        and echo -ne "$leading_whitespace$behind_count$git_behind_symbol"; and set leading_whitespace " ";
        test $modified_count -gt 0 2>/dev/null;      and echo -ne "$leading_whitespace$modified_count$git_modified_symbol"; and set leading_whitespace " ";
        test $unmerged_count -gt 0 2>/dev/null;      and echo -ne "$leading_whitespace$unmerged_count$git_unmerged_symbol"; and set leading_whitespace " ";
        test $added_count -gt 0 2>/dev/null;         and echo -ne "$leading_whitespace$added_count$git_added_symbol"; and set leading_whitespace " ";
        test $has_untracked_files -gt 0 2>/dev/null; and echo -ne "$leading_whitespace$git_has_untracked_files_symbol"; and set leading_whitespace " ";
        test $is_clean -gt 0 2>/dev/null;            and echo -ne "$leading_whitespace$git_clean_symbol"; and set leading_whitespace " ";
    else
        return 1
    end
end
 
function __promptline_wrapper -d "reorder content between the wrapper at argument 2 and 3"
    # wrap the text in $1 with $2 and $3, only if $1 is not empty
    # $2 and $3 typically contain non-content-text, like color escape codes and separators
 
    test (count $argv) -lt 3; and return 1
    echo -ne $argv[2]$argv[1]$argv[3]
end
 
function __promptline_left_prompt -S -d "draw the left part of promptline"
    set -l return_value $status
 
    # section "a" header
    set -l is_prompt_empty 1
    set -l slice_prefix "$a_bg$sep$a_fg$a_bg$space"
    set -l slice_suffix "$space$a_sep_fg"
    set -l slice_joiner "$a_fg$a_bg$alt_sep$space"
    set -l slice_empty_prefix "$a_fg$a_bg$space"
    test $is_prompt_empty -eq 1; and set slice_prefix "$slice_empty_prefix"
    # section "a" slices
    test $show_hostname = "yes"; and __promptline_wrapper $HOSTNAME "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"; and set is_prompt_empty 0
    if begin; test $show_virtual_env = "yes"; and test -n "$VIRTUAL_ENV"; end
        __promptline_wrapper (echo "$VIRTUAL_ENV" | sed 's#.*\/##g') "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"; and set is_prompt_empty 0
    end
 
    # section "b" header
    if test $show_username = "yes"
        set -l curr_user (whoami)
        if test "$curr_user" = "root"
            set danger_bg "\e[48;5;88m"
            set danger_sep_fg "\e[38;5;88m"
            set slice_prefix "$danger_bg$sep$b_fg$danger_bg$space"
            set slice_suffix "$space$danger_sep_fg"
            set slice_empty_prefix "$b_fg$danger_bg$space"
        else
            set slice_prefix "$b_bg$sep$b_fg$b_bg$space"
            set slice_suffix "$space$b_sep_fg"
            set slice_empty_prefix "$b_fg$b_bg$space"
        end
        set slice_joiner "$b_fg$b_bg$alt_sep$space"
        test $is_prompt_empty -eq 1; and set slice_prefix "$slice_empty_prefix"
        # section "b" slices
        __promptline_wrapper "$curr_user" "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"; and set is_prompt_empty 0
    end
 
    # section "c" header
    set slice_prefix "$c_bg$sep$c_fg$c_bg$space"
    set slice_suffix "$space$c_sep_fg"
    set slice_joiner "$c_fg$c_bg$alt_sep$space"
    set slice_empty_prefix "$c_fg$c_bg$space"
    test $is_prompt_empty -eq 1; and set slice_prefix "$slice_empty_prefix"
    # section "c" slices
    test $show_current_working_directory = "yes"; and __promptline_wrapper (__promptline_cwd) "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"; and set is_prompt_empty 0
 
    if test $show_only_left_prompt = "yes"
        # section "y" header
        set slice_prefix "$y_bg$sep$y_fg$y_bg$space"
        set slice_suffix "$space$y_sep_fg"
        set slice_joiner "$y_fg$y_bg$alt_sep$space"
        set slice_empty_prefix "$y_fg$y_bg$space"
        test $is_prompt_empty -eq 1; and set slice_prefix "$slice_empty_prefix"
        # section "y" slices
        if test $show_git_branch = "yes"
            __promptline_wrapper (__promptline_vcs_branch) "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"; and set is_prompt_empty 0
        else if test $show_git_status = "yes"
            __promptline_wrapper (__promptline_git_status) "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"; and set is_prompt_empty 0
        end
     
        # section "warn" header
        set slice_prefix "$warn_bg$sep$warn_fg$warn_bg$space"
        set slice_suffix "$space$warn_sep_fg"
        set slice_joiner "$warn_fg$warn_bg$alt_sep$space"
        set slice_empty_prefix "$warn_fg$warn_bg$space"
        test $is_prompt_empty -eq 1; and set slice_prefix "$slice_empty_prefix"
        # section "warn" slices
        if begin; test $show_battery_level = "yes"; and test -n "$LAST_BATTERY_LEVEL"; and test "$LAST_BATTERY_LEVEL" -le "$battery_threshold"; end
            __promptline_wrapper "$battery_symbol$LAST_BATTERY_LEVEL$battery_percent_sign" "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"; and set is_prompt_empty 0
        end
        if begin; test $show_return_value = "yes"; and test $return_value -ne 0; end
            __promptline_wrapper "$return_value_symbol$return_value" "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"; and set is_prompt_empty 0
        end
    end
 
    # close sections
    echo -ne "$reset_bg$sep$reset$space"
end
 
function __promptline_right_prompt -S -d "draw the right part of promptline"
    set -l return_value $status
    test $show_only_left_prompt = "yes"; and return
 
    # section "warn" header
    set -l slice_prefix "$warn_sep_fg$rsep$warn_fg$warn_bg"
    set -l slice_suffix "$space$warn_sep_fg"
    set -l slice_joiner "$warn_fg$warn_bg$alt_rsep$space"
    # section "warn" slices
    if begin; test $show_return_value = "yes"; and test $return_value -ne 0; end
        __promptline_wrapper "$return_value_symbol$return_value" "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"
    end
    if begin; test $show_battery_level = "yes"; and test -n "$LAST_BATTERY_LEVEL"; and test "$LAST_BATTERY_LEVEL" -le "$battery_threshold"; end
        __promptline_wrapper "$battery_symbol$LAST_BATTERY_LEVEL$battery_percent_sign" "$slice_prefix" "$slice_suffix"
    end
 
    # section "y" header
    set slice_prefix "$y_sep_fg$rsep$y_fg$y_bg$space"
    set slice_suffix "$space$y_sep_fg"
    set slice_joiner "$y_fg$y_bg$alt_rsep$space"
    # section "y" slices
    if test $show_git_branch = "yes"
        __promptline_wrapper (__promptline_vcs_branch) "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"
    else if test $show_git_status = "yes"
        __promptline_wrapper (__promptline_git_status) "$slice_prefix" "$slice_suffix"; and set slice_prefix "$slice_joiner"
    end
 
    # close sections
    echo -ne "$reset"
end

# save the battery file in the same directory
set -g BATTERY_FILE (dirname (status -f))"/.battery.fish"
set -g VIRTUAL_ENV_DISABLE_PROMPT 1
set -g HOSTNAME (hostname)
 
# create a seperate file for calculating the battery level and start the script
# in the background to improve the performance of this prompt. On OS X this
# solution seems to be a advantage, because the battery level refreshes
# automatically without hitting enter to get the current percentage. But on
# Linux the current battery level is always printed one step later.
if not test -f "$BATTERY_FILE"
    printf "\n# osx\n" > "$BATTERY_FILE"
    printf "if test (uname) = \"Darwin\"\n" >> "$BATTERY_FILE"
    printf "    set current_capacity (ioreg -rc AppleSmartBattery 2>/dev/null | grep CurrentCapacity | awk -F' ' '{print \$NF}')\n" >> "$BATTERY_FILE"
    printf "    set battery_capacity (ioreg -rc AppleSmartBattery 2>/dev/null | grep MaxCapacity | awk -F' ' '{print \$NF}')\n" >> "$BATTERY_FILE"
    printf "    set -U LAST_BATTERY_LEVEL (math \$current_capacity \* 100 \/ \$battery_capacity)\n" >> "$BATTERY_FILE"
    printf "end\n\n" >> "$BATTERY_FILE"
    printf "# linux\n" >> "$BATTERY_FILE"
    printf "for possible_battery_dir in /sys/class/power_supply/BAT*\n" >> "$BATTERY_FILE"
    printf "    if begin; test -d \"\$possible_battery_dir\"; and test -f \"\$possible_battery_dir/charge_full\"; and test -f \"\$possible_battery_dir/charge_now\"; end\n" >> "$BATTERY_FILE"
    printf "        set current_capacity (cat \"\$possible_battery_dir/charge_now\")\n" >> "$BATTERY_FILE"
    printf "        set battery_capacity (cat \"\$possible_battery_dir/charge_full\")\n" >> "$BATTERY_FILE"
    printf "        set -U LAST_BATTERY_LEVEL (math \$current_capacity \* 100 \/ \$battery_capacity)\n" >> "$BATTERY_FILE"
    printf "    end\n" >> "$BATTERY_FILE"
    printf "end\n" >> "$BATTERY_FILE"
end

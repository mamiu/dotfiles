function __print_current_namespace
    set_color $fish_color_autosuggestion
    echo "Current namespace: $KUBE_CURRENT_NS" >&2
    set_color normal
end

function kubectl-namespaced
    if not type -q fzf
        echo "fzf must be installed in order to use kubectl-namespaced"
        return 1
    end

    if test -z "$KUBE_CURRENT_NS"
        set -g KUBE_CURRENT_NS (kubectl get ns -o name | sed -e "s/^[^/]*\///g" | fzf)
        if test $status -gt 0
            return
        end
    end

    if test "$argv[1]" = "logs" -o "$argv[1]" = "exec"
        set -g KUBE_SELECTED_POD (kubectl -n "$KUBE_CURRENT_NS" get pods -o name | sed -e "s/^[^/]*\///g" | fzf)

        if test -z "$KUBE_SELECTED_POD"
            echo "Couldn't find any pod for namespace \"$KUBE_CURRENT_NS\""
            return
        end

        if test "$argv[1]" = "exec"
            commandline -b "kubectl -n \"$KUBE_CURRENT_NS\" $argv \"$KUBE_SELECTED_POD\" -- bash"
        else
            __print_current_namespace
            kubectl -n "$KUBE_CURRENT_NS" $argv "$KUBE_SELECTED_POD" | bat -l log --style numbers
        end
        return
    end

    __print_current_namespace
    if count $argv > /dev/null
        kubectl -n "$KUBE_CURRENT_NS" $argv
    end
end

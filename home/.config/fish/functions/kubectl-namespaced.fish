function __print_current_namespace
    set_color $fish_color_autosuggestion
    echo "Current namespace: $KUBE_CURRENT_NS" >&2
    set_color normal
end

function __select_a_pod
    set -g KUBE_SELECTED_POD (kubectl -n "$KUBE_CURRENT_NS" get pods -o name | sed -e "s/^[^/]*\///g" | fzf)

    if test -z "$KUBE_SELECTED_POD"
        echo "Couldn't find any pod for namespace \"$KUBE_CURRENT_NS\""
        return
    end
end

function kubectl-namespaced
    if not type -q fzf
        echo "fzf must be installed in order to use kubectl-namespaced"
        return 1
    end

    # You can set a namespace by passing the argument sn (set namespace) to this function
    if test -z "$KUBE_CURRENT_NS" -o "$argv[1]" = "sn"
        set -g KUBE_CURRENT_NS (kubectl get ns -o name | sed -e "s/^[^/]*\///g" | fzf)
        if test $status -gt 0
            return
        end
    end
    __print_current_namespace

    if test "$argv[1]" = "debug"
        kubectl run --namespace="$KUBE_CURRENT_NS" --image=humiu/debug --rm -it debug
        return
    end

    if test "$argv[1]" = "exec"
        __select_a_pod
        commandline -b "kubectl -n \"$KUBE_CURRENT_NS\" $argv \"$KUBE_SELECTED_POD\" -- bash"
        return
    end

    if test "$argv[1]" = "logs"
        __select_a_pod
        if type -q $__BAT_CMD
            set logs_pager "$__BAT_CMD -l log --style numbers"
        else
            set logs_pager "less"
        end
        fish -c "kubectl -n \"$KUBE_CURRENT_NS\" $argv \"$KUBE_SELECTED_POD\" | $logs_pager"
        return
    end

    if count $argv > /dev/null; and test "$argv[1]" != "sn"
        kubectl -n "$KUBE_CURRENT_NS" $argv
    end
end

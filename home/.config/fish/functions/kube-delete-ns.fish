
function __hide_cursor
    # hide cursor
    echo -en "\e[?25l"
end

function __show_cursor
    # show cursor
    echo -en "\e[?25h"
end

function __loading_spinner
    while kill -0 $argv[1]
        # __hide_cursor
        for char in "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"
            # move cursor to the beginning of the line before printing character
            echo -en "\e[3000D $char $argv[2..-1] "
            sleep 0.06
        end
        # __show_cursor
    end
end

function kube-delete-ns
    kubectl proxy &>/dev/null &
    jobs -lp | read KUBE_PROXY_PID
    for ns in $argv
        echo -en " Checking namespace "(set_color -o)"\033[1;34m$ns\033[1;0m"(set_color normal)
        kubectl get ns $ns &>/dev/null
        # kubectl get ns $ns &>/dev/null &
        # jobs -lp | read KUBE_CHECK_NS_PID
        # __loading_spinner $KUBE_CHECK_NS_PID "Checking namespace \033[1;34m$ns\033[1;0m"
        # wait $KUBE_CHECK_NS_PID
        if test $status -gt 0
            echo -ne "\033[2K\033[10000D"
            set_color --italics ff3
            echo -n " i"
            set_color normal
            echo -e " Namespace \033[1;34m$ns\033[1;0m already deleted"
            continue
        end
        echo -en "\033[2K\033[10000D Deleting namespace "(set_color -o)"\033[1;34m$ns\033[1;0m"(set_color normal)" ..."
        kubectl get namespace $ns -o json | jq '.spec = {"finalizers":[]}' >kube-del-ns-temp.json
        curl -ks \
            -o /dev/null \
            -H "Content-Type: application/json" \
            -X PUT \
            --data-binary @kube-del-ns-temp.json \
            http://127.0.0.1:8001/api/v1/namespaces/$ns/finalize 2>&1
        # following line is doing cursor movements (https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x361.html, http://ascii-table.com/ansi-escape-sequences.php, https://en.wikipedia.org/wiki/ANSI_escape_code#Terminal_output_sequences)
        echo -e "\033[2K\033[10000D \033[0;32m✔\033[0m Deleted \033[1;34m$ns\033[1;0m"
    end
    if test -e kube-del-ns-temp.json
        rm kube-del-ns-temp.json &>/dev/null
    end
    kill -TERM $KUBE_PROXY_PID
end

# function do_task
#     function test_func
#         sleep 1
#         emit test_event # you could also `background "sleep 10; signal sleep_done"` above and await here
#     end
#     function on_premature_exit --on-event test_event
#         # functions -e on_premature_exit # erase to prevent recursively calling itself when it exits
#         echo "Cancelled waiting"
#     end
#     echo start
#     sleep 1
#     echo before test_func
#     # not working:
#     # test_func &
#     # working:
#     sleep 1 &
#     # reason see here:
#     # https://github.com/fish-shell/fish-shell/issues/238
#     # https://github.com/fish-shell/fish-shell/issues/563
#     echo after test_func
#     sleep 1
#     echo done
# end

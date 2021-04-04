
# ABBREVIATIONS
if status --is-interactive
    if test -n "$__BAT_CMD"
        abbr --add --global b $__BAT_CMD
    end
    abbr --add --global e echo
    abbr --add --global en 'echo -n'
    abbr --add --global m mosh
    abbr --add --global v vim
    abbr --add --global s sudo
    abbr --add --global c curl
    abbr --add --global g git
    abbr --add --global gc 'git clone'
    abbr --add --global gco 'git commit -am'
    abbr --add --global gp 'git push'
    abbr --add --global gpu 'git push -u origin master'
    abbr --add --global gr 'git remote -v'
    abbr --add --global gs 'git status'
    abbr --add --global gd 'git diff'
    abbr --add --global w 'watch -n 1'
    abbr --add --global n 'netstat -tlpn'
    abbr --add --global k 'kubectl'
    abbr --add --global ka 'kubectl apply -f'
    abbr --add --global kg 'kubectl get'
    abbr --add --global kga 'kubectl get all -A'
    abbr --add --global kn 'kubectl -n'
    abbr --add --global ks 'kubectl -n kube-system'
    abbr --add --global ksa 'kubectl -n kube-system get all'
    abbr --add --global ksp 'kubectl -n kube-system get pods'
    abbr --add --global ksn 'kubectl -n kube-system get pod -o name'
    abbr --add --global ksna 'kubectl -n kube-system get all -o name'
    abbr --add --global ksl 'kubectl -n kube-system logs'
    abbr --add --global kvs 'set -g KUBE_CURRENT_NS (kubectl get ns -o name | sed -e "s/^[^/]*\///g" | fzf)'
    abbr --add --global kv "kubectl-namespaced"
    abbr --add --global kva "kubectl-namespaced get all"
    abbr --add --global kvp "kubectl-namespaced get pods"
    abbr --add --global kvn "kubectl-namespaced get pod -o name"
    abbr --add --global kvna "kubectl-namespaced get all -o name"
    abbr --add --global kvl "kubectl-namespaced logs"
    abbr --add --global kve "kubectl-namespaced exec -it"
end

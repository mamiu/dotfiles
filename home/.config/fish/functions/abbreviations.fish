
function abbreviations
  if status --is-interactive
      if type -q bat
          abbr --add --global b bat
      end
      abbr --add --global e echo
      abbr --add --global en 'echo -n'
      abbr --add --global ee 'echo -e'
      abbr --add --global m mosh
      abbr --add --global v vim
      abbr --add --global s sudo
      abbr --add --global c curl
      abbr --add --global g git
      abbr --add --global gc 'git clone'
      abbr --add --global gco 'git commit -am'
      abbr --add --global gp 'git push'
      abbr --add --global gpf 'git push -f'
      abbr --add --global gpu 'git push -u origin master'
      abbr --add --global gr 'git remote -v'
      abbr --add --global gs 'git status'
      abbr --add --global gd 'git diff'
      abbr --add --global w 'watch -n 1'
      abbr --add --global n 'netstat -tlpn'
      abbr --add --global d 'docker'
      abbr --add --global dp 'docker ps'
      abbr --add --global dpa 'docker ps -a'
      abbr --add --global dpull 'docker pull'
      abbr --add --global dpush 'docker push'
      abbr --add --global dr 'docker run --rm -it'
      abbr --add --global dst 'docker start'
      abbr --add --global dsp 'docker stop'
      abbr --add --global db 'docker build'
      abbr --add --global di 'docker images'
      abbr --add --global de 'docker exec'
      abbr --add --global da 'docker attach'
      abbr --add --global dl 'docker logs'
      abbr --add --global dlf 'docker logs -f'
      abbr --add --global drm 'docker rm'
      abbr --add --global drmi 'docker rmi'
      abbr --add --global dc 'docker compose'
      abbr --add --global dcu 'docker compose up'
      abbr --add --global dcud 'docker compose up -d'
      abbr --add --global dcd 'docker compose down'
      abbr --add --global dcdv 'docker compose down -v'
      abbr --add --global dcp 'docker compose ps'
      abbr --add --global dcpa 'docker compose ps -a'
      abbr --add --global dcst 'docker compose start'
      abbr --add --global dcsp 'docker compose stop'
      abbr --add --global dcr 'docker compose restart'
      abbr --add --global dca 'docker compose attach'
      abbr --add --global dcrm 'docker compose rm'
      abbr --add --global dcl 'docker compose logs'
      abbr --add --global dclf 'docker compose logs -f'
      abbr --add --global k 'kubectl'
      abbr --add --global ka 'kubectl apply -f'
      abbr --add --global kg 'kubectl get'
      abbr --add --global kga 'kubectl get all -A'
      abbr --add --global ks 'kubectl -n kube-system'
      abbr --add --global ksa 'kubectl -n kube-system get all'
      abbr --add --global ksp 'kubectl -n kube-system get pods'
      abbr --add --global ksl 'kubectl -n kube-system logs'
      abbr --add --global kn "kubectl-namespaced"
      abbr --add --global kna "kubectl-namespaced get all"
      abbr --add --global knp "kubectl-namespaced get pods"
      abbr --add --global knan "kubectl-namespaced get all -o name"
      abbr --add --global knpn "kubectl-namespaced get pods -o name"
      abbr --add --global knl "kubectl-namespaced logs"
      abbr --add --global kne "kubectl-namespaced exec -it"
      abbr --add --global kdn "kube-delete-ns"
  end
end
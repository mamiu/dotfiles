
function abbreviations
  if status --is-interactive
      abbr --add --global en 'echo -n'
      abbr --add --global ee 'echo -e'
      abbr --add --global w 'watch -n 1'
      abbr --add --global n 'netstat -tlpn'
      abbr --add --global gc 'git clone'
      abbr --add --global ga 'git add -A'
      abbr --add --global gco 'git commit -m'
      abbr --add --global gca 'git commit -am'
      abbr --add --global gp 'git push'
      abbr --add --global gpf 'git push -f'
      abbr --add --global gpu 'git push -u origin main'
      abbr --add --global gpl 'git pull'
      abbr --add --global gf 'git fetch'
      abbr --add --global gfo 'git fetch origin'
      abbr --add --global gr 'git remote -v'
      abbr --add --global grao 'git remote add origin'
      abbr --add --global grro 'git remote remove origin'
      abbr --add --global gs 'git status'
      abbr --add --global gl 'git log'
      abbr --add --global gd 'git diff'
      abbr --add --global y 'yarn'
      abbr --add --global yi 'yarn init'
      abbr --add --global yr 'yarn run'
      abbr --add --global yd 'yarn dev'
      abbr --add --global ya 'yarn add -D'
      abbr --add --global yga 'yarn global add'
      abbr --add --global ygu 'yarn global upgrade'
      abbr --add --global yb 'yarn build'
      abbr --add --global yp 'yarn preview'
      abbr --add --global yf 'yarn format'
      abbr --add --global yl 'yarn lint'
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
      abbr --add --global drm 'docker container rm'
      abbr --add --global dirm 'docker image rm'
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
      abbr --add --global dce 'docker compose exec'
      abbr --add --global dcl 'docker compose logs'
      abbr --add --global dclf 'docker compose logs -f'
      abbr --add --global dcrm 'docker compose rm'
      abbr --add --global k 'kubectl'
      abbr --add --global kc 'kubectl create -n'
      abbr --add --global kcn 'kubectl create namespace'
      abbr --add --global kcd 'kubectl create deploy -n'
      abbr --add --global kd 'kubectl delete -n'
      abbr --add --global kdn 'kubectl delete namespace'
      abbr --add --global kdd 'kubectl delete deploy -n'
      abbr --add --global ka 'kubectl apply -f'
      abbr --add --global kg 'kubectl get -n'
      abbr --add --global kga 'kubectl get all -A'
      abbr --add --global ks 'kubectl -n kube-system'
      abbr --add --global ksa 'kubectl -n kube-system get all'
      abbr --add --global ksp 'kubectl -n kube-system get pods'
      abbr --add --global ksl 'kubectl -n kube-system logs'
      abbr --add --global kcg 'kubectl config get-contexts'
      abbr --add --global kcc 'kubectl config current-context'
      abbr --add --global kcu 'kubectl config use-context'
      abbr --add --global kx "kubectx"
      abbr --add --global kn "kubens"
      abbr --add --global kh "kubectl-helper"
      abbr --add --global khs "kubectl-helper sn"
      abbr --add --global kha "kubectl-helper get all"
      abbr --add --global khp "kubectl-helper get pods"
      abbr --add --global khan "kubectl-helper get all -o name"
      abbr --add --global khpn "kubectl-helper get pods -o name"
      abbr --add --global khl "kubectl-helper logs -f"
      abbr --add --global khe "kubectl-helper exec -it"
      abbr --add --global kher "kubectl-helper k3s-exec-as-root"
      abbr --add --global khv "kubectl-helper vim"
      abbr --add --global khd "kubectl-helper debug"
      abbr --add --global kdnf "kube-delete-ns"
      abbr --add --global hga "helm get all"
      abbr --add --global hgh "helm get hooks"
      abbr --add --global hgm "helm get manifest"
      abbr --add --global hgn "helm get notes"
      abbr --add --global hgv "helm get values"
      abbr --add --global hh "helm history --namespace"
      abbr --add --global hi "helm install --namespace"
      abbr --add --global hl "helm list --namespace"
      abbr --add --global hp "helm pull"
      abbr --add --global hra "helm repo add"
      abbr --add --global hrl "helm repo list"
      abbr --add --global hrr "helm repo remove"
      abbr --add --global hru "helm repo update"
      abbr --add --global hrb "helm rollback"
      abbr --add --global hseh "helm search hub"
      abbr --add --global hser "helm search repo"
      abbr --add --global hsha "helm show all"
      abbr --add --global hshc "helm show chart"
      abbr --add --global hshr "helm show readme"
      abbr --add --global hshv "helm show values"
      abbr --add --global hs "helm status"
      abbr --add --global ht "helm template"
      abbr --add --global hu "helm uninstall"
      abbr --add --global hug "helm upgrade"
  end
end

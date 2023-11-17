# Домашнее задание к занятию «Управление доступом»

### Цель заданияВ тестовой среде Kubernetes нужно предоставить ограниченный доступ пользователю.

------

### Чеклист готовности к домашнему заданию
1. Установлено k8s-решение, например MicroK8S.    
2. Установленный локальный kubectl.    
3. Редактор YAML-файлов с подключённым github-репозиторием.    

------

### Инструменты / дополнительные материалы, которые пригодятся для выполнения задания
1. [Описание](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) RBAC.    
2. [Пользователи и авторизация RBAC в Kubernetes](https://habr.com/ru/company/flant/blog/470503/).    
3. [RBAC with Kubernetes in Minikube](https://medium.com/@HoussemDellai/rbac-with-kubernetes-in-minikube-4deed658ea7b).    

------

### Задание 1. Создайте конфигурацию для подключения пользователя
1. Создайте и подпишите SSL-сертификат для подключения к кластеру.     
2. Настройте конфигурационный файл kubectl для подключения.     
3. Создайте роли и все необходимые настройки для пользователя.     
4. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).    
5. Предоставьте манифесты и скриншоты и/или вывод необходимых команд.     

------

### Ответы:

```
ubuntu@server-kube:~$ openssl genrsa -out netology.key 2048
ubuntu@server-kube:~$ openssl req -new -key netology.key -out netology.csr -subj "/CN=netology/O=netology"
ubuntu@server-kube:~$ openssl x509 -req -in netology.csr -CA /var/snap/microk8s/6089/certs/ca.crt -CAkey /var/snap/microk8s/6089/certs/ca.key -CAcreateserial -out netology.crt -days 365
Certificate request self-signature ok
subject=CN = netology, O = netology
ubuntu@server-kube:~$ micro config set-credentials netology --client-certificate=netology.crt --client-key=netology.key --embed-certs=true
User "netology" set.
ubuntu@server-kube:~$ micro config set-context netology --cluster=microk8s-cluster --user=netology
Context "netology" created.
ubuntu@server-kube:~$ micro config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://127.0.0.1:16443
  name: microk8s-cluster
contexts:
- context:
    cluster: microk8s-cluster
    user: admin
  name: microk8s
- context:
    cluster: microk8s-cluster
    user: netology
  name: netology
current-context: microk8s
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
- name: netology
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
ubuntu@server-kube:~$ micro config get-contexts
CURRENT   NAME       CLUSTER            AUTHINFO   NAMESPACE
*         microk8s   microk8s-cluster   admin
          netology   microk8s-cluster   netology
ubuntu@server-kube:~$ micro get nodes
NAME          STATUS   ROLES    AGE   VERSION
server-kube   Ready    <none>   60m   v1.28.3
ubuntu@server-kube:~$ micro config use-context netology
Switched to context "netology".
ubuntu@server-kube:~$ micro config get-contexts
CURRENT   NAME       CLUSTER            AUTHINFO   NAMESPACE
          microk8s   microk8s-cluster   admin
*         netology   microk8s-cluster   netology
ubuntu@server-kube:~$ micro get nodes
NAME          STATUS   ROLES    AGE   VERSION
server-kube   Ready    <none>   60m   v1.28.3
ubuntu@server-kube:~$ micro config use-context microk8s
Switched to context "microk8s".
ubuntu@server-kube:~$ microk8s enable rbac
Infer repository core for addon rbac
Enabling RBAC
Reconfiguring apiserver
Restarting apiserver
RBAC is enabled
ubuntu@server-kube:~$ micro config use-context netology
Switched to context "netology".
ubuntu@server-kube:~$ micro get nodes
Error from server (Forbidden): nodes is forbidden: User "netology" cannot list resource "nodes" in API group "" at the cluster scope
ubuntu@server-kube:~$ micro config use-context microk8s
Switched to context "microk8s".
ubuntu@server-kube:~$ micro get nodes
NAME          STATUS   ROLES    AGE   VERSION
server-kube   Ready    <none>   84m   v1.28.3
ubuntu@server-kube:~$ micro apply -f deploy.yaml
deployment.apps/nginx-deploy created
ubuntu@server-kube:~$ micro apply -f role.yaml
role.rbac.authorization.k8s.io/netology created
ubuntu@server-kube:~$ micro apply -f rolebind.yaml
rolebinding.rbac.authorization.k8s.io/netology-pods created
ubuntu@server-kube:~$ micro config use-context netology
Switched to context "netology".
ubuntu@server-kube:~$ micro get nodes
Error from server (Forbidden): nodes is forbidden: User "netology" cannot list resource "nodes" in API group "" at the cluster scope
ubuntu@server-kube:~$ micro get po
NAME                            READY   STATUS    RESTARTS   AGE
nginx-deploy-7c79c4bf97-5wr87   1/1     Running   0          29s
ubuntu@server-kube:~$ micro delete po nginx-deploy-7c79c4bf97-5wr87
Error from server (Forbidden): pods "nginx-deploy-7c79c4bf97-5wr87" is forbidden: User "netology" cannot delete resource "pods" in API group "" in the namespace "default"
ubuntu@server-kube:~$ micro logs nginx-deploy-7c79c4bf97-5wr87
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2023/11/17 08:56:19 [notice] 1#1: using the "epoll" event method
2023/11/17 08:56:19 [notice] 1#1: nginx/1.25.3
2023/11/17 08:56:19 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2023/11/17 08:56:19 [notice] 1#1: OS: Linux 5.15.0-88-generic
2023/11/17 08:56:19 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 65536:65536
2023/11/17 08:56:19 [notice] 1#1: start worker processes
2023/11/17 08:56:19 [notice] 1#1: start worker process 29
2023/11/17 08:56:19 [notice] 1#1: start worker process 30
ubuntu@server-kube:~$ micro describe po nginx-deploy-7c79c4bf97-5wr87
Name:             nginx-deploy-7c79c4bf97-5wr87
Namespace:        default
Priority:         0
Service Account:  default
Node:             server-kube/10.0.3.5
Start Time:       Fri, 17 Nov 2023 08:56:04 +0000
Labels:           app=nginx
                  pod-template-hash=7c79c4bf97
Annotations:      cni.projectcalico.org/containerID: 5289d3ee6aa3c3115f28fb46cca6e038686b0d4d77ad5634c164122a53377db1
                  cni.projectcalico.org/podIP: 10.1.55.195/32
                  cni.projectcalico.org/podIPs: 10.1.55.195/32
Status:           Running
IP:               10.1.55.195
IPs:
  IP:           10.1.55.195
Controlled By:  ReplicaSet/nginx-deploy-7c79c4bf97
Containers:
  nginx:
    Container ID:   containerd://0c272703aaf660a7e62bbd474907ff888e3461045af16f10ee97a29ce7e87f0a
    Image:          nginx:latest
    Image ID:       docker.io/library/nginx@sha256:86e53c4c16a6a276b204b0fd3a8143d86547c967dc8258b3d47c3a21bb68d3c6
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Fri, 17 Nov 2023 08:56:19 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vrst2 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-vrst2:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
ubuntu@server-kube:~$ micro get deploy
Error from server (Forbidden): deployments.apps is forbidden: User "netology" cannot list resource "deployments" in API group "apps" in the namespace "default"
ubuntu@server-kube:~$ micro config view --minify | grep -i '\- name'
- name: netology

```
Не стал разделять выводы команд по пунктам, в принципе и так все видно. Пользователю netology даны права на просмотр подов и их логов, на другие команды, такие как describe, get nodes, delete и остальные прав нет.    

Также в вывод добавил microk8s enable rbac, т.к. без этого аддона ограничение прав не работает, пользователю netology были доступны все команды.    

------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.    
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, скриншоты результатов.     
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.    

------
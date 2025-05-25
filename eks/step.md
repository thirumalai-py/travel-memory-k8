# Create EKS Cluster - Without Ingress

1) Crete a cluster
`eksctl create cluster --name thiru-demo-2-node-micro-nginx --region ap-south-1 --nodegroup-name node-workers --node-type t3.medium --nodes 2 --nodes-min 2 --nodes-max 2`

2) Get Config
`kubectl config get-contexts`

3) Update Config
`aws eks --region ap-south-1 update-kubeconfig --name node-micro-nginx`

# Deploy the Codes

4) kubectl apply -f namespace.yaml
5) kubectl apply -f db-deployment.yaml
6) in other terminal check database running with: kubectl get pods -n database, kubectl get svc -n database
7) # Run nslookup from a temporary pod
(it creates pod to test database)
kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh 
8) nslookup mongodb-service.database.svc.cluster.local

9) kubectl apply -f secret.yaml - to get the DB secret for the backend deployment
9) kubectl apply -f travelmemory-backend-deployment.yaml
10) kubectl logs namespace -n backend (for debugging)
11) kubectl apply -f travelmemory-backend-service.yaml
12) kubectl get svc
13) Check the Loadbalancer URL and see if the service is running in browser and paste the url on the travelmemory-backend-deployment.yaml as `REACT_APP_BACKEND_URL`

14) kubectl apply -f travelmemory-backend-deployment.yaml
15) kubectl logs namespace -n backend (for debugging)
16) kubectl apply -f travelmemory-backend-service.yaml
17) kubectl get svc
18) Check the Loadbalancer URL and see if the service is running in browser


- Get all pods - kubectl get pods -A
- Get All services - kubectl get svc -A











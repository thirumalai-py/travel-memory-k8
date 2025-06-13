# Useful Minikube commands

- Enable Minikube metrics-server
`minikube addons enable metrics-server`

- List of Addon list
`minikube addon list`

- Get the top pods
`kubectl top pods -A`

- Get the hpa of the namespace
`kubectl get hpa -n default`

kubectl top nodes

- get the list of name spaces

## Namespace
kubectl get ns
kubectl get create ns <name>

# Test the HPA

kubectl get hpa product-catalog-hpa-demo -w

kubectl describe hpa product-catalog-hpa-demo -n default

kubectl delete hpa product-catalog-hpa-demo

kubectl get pods -l app=product-catalog -w

kubectl get service product-catalog-service -o jsonpath='{.spec.clusterIP}'

kubectl get pods

kubectl exec -it <po-name-from-above> -- bash

while true; do curl -s -o /dev/null -w "%{http_code}" http://<SERVICE_IP_OBTAINED_ABOVE>;done

while true; do curl -s -o /dev/null -w "%{http_code}" http://10.111.185.253;done









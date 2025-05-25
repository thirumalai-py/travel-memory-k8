kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh

nslookup mongodb-service.database.svc.cluster.local


# Set up port forwarding

kubectl port-forward -n backend pod/$(kubectl get pods -n backend -l app=travelmemory-backend -o jsonpath="{.items[0].metadata.name}") 3001:3001


kubectl port-forward -n frontend pod/$FRONTEND_POD 3000:3000

FRONTEND_POD=$(kubectl get pods -n frontend -l app=travelmemory-frontend -o jsonpath="{.items[0].metadata.name}")






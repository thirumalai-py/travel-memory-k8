# Set up port forwarding
kubectl port-forward -n backend pod/$(kubectl get pods -n backend -l app=travelmemory-backend -o jsonpath="{.items[0].metadata.name}") 3001:3001
# Get the frontend pod name
$FRONTEND_POD=$(kubectl get pods -n frontend -l app=travelmemory-frontend -o jsonpath="{.items[0].metadata.name}")

# Port forward directly from the pod
kubectl port-forward -n frontend pod/$FRONTEND_POD 3000:3000
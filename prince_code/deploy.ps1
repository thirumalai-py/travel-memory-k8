# deployment.ps1
# PowerShell script for deploying Kubernetes resources

# Apply namespaces first
Write-Host "Applying namespaces..." -ForegroundColor Green
kubectl apply -f namespace.yml
#kubectl apply -f backend-namespace.yml

# Database tier
Write-Host "Deploying database components..." -ForegroundColor Green
kubectl apply -f db-pv.yml
kubectl apply -f db-pvc.yml
kubectl apply -f db-deployment.yml
kubectl apply -f mongodb-service.yml

# Backend tier
#Write-Host "Deploying backend components..." -ForegroundColor Green
#kubectl apply -f secret.yml
#kubectl apply -f backend-deployment.yml
#kubectl apply -f backend-service.yml
#kubectl apply -f backend-ingress.yml

# Verify deployments
Write-Host "Waiting for deployments to be ready..." -ForegroundColor Yellow
Write-Host "Checking MongoDB deployment status..."
kubectl wait --for=condition=available --timeout=300s deployment/mongodb-deployment -n database

#Write-Host "Checking Backend deployment status..."
#kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n backend

# Check pod status
Write-Host "`nChecking pod status:" -ForegroundColor Cyan
Write-Host "Database Pods:"
kubectl get pods -n database

#Write-Host "`nBackend Pods:"
#kubectl get pods -n backend

# Check services
Write-Host "`nChecking services:" -ForegroundColor Cyan
Write-Host "Database Services:"
kubectl get svc -n database

#Write-Host "`nBackend Services:"
#kubectl get svc -n backend

#Write-Host "`nChecking ingress:" -ForegroundColor Cyan
#kubectl get ingress -n backend

#Write-Host "`nDeployment complete!" -ForegroundColor Green
#Write-Host "Your application should be accessible through the ingress endpoint."

# Optional: You can add a simple verification test
#Write-Host "`nWould you like to test the backend connection? (y/n)" -ForegroundColor Yellow
#$response = Read-Host

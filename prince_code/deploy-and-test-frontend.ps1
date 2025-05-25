# deploy-and-test-frontend.ps1 - Script for deploying and testing the TravelMemory frontend

Write-Host "Deploying and Testing TravelMemory Frontend" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

# Step 1: Apply all the frontend resources
Write-Host "`nStep 1: Applying frontend resources..." -ForegroundColor Green

Write-Host "Creating Nginx configuration..." -ForegroundColor Yellow
kubectl apply -f frontend-nginx-conf.yaml

Write-Host "Creating environment configuration..." -ForegroundColor Yellow
kubectl apply -f frontend-env.yaml

Write-Host "Creating frontend deployment..." -ForegroundColor Yellow
kubectl apply -f travelmemory-frontend-deployment.yaml

Write-Host "Creating frontend service..." -ForegroundColor Yellow
kubectl apply -f travelmemory-frontend-service.yaml

# Step 2: Wait for the deployment to be ready
Write-Host "`nStep 2: Waiting for deployment to be ready..." -ForegroundColor Green
kubectl rollout status deployment/travelmemory-frontend -n frontend

# Step 3: Check if the builder has completed
Write-Host "`nStep 3: Checking frontend builder logs..." -ForegroundColor Green
$frontendPod = $(kubectl get pods -n frontend -l app=travelmemory-frontend -o jsonpath="{.items[0].metadata.name}")

if ($frontendPod) {
    Write-Host "Frontend pod found: $frontendPod" -ForegroundColor Yellow
    
    Write-Host "`nInitContainer logs:" -ForegroundColor Yellow
    kubectl logs -n frontend $frontendPod -c frontend-builder
    
    # Check if the init container completed successfully
    $initContainerStatus = $(kubectl get pod $frontendPod -n frontend -o jsonpath="{.status.initContainerStatuses[0].state.terminated.reason}")
    
    if ($initContainerStatus -eq "Completed") {
        Write-Host "`nInit container completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "`nInit container may not have completed. Status: $initContainerStatus" -ForegroundColor Red
    }
} else {
    Write-Host "No frontend pod found." -ForegroundColor Red
}

# Step 4: Set up port forwarding
Write-Host "`nStep 4: Setting up port forwarding to test the frontend..." -ForegroundColor Green
Write-Host "Opening a new terminal window with port forwarding. Access at http://localhost:3000" -ForegroundColor Yellow

# Start port forwarding in a new window
Start-Process powershell -ArgumentList "-Command", "kubectl port-forward -n frontend svc/travelmemory-frontend-service 3000:80; Read-Host 'Press Enter to close'"

# Step 5: Open browser after a short delay
Write-Host "`nStep 5: Opening browser to test frontend..." -ForegroundColor Green
Start-Sleep -Seconds 5
Start-Process "http://localhost:3000"

# Step 6: Provide testing instructions
Write-Host "`nFrontend should now be accessible at http://localhost:3000" -ForegroundColor Cyan
Write-Host "If the frontend doesn't load properly, check:" -ForegroundColor Yellow
Write-Host "1. Backend connectivity: kubectl logs -n frontend $frontendPod -c frontend-server" -ForegroundColor Yellow
Write-Host "2. Environment configuration: kubectl describe configmap frontend-env -n frontend" -ForegroundColor Yellow
Write-Host "3. Nginx configuration: kubectl describe configmap frontend-nginx-conf -n frontend" -ForegroundColor Yellow

Write-Host "`nTo manually port-forward in case the window was closed:" -ForegroundColor Green
Write-Host "kubectl port-forward -n frontend svc/travelmemory-frontend-service 3000:80" -ForegroundColor Green

Write-Host "`nDeployment and testing complete!" -ForegroundColor Cyan
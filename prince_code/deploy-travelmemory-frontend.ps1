# deploy-travelmemory-frontend.ps1 - PowerShell script to deploy TravelMemory frontend

Write-Host "Deploying TravelMemory Frontend" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

# Step 1: Create a namespace for the frontend
Write-Host "`nStep 1: Creating frontend namespace..." -ForegroundColor Green
$namespaceYaml = @"
apiVersion: v1
kind: Namespace
metadata:
  name: frontend
"@
$namespaceYaml | Out-File -FilePath "frontend-namespace.yml" -Encoding utf8
kubectl apply -f frontend-namespace.yml

# Step 2: Create a deployment that runs the frontend application
Write-Host "`nStep 2: Creating frontend deployment..." -ForegroundColor Green

# Get backend service host
$backendIngressHost = kubectl get ingress -n backend -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}" 2>$null
if ([string]::IsNullOrEmpty($backendIngressHost)) {
    $backendIngressHost = kubectl get ingress -n backend -o jsonpath="{.items[0].status.loadBalancer.ingress[0].hostname}" 2>$null
}

if ([string]::IsNullOrEmpty($backendIngressHost)) {
    Write-Host "Could not find backend ingress address. Using placeholder..." -ForegroundColor Yellow
    $backendIngressHost = "travelmemory-backend-ingress"
} else {
    Write-Host "Found backend ingress address: $backendIngressHost" -ForegroundColor Green
}

# Create the deployment YAML
$deploymentYaml = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: travelmemory-frontend
  namespace: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: travelmemory-frontend
  template:
    metadata:
      labels:
        app: travelmemory-frontend
    spec:
      containers:
      - name: travelmemory-frontend
        image: node:14
        workingDir: /app
        command: ["/bin/bash", "-c"]
        args:
        - |
          echo "Cloning TravelMemory repository..."
          git clone https://github.com/XXRadeonXFX/TravelMemory.git /tmp/repo
          
          echo "Copying frontend code..."
          cp -r /tmp/repo/frontend/* /app/
          
          echo "Installing dependencies..."
          npm install
          
          # Add API_URL environment variable to .env file
          echo "REACT_APP_API_URL=http://$backendIngressHost/api" > .env
          echo "Using backend URL: http://$backendIngressHost/api"
          
          echo "Starting frontend application..."
          npm start
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
"@

$deploymentYaml | Out-File -FilePath "travelmemory-frontend-deployment.yml" -Encoding utf8
kubectl apply -f travelmemory-frontend-deployment.yml

# Step 3: Create a service for the frontend
Write-Host "`nStep 3: Creating frontend service..." -ForegroundColor Green
$serviceYaml = @"
apiVersion: v1
kind: Service
metadata:
  name: travelmemory-frontend-service
  namespace: frontend
spec:
  selector:
    app: travelmemory-frontend
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
"@
$serviceYaml | Out-File -FilePath "travelmemory-frontend-service.yml" -Encoding utf8
kubectl apply -f travelmemory-frontend-service.yml

# Step 4: Create an ingress for external access
Write-Host "`nStep 4: Creating frontend ingress..." -ForegroundColor Green
$ingressYaml = @"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: travelmemory-frontend-ingress
  namespace: frontend
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: travelmemory-frontend-service
            port:
              number: 80
"@
$ingressYaml | Out-File -FilePath "travelmemory-frontend-ingress.yml" -Encoding utf8
kubectl apply -f travelmemory-frontend-ingress.yml

# Step 5: Wait for the deployment to be ready
Write-Host "`nStep 5: Waiting for deployment to be ready..." -ForegroundColor Green
kubectl rollout status deployment/travelmemory-frontend -n frontend

# Step 6: Display access information
Write-Host "`nStep 6: Deployment complete! Here's how to access your application:" -ForegroundColor Green

# Check if the ingress has an address
$frontendIngressHost = kubectl get ingress -n frontend -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}" 2>$null
if ([string]::IsNullOrEmpty($frontendIngressHost)) {
    $frontendIngressHost = kubectl get ingress -n frontend -o jsonpath="{.items[0].status.loadBalancer.ingress[0].hostname}" 2>$null
}

if (-not [string]::IsNullOrEmpty($frontendIngressHost)) {
    Write-Host "`nAccess your TravelMemory application at:" -ForegroundColor Cyan
    Write-Host "http://$frontendIngressHost" -ForegroundColor Green
} else {
    Write-Host "`nIngress address not yet available. You can port-forward to access the frontend:" -ForegroundColor Yellow
    Write-Host "kubectl port-forward -n frontend svc/travelmemory-frontend-service 3000:80" -ForegroundColor Green
    Write-Host "Then access at: http://localhost:3000" -ForegroundColor Green
}

# Provide information about pods
Write-Host "`nFrontend pod status:" -ForegroundColor Cyan
kubectl get pods -n frontend

# Instructions for checking logs
Write-Host "`nTo check the frontend logs:" -ForegroundColor Cyan
$frontendPod = kubectl get pods -n frontend -l app=travelmemory-frontend -o jsonpath="{.items[0].metadata.name}" 2>$null
if ($frontendPod) {
    Write-Host "kubectl logs -f $frontendPod -n frontend" -ForegroundColor Green
}

Write-Host "`nDeployment complete!" -ForegroundColor Cyan
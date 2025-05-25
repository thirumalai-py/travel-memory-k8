# deploy-travelmemory-backend.ps1 - PowerShell script to deploy TravelMemory backend

Write-Host "Deploying TravelMemory Backend from GitHub" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Step 1: Fix the MongoDB URI in the Secret
Write-Host "`nStep 1: Fixing MongoDB URI in Secret..." -ForegroundColor Green

$correctMongoUri = "mongodb://mongodb-service.database.svc.cluster.local:27017/TravelMemory"
$encodedMongoUri = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($correctMongoUri))

Write-Host "Complete MongoDB URI: $correctMongoUri" -ForegroundColor Yellow
Write-Host "Encoded URI: $encodedMongoUri" -ForegroundColor Yellow

# Create the fixed Secret YAML
$secretYaml = @"
apiVersion: v1
kind: Secret
metadata:
  name: backend-secret
  namespace: backend
type: Opaque
data:
  # Data needs to be converted to base64
  # MONGO_URI: mongodb://mongodb-service.database.svc.cluster.local:27017/TravelMemory    
  MONGO_URI: $encodedMongoUri
  
  # PORT: 3001
  PORT: MzAwMQ==
"@

$secretYaml | Out-File -FilePath "backend-secret.yml" -Encoding utf8

# Create backend namespace if it doesn't exist
$backendNamespaceExists = kubectl get namespace backend 2>$null
if (-not $backendNamespaceExists) {
    Write-Host "`nCreating backend namespace..." -ForegroundColor Yellow
    kubectl create namespace backend
} else {
    Write-Host "`nBackend namespace already exists." -ForegroundColor Green
}

# Apply the fixed Secret
Write-Host "`nApplying fixed Secret..." -ForegroundColor Green
kubectl apply -f backend-secret.yml

# Step 2: Create Deployment YAML
Write-Host "`nStep 2: Creating Deployment YAML..." -ForegroundColor Green

$deploymentYaml = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: travelmemory-backend
  namespace: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: travelmemory-backend
  template:
    metadata:
      labels:
        app: travelmemory-backend
    spec:
      containers:
      - name: travelmemory-backend
        image: node:14
        workingDir: /app
        command: ["/bin/bash", "-c"]
        args:
        - |
          echo "Cloning TravelMemory repository..."
          git clone https://github.com/XXRadeonXFX/TravelMemory.git /app
          
          echo "Installing dependencies..."
          cd /app/backend
          npm install
          
          echo "Starting backend application..."
          node index.js
        ports:
        - containerPort: 3001
        env:
        - name: MONGO_URI
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: MONGO_URI
        - name: PORT
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: PORT
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
"@

$deploymentYaml | Out-File -FilePath "travelmemory-backend-deployment.yml" -Encoding utf8

# Step 3: Create Service YAML
Write-Host "`nStep 3: Creating Service YAML..." -ForegroundColor Green

$serviceYaml = @"
apiVersion: v1
kind: Service
metadata:
  name: travelmemory-backend-service
  namespace: backend
spec:
  selector:
    app: travelmemory-backend
  ports:
  - port: 80
    targetPort: 3001
  type: ClusterIP
"@

$serviceYaml | Out-File -FilePath "travelmemory-backend-service.yml" -Encoding utf8

# Step 4: Create Ingress YAML
Write-Host "`nStep 4: Creating Ingress YAML..." -ForegroundColor Green

$ingressYaml = @"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: travelmemory-backend-ingress
  namespace: backend
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: travelmemory-backend-service
            port:
              number: 80
"@

$ingressYaml | Out-File -FilePath "travelmemory-backend-ingress.yml" -Encoding utf8

# Step 5: Apply all YAML files
Write-Host "`nStep 5: Applying YAML files to deploy backend..." -ForegroundColor Green

kubectl apply -f travelmemory-backend-deployment.yml
kubectl apply -f travelmemory-backend-service.yml
kubectl apply -f travelmemory-backend-ingress.yml

# Step 6: Wait for deployment to be ready
Write-Host "`nStep 6: Waiting for deployment to be ready..." -ForegroundColor Green

kubectl rollout status deployment/travelmemory-backend -n backend

# Step 7: Check the deployment
Write-Host "`nStep 7: Checking deployment status..." -ForegroundColor Green

Write-Host "`nPods status:" -ForegroundColor Yellow
kubectl get pods -n backend -l app=travelmemory-backend

Write-Host "`nService details:" -ForegroundColor Yellow
kubectl get service travelmemory-backend-service -n backend

Write-Host "`nIngress details:" -ForegroundColor Yellow
kubectl get ingress travelmemory-backend-ingress -n backend

# Step 8: Provide testing instructions
Write-Host "`nStep 8: Testing your backend API" -ForegroundColor Green

Write-Host "`nTo port-forward and test locally:" -ForegroundColor Yellow
Write-Host "kubectl port-forward -n backend svc/travelmemory-backend-service 3001:80" -ForegroundColor Green
Write-Host "Then in a browser or with curl: http://localhost:3001/api/trips" -ForegroundColor Green

$ingressIP = kubectl get ingress travelmemory-backend-ingress -n backend -o jsonpath="{.status.loadBalancer.ingress[0].ip}" 2>$null
if ($ingressIP) {
    Write-Host "`nOr access via Ingress at:" -ForegroundColor Yellow
    Write-Host "http://$ingressIP/api/trips" -ForegroundColor Green
}

# Step 9: View logs if needed
Write-Host "`nStep 9: To check logs of your backend:" -ForegroundColor Green
$podName = kubectl get pods -n backend -l app=travelmemory-backend -o jsonpath="{.items[0].metadata.name}" 2>$null
if ($podName) {
    Write-Host "kubectl logs -f $podName -n backend" -ForegroundColor Green
}

Write-Host "`nDeployment complete! Your TravelMemory backend should now be running." -ForegroundColor Cyan
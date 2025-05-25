# TravelMemory Application Kubernetes Deployment

## Overview

TravelMemory is a web application that allows users to document and share their travel experiences. This repository contains all the necessary Kubernetes configuration files to deploy the complete TravelMemory application stack, including:

- MongoDB database with persistent storage
- Node.js backend API service
- React frontend UI

The application is structured in a three-tier architecture with separate namespaces for each component, ensuring proper isolation and resource management.

## Architecture

![TravelMemory Architecture](https://i.imgur.com/YourArchitectureDiagram.png)

### Components:

#### Database Tier (namespace: database)
- **MongoDB**: NoSQL database storing travel memories, user information, and comments
- **Persistent Volume**: Ensures data durability across pod restarts
- **MongoDB Service**: Internal endpoint for database access

#### Backend Tier (namespace: backend)
- **Node.js API**: RESTful API for creating, reading, updating, and deleting travel memories
- **Backend Service**: Internal service for the API
- **Ingress**: External access point for the API at `/api` path

#### Frontend Tier (namespace: frontend)
- **React Application**: Single-page application providing the user interface
- **Nginx Server**: Serves the static frontend files and handles routing
- **Ingress**: External access point for the frontend at `/` path

## Prerequisites

- Kubernetes cluster (minikube, K3s, or any cloud provider)
- kubectl configured to access your cluster
- Git (for deployment scripts)
- PowerShell (for running deployment scripts)

## Deployment Instructions

### 1. Clone this Repository

```bash
git clone <repository-url>
cd travelmemory-kubernetes
```

### 2. Create Namespaces

```bash
kubectl apply -f namespace.yml
```

This creates three namespaces:
- `database`: For MongoDB components
- `backend`: For the TravelMemory API
- `frontend`: For the React frontend

### 3. Deploy the Database Tier

```bash
# Apply in order
kubectl apply -f db-pv.yml
kubectl apply -f db-pvc.yml
kubectl apply -f db-deployment.yml
kubectl apply -f mongodb-service.yml
```

Verify the MongoDB deployment:
```bash
kubectl get pods -n database
```

### 4. Populate Initial Data (Optional)

To populate the MongoDB with sample travel data:

```powershell
.\insert-tripdetails.ps1
```

### 5. Deploy the Backend Tier

```bash
kubectl apply -f backend-secret.yml
kubectl apply -f travelmemory-backend-deployment.yml
kubectl apply -f travelmemory-backend-service.yml
kubectl apply -f travelmemory-backend-ingress.yml
```

Verify the backend is running:
```bash
kubectl get pods -n backend
```

### 6. Deploy the Frontend Tier

```bash
kubectl apply -f frontend-nginx-conf.yaml
kubectl apply -f frontend-env.yaml
kubectl apply -f travelmemory-frontend-deployment.yaml
kubectl apply -f travelmemory-frontend-service.yaml
kubectl apply -f travelmemory-frontend-ingress.yml
```

Alternatively, use the provided script:
```powershell
.\deploy-and-test-frontend.ps1
```

Verify the frontend is running:
```bash
kubectl get pods -n frontend
```

## Accessing the Application

### Method 1: Using Ingress (if Ingress controller is configured)

For backend API:
```
http://<cluster-ip>/api
```

For frontend:
```
http://<cluster-ip>/
```

### Method 2: Using Port Forwarding

For backend API:
```bash
kubectl port-forward -n backend svc/travelmemory-backend-service 3001:80
# Access at http://localhost:3001/api
```

For frontend:
```bash
kubectl port-forward -n frontend svc/travelmemory-frontend-service 3000:80
# Access at http://localhost:3000
```

## Testing

### Testing MongoDB

To test the MongoDB connectivity:

```bash
# Using nslookup from a temporary pod
kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh
# Inside the pod
nslookup mongodb-service.database.svc.cluster.local
```

For more comprehensive MongoDB testing:
```powershell
.\get-and-test-mongodb.ps1
```

### Testing Backend API

```bash
# Test with curl
curl http://localhost:3001/api/trips

# Or open in browser
http://localhost:3001/api/trips
```

### Testing Frontend

Access the frontend and verify you can:
1. View the list of trips
2. Click on individual trips for details
3. Navigate the application correctly

```bash
# Open in browser
http://localhost:3000
```

## Troubleshooting

### Database Tier Issues

1. Check MongoDB pod status:
   ```bash
   kubectl get pods -n database
   kubectl describe pod -n database <pod-name>
   ```

2. Check MongoDB logs:
   ```bash
   kubectl logs -n database <pod-name>
   ```

3. Verify Persistent Volume connection:
   ```bash
   kubectl get pv
   kubectl get pvc -n database
   ```

### Backend Tier Issues

1. Check backend pod status:
   ```bash
   kubectl get pods -n backend
   kubectl describe pod -n backend <pod-name>
   ```

2. Check backend logs:
   ```bash
   kubectl logs -n backend <pod-name>
   ```

3. Verify MongoDB connection in logs
4. Check Secret configuration:
   ```bash
   kubectl describe secret -n backend backend-secret
   ```

### Frontend Tier Issues

1. Check frontend pod status:
   ```bash
   kubectl get pods -n frontend
   kubectl describe pod -n frontend <pod-name>
   ```

2. Check init container build logs:
   ```bash
   kubectl logs -n frontend <pod-name> -c frontend-builder
   ```

3. Check Nginx server logs:
   ```bash
   kubectl logs -n frontend <pod-name> -c frontend-server
   ```

4. Verify ConfigMap configuration:
   ```bash
   kubectl describe configmap -n frontend frontend-env
   kubectl describe configmap -n frontend frontend-nginx-conf
   ```

## File Structure

```
.
├── database/
│   ├── db-deployment.yml       # MongoDB deployment
│   ├── db-pv.yml               # Persistent volume
│   ├── db-pvc.yml              # Persistent volume claim
│   └── mongodb-service.yml     # MongoDB service
├── backend/
│   ├── backend-secret.yml      # Secret with MongoDB URI
│   ├── travelmemory-backend-deployment.yml  # Backend application
│   ├── travelmemory-backend-service.yml     # Backend service
│   └── travelmemory-backend-ingress.yml     # Backend ingress
├── frontend/
│   ├── frontend-env.yaml       # Frontend environment variables
│   ├── frontend-nginx-conf.yaml  # Nginx configuration
│   ├── travelmemory-frontend-deployment.yaml  # Frontend application
│   ├── travelmemory-frontend-service.yaml     # Frontend service
│   └── travelmemory-frontend-ingress.yml      # Frontend ingress
├── scripts/
│   ├── deploy-and-test-frontend.ps1  # Frontend deployment script
│   ├── get-and-test-mongodb.ps1      # MongoDB testing script
│   └── insert-tripdetails.ps1        # Sample data script
├── namespace.yml               # Namespace definitions
└── README.md                   # This file
```

## Environment Variables

### Backend

- `MONGO_URI`: Connection string for MongoDB
- `PORT`: Port for the backend API (default: 3001)

### Frontend

- `REACT_APP_API_URL`: URL for the backend API

## Next Steps

- Set up CI/CD for automated deployments
- Add monitoring and logging
- Implement user authentication
- Configure backup and restore procedures
- Scale the application horizontally with multiple replicas

## Contributing

Please feel free to submit issues or pull requests to improve this deployment configuration.

## License

[Your License Here]

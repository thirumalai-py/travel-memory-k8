#!/bin/bash

# deploy-and-test-frontend.sh - Script for deploying and testing the TravelMemory frontend

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}Deploying and Testing TravelMemory Frontend${NC}"
echo -e "${CYAN}===========================================${NC}"

# Step 1: Apply all the frontend resources
echo -e "\n${GREEN}Step 1: Applying frontend resources...${NC}"

echo -e "${YELLOW}Creating Nginx configuration...${NC}"
kubectl apply -f frontend-nginx-conf.yaml

echo -e "${YELLOW}Creating environment configuration...${NC}"
kubectl apply -f frontend-env.yaml

echo -e "${YELLOW}Creating frontend deployment...${NC}"
kubectl apply -f travelmemory-frontend-deployment.yaml

echo -e "${YELLOW}Creating frontend service...${NC}"
kubectl apply -f travelmemory-frontend-service.yaml

# Step 2: Wait for the deployment to be ready
echo -e "\n${GREEN}Step 2: Waiting for deployment to be ready...${NC}"
kubectl rollout status deployment/travelmemory-frontend -n frontend

# Step 3: Check if the builder has completed
echo -e "\n${GREEN}Step 3: Checking frontend builder logs...${NC}"
frontendPod=$(kubectl get pods -n frontend -l app=travelmemory-frontend -o jsonpath="{.items[0].metadata.name}")

if [ -n "$frontendPod" ]; then
    echo -e "${YELLOW}Frontend pod found: $frontendPod${NC}"
    
    echo -e "\n${YELLOW}InitContainer logs:${NC}"
    kubectl logs -n frontend $frontendPod -c frontend-builder
    
    # Check if the init container completed successfully
    initContainerStatus=$(kubectl get pod $frontendPod -n frontend -o jsonpath="{.status.initContainerStatuses[0].state.terminated.reason}" 2>/dev/null)
    
    if [ "$initContainerStatus" = "Completed" ]; then
        echo -e "\n${GREEN}Init container completed successfully!${NC}"
    else
        echo -e "\n${RED}Init container may not have completed. Status: $initContainerStatus${NC}"
    fi
else
    echo -e "${RED}No frontend pod found.${NC}"
fi

# Step 4: Set up port forwarding
echo -e "\n${GREEN}Step 4: Setting up port forwarding to test the frontend...${NC}"
echo -e "${YELLOW}Opening a new terminal window with port forwarding. Access at http://localhost:3000${NC}"

# Function to detect the available terminal emulator
open_terminal_with_port_forward() {
    local port_forward_cmd="kubectl port-forward -n frontend svc/travelmemory-frontend-service 3000:80"
    
    # Try different terminal emulators based on the system
    if command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal -- bash -c "$port_forward_cmd; echo 'Press Enter to close'; read"
    elif command -v xterm >/dev/null 2>&1; then
        xterm -e bash -c "$port_forward_cmd; echo 'Press Enter to close'; read" &
    elif command -v konsole >/dev/null 2>&1; then
        konsole -e bash -c "$port_forward_cmd; echo 'Press Enter to close'; read" &
    elif command -v terminator >/dev/null 2>&1; then
        terminator -e "bash -c '$port_forward_cmd; echo Press Enter to close; read'" &
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        osascript -e "tell application \"Terminal\" to do script \"$port_forward_cmd; echo 'Press Enter to close'; read\""
    else
        echo -e "${YELLOW}Could not detect terminal emulator. Starting port forwarding in background...${NC}"
        $port_forward_cmd &
        PORT_FORWARD_PID=$!
        echo -e "${YELLOW}Port forwarding started with PID: $PORT_FORWARD_PID${NC}"
        echo -e "${YELLOW}To stop: kill $PORT_FORWARD_PID${NC}"
    fi
}

# Start port forwarding
open_terminal_with_port_forward

# Step 5: Open browser after a short delay
echo -e "\n${GREEN}Step 5: Opening browser to test frontend...${NC}"
sleep 5

# Function to open browser based on the system
open_browser() {
    local url="http://localhost:3000"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$url"
        elif command -v firefox >/dev/null 2>&1; then
            firefox "$url" &
        elif command -v google-chrome >/dev/null 2>&1; then
            google-chrome "$url" &
        elif command -v chromium-browser >/dev/null 2>&1; then
            chromium-browser "$url" &
        else
            echo -e "${YELLOW}Could not auto-open browser. Please manually navigate to: $url${NC}"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open "$url"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        # Windows (Git Bash, Cygwin, etc.)
        start "$url" 2>/dev/null || cmd /c start "$url"
    else
        echo -e "${YELLOW}Could not auto-open browser. Please manually navigate to: $url${NC}"
    fi
}

open_browser

# Step 6: Provide testing instructions
echo -e "\n${CYAN}Frontend should now be accessible at http://localhost:3000${NC}"
echo -e "${YELLOW}If the frontend doesn't load properly, check:${NC}"
echo -e "${YELLOW}1. Backend connectivity: kubectl logs -n frontend $frontendPod -c frontend-server${NC}"
echo -e "${YELLOW}2. Environment configuration: kubectl describe configmap frontend-env -n frontend${NC}"
echo -e "${YELLOW}3. Nginx configuration: kubectl describe configmap frontend-nginx-conf -n frontend${NC}"

echo -e "\n${GREEN}To manually port-forward in case the window was closed:${NC}"
echo -e "${GREEN}kubectl port-forward -n frontend svc/travelmemory-frontend-service 3000:80${NC}"

echo -e "\n${CYAN}Deployment and testing complete!${NC}"

# Optional: Wait for user input before exiting
echo -e "\n${YELLOW}Press Enter to exit...${NC}"
read
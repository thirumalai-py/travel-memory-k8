6443 from 0.0.0.0/0

2379 - 2380 from same-security-group-id

10250 - 10252 from same-security-group-id

Aryan.mohan60@gmail.com



sudo su -

- get the contexts
kubectl config get-contexts 

- Use the context
 kubectl config use-context kubernetes-admin@kubernetes  

- Run the command to save the config to the local mac of the selfmanaged cluster
KUBECONFIG=/c/Users/<your-username>/.kube/config:/c/Users/<your-username>/.kube/self-managed-cluster-config kubectl config view --flatten > config-merged

- Eg
KUBECONFIG=/Users/thirumalairaja/.kube/config:/Users/thirumalairaja/Documents/Hero/Docker/travel-memory-k8/self_managed_ks/master_config.txt kubectl config view --flatten > config-merged


















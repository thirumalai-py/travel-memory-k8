
# Create a test pod
kubectl run mongo-test --image=mongo:latest -n database

# Open a shell to the pod
kubectl exec -it mongo-test -n database -- bash

# Inside the pod, connect to MongoDB
mongosh mongodb-service:27017

# Inside the MongoDB shell, explore your database
> use TravelMemory
> show collections
> db.tripdetails.find().pretty()
> exit

# Test your connection string format
mongosh "mongodb://mongodb-service.database.svc.cluster.local:27017/TravelMemory"
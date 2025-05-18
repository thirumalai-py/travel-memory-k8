# Travel Memory

`.env` file to work with the backend after creating a database in mongodb: 

```
MONGO_URI='ENTER_YOUR_URL'
PORT=3001
```

Data format to be added: 

```json
{
    "tripName": "Incredible India",
    "startDateOfJourney": "19-03-2022",
    "endDateOfJourney": "27-03-2022",
    "nameOfHotels":"Hotel Namaste, Backpackers Club",
    "placesVisited":"Delhi, Kolkata, Chennai, Mumbai",
    "totalCost": 800000,
    "tripType": "leisure",
    "experience": "Lorem Ipsum, Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum, ",
    "image": "https://t3.ftcdn.net/jpg/03/04/85/26/360_F_304852693_nSOn9KvUgafgvZ6wM0CNaULYUa7xXBkA.jpg",
    "shortDescription":"India is a wonderful country with rich culture and good people.",
    "featured": true
}
```


For frontend, you need to create `.env` file and put the following content (remember to change it based on your requirements):
```bash
REACT_APP_BACKEND_URL=http://localhost:3001
```

## Docker Commands

### Build the image
docker build -t travel-frontend:V1.2 .

### Run the image
docker run -d -p 3001:3001 --name docker_backend travel-backend:V1.0
docker run -d -p 3000:3000 --name docker_frontend travel-frontend:V1.2

### Run the image with ENV variable
docker run -d -p 3001:3001 -e MONGO_URI="mongodb+srv://thirumalaipy:SL2OuQmQhJs9UwFP@cluster0.1uz02.mongodb.net/travelmemory?retryWrites=true&w=majority" --name docker_backend travel-local-backend:V1.0

### Run the image with more than 1 ENV variable
docker run -d -p 3001:3001 -e MONGO_URI="mongodb+srv://thirumalaipy:SL2OuQmQhJs9UwFP@cluster0.1uz02.mongodb.net/travelmemory?retryWrites=true&w=majority" -e  PORT="3001" --name docker_backend_2 travel-local-backend:V1.0

### Run the image with Network name and ENV variable
docker run -d -p 3001:3001 -e MONGO_URI="mongodb://mongo:27017/travelmemory?retryWrites=true&w=majority" --network tmnetwork --name docker_backend travel-local-backend:V1.0

# Volume
docker volume create databasemongo
docker run -d -p 27018:27017 -v databasemongo:/data/db  mongo:latest

# Build Mount for the External volume path
docker run -d -p 8080:80 -v D:/teaching/batch10/dockerLearning/html:/usr/share/nginx/html nginx


# Network
docker network create tmnetwork
docker network ls
docker run -d -p 27017:27017 -v mongovolume:/data/db --network tmnetwork --name mongo mongo:latest


# Docker Push 
docker tag local-name hub-nam:tag
docker push thirumalaipy/flask:2.0
docker pull thirumalaipy/flask:2.0



# ECS Video of prasanth
https://www.youtube.com/watch?v=V-y1rzHoq08
# Github actions
https://github.com/UnpredictablePrashant/CICDPipeline-html/tree/main

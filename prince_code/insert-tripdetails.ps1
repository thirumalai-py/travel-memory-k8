 insert-tripdetails.ps1 - PowerShell script to insert trip details data into MongoDB

Write-Host "Inserting Trip Details into MongoDB" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Create the MongoDB script file
Write-Host "`nCreating MongoDB script file..." -ForegroundColor Green
$mongoScript = @'
// Switch to TravelMemory database
db = db.getSiblingDB('TravelMemory');

// Insert the two trip details documents with exact same IDs and data
db.tripdetails.insertMany([
  {
    _id: ObjectId("67f56e6ea804d45c12cf8866"),
    tripName: "Incredible India",
    startDateOfJourney: "19-03-2022",
    endDateOfJourney: "27-03-2022",
    nameOfHotels: "Hotel Namaste, Backpackers Club",
    placesVisited: "Delhi, Kolkata, Chennai, Mumbai",
    totalCost: 800000,
    tripType: "leisure",
    experience: "Lorem Ipsum, Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum",
    image: "https://t3.ftcdn.net/jpg/03/04/85/26/360_F_304852693_nSOn9KvUgafgvZ6wM_",
    shortDescription: "India is a wonderful country with rich culture and good people.",
    featured: true,
    createdAt: new Date("2025-04-08T18:26:06.901+00:00"),
    __v: 0
  },
  {
    _id: ObjectId("67f59b09e37a988528a39723"),
    tripName: "Serene Switzerland",
    startDateOfJourney: "12-05-2023",
    endDateOfJourney: "22-05-2023",
    nameOfHotels: "Alpine Lodge, Zurich Grand, Lake View Resort",
    placesVisited: "Zurich, Lucerne, Interlaken, Geneva, Zermatt",
    totalCost: 950000,
    tripType: "leisure",
    experience: "The majestic Alps took my breath away at every turn. Train journeys through scenic routes were unforgettable.",
    image: "https://t4.ftcdn.net/jpg/02/95/24/49/360_F_295244964_iUbhoOEzCB5rjg6eZ",
    shortDescription: "Alpine paradise with crystal lakes, chocolate, and panoramic mountain views.",
    featured: true,
    createdAt: new Date("2025-04-08T21:33:46.093+00:00"),
    __v: 0
  }
], { ordered: true });

// Verify insertion
print("\n=== Inserted Trip Details ===");
print("Total documents: " + db.tripdetails.countDocuments());
print("\nTrip names:");
db.tripdetails.find({}, {tripName: 1}).forEach(function(doc) {
  print(" - " + doc.tripName);
});
'@

$mongoScript | Out-File -FilePath "tripdetails-insert.js" -Encoding utf8

# Check if a temporary pod already exists and delete it
$podExists = kubectl get pod mongo-client -n database 2>$null
if ($podExists) {
    Write-Host "`nExisting mongo-client pod found, removing it..." -ForegroundColor Yellow
    kubectl delete pod mongo-client -n database
}

# Create temporary MongoDB client pod
Write-Host "`nCreating temporary MongoDB client pod..." -ForegroundColor Green
kubectl run mongo-client --image=mongo:latest -n database --restart=Never

# Wait for the pod to be ready
Write-Host "`nWaiting for MongoDB client pod to be ready..." -ForegroundColor Green
kubectl wait --for=condition=ready pod/mongo-client -n database --timeout=60s

# Copy the script to the pod
Write-Host "`nCopying script to pod..." -ForegroundColor Green
kubectl cp tripdetails-insert.js database/mongo-client:/tripdetails-insert.js

# Run the script
Write-Host "`nExecuting script to insert trip details data..." -ForegroundColor Green
kubectl exec -it mongo-client -n database -- mongosh mongodb-service:27017 /tripdetails-insert.js

# Cleanup
Write-Host "`nCleaning up..." -ForegroundColor Green
Remove-Item -Path "tripdetails-insert.js" -Force
kubectl delete pod mongo-client -n database

Write-Host "`nTrip details data insertion complete!" -ForegroundColor Cyan
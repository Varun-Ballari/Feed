# Feed
### Make a Difference Hackathon Project


Our app allows users to donate their excess food to food banks through UPS drivers traveling en route. The user takes a picture of the food items and answers a few simple questions to ensure the food's preservability and quality and then clicks donate. The app will then let the user know when the UPS driver will arrive to the specified location to pick up the food items.


### API's and Modules

* `UPS Api`
* `Python Flask`
* `iOS Vision`
* `iOS CoreML`


### Details on Features
Feed was built on Swift. We utilized Apple's machine learning model Resnet50 to detect the food that the user is trying to donate. We utilized MapKit to construct an interactive interface so users can view food bank locations and the distances from their location, and  utilized CoreLocation, AVKit, and Vision to get the addresses of the food banks, access the device's video functionalities, and analyze the pictures of food to be donated, respectively. We stored the user and food bank information in a database through MongoDB. Our backend was build on Python, Flask, and Javascript. The optimal food bank was chosen from an all-encompassing algorithm that calculates the shortest distance between the user's location and food banks and takes the food bank's requirements into account as well as price user would have to pay.



### Devpost
[__HERE__](https://devpost.com/software/feed-k8yrtn)
This project won 1st place at Make a Difference Hackathon (01/2018)

### Hosting
It is hosted on Heroku and uses Postgres as a MongoDB for infromation for user authentication, user history, and general information about food banks.

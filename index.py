from flask import Flask, request, render_template, jsonify
import os
import pymongo
import random
import requests


# CONSUMER_KEY = os.environ.get('CONSUMER_KEY') or keys['consumer_key']
# CONSUMER_SECRET = os.environ.get('CONSUMER_SECRET') or keys['consumer_secret']
# ACCESS_TOKEN = os.environ.get('ACCESS_TOKEN') or keys['access_token']
# ACCESS_TOKEN_SECRET = os.environ.get('ACCESS_TOKEN_SECRET') or keys['access_token_secret']

app = Flask(__name__)


USERNAME = os.environ.get('USERNAME') or 'feed'
PASSWORD = os.environ.get('PASSWORD') or 'cochack'

client = pymongo.MongoClient("mongodb://" + USERNAME + ":" + PASSWORD+ "@cluster0-shard-00-00-ckk4p.mongodb.net:27017/,cluster0-shard-00-01-ckk4p.mongodb.net:27017/,cluster0-shard-00-02-ckk4p.mongodb.net:27017/admin?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin")
# client = pymongo.MongoClient("localhost", 27017)

# client = pymongo.MongoClient("localhost", 27017)

# DELETE_DB_PASSWORD = os.environ.get('DELETE_DB_PASSWORD') or keys['delete_db_password']

db = client.Feed
users = db.Users
foodbanks = db.Foodbanks
history = db.History


@app.route('/')
def index():
    return jsonify({"success": True, "Works" : True })


@app.route('/users', methods=['GET'])
def login():

    email = request.args.get('email')
    password = request.args.get('password')
    print(email, password)

    if email == None or password == None:
        print("NOT WORKING!")

    # Check if user exists
    finder = list(users.find({"email": email, "password" : password }, {"email" : 1}))
    print(finder)
    if (len(finder) != 0):
        return jsonify({"success": True, "email" : finder[0]['email']}) #<- Varun, you're so extra
    else:
        return jsonify({"success": False})

# Returns list of all foodbanks
@app.route('/allFoodBanks', methods=['GET'])
def allfoodBanks():
    finder = list(foodbanks.find({}, {"foodLast": 0}))
    return jsonify({"success": True, "foodBankList" : finder})


#Choose which foodbank to deliver food to and get delivery estimates using UPS's Rate API
@app.route('/requestDropoff', methods=['POST'])
def requestDropoff():
    how_long = request.args.get('how_long') #How long the food will last

    foodName = request.args.get('foodName') #How name of the food
    servings = request.args.get('servings') #How many people can the food serve
    userStreet = request.args.get('userStreet') # \
    userCity  = request.args.get('userCity')    # |
    userState = request.args.get('userState')   # | Location of the user
    userZip = request.args.get('userZip')       # /

    # Check if user exists
    finder = list(foodbanks.find({"foodLast": {"$lt": how_long} }, {"name" : 1, 
        "street": 1, "city": 1, "state": 1, "zip": 1}))
    # Return best drop off location

    for fb in finder:
        fb_name = finder['name']
        fb_street = finder['street']
        fb_city = finder['city']
        fb_state = finder['state']
        fb_zip = finder['zip']

        dictToSend = {
            "UPSSecurity": {
                "UsernameToken": {
                    "Username": "raghavmittal",
                    "Password": "Cochackathon123"
                },
                "ServiceAccessToken": {
                    "AccessLicenseNumber": "AD3CD993372CEA8C"
                }
            },
            "RateRequest": {
                "Request": {
                    "RequestOption": "Ratetimeintransit",
                    "TransactionReference": {
                        "CustomerContext": "Your Customer Context"
                    }
                },
                "Shipment": {
                    "Shipper": {
                        "Name": "Shipper Name",
                        "ShipperNumber": "Shipper Number",
                        "Address": {
                            "AddressLine": [userStreet],
                            "City": userCity,
                            "StateProvinceCode": userState,
                            "PostalCode": userZip,
                            "CountryCode": "US"
                        }
                    },
                    "ShipTo": {
                        "Name": fb_name,
                        "Address": {
                            "AddressLine": [fb_street],
                            "City": fb_city,
                            "StateProvinceCode": fb_state,
                            "PostalCode": fb_zip,
                            "CountryCode": "US"
                        }
                    },
                    "ShipFrom": {
                        "Name": "Ship From Name",
                        "Address": {
                            "AddressLine": [userStreet],
                            "City": userCity,
                            "StateProvinceCode": userState,
                            "PostalCode": userZip,
                            "CountryCode": "US"
                        }
                    },
                    "Service": {
                        "Code": "03",
                        "Description": "Service Code Description"
                    },
                    "Package": {
                        "PackagingType": {
                            "Code": "02",
                            "Description": "Rate"
                        },
                        "Dimensions": {
                            "UnitOfMeasurement": {
                                "Code": "IN",
                                "Description": "inches"
                            },
                            "Length": "5",
                            "Width": "4",
                            "Height": "3"
                        },
                        "PackageWeight": {
                            "UnitOfMeasurement": {
                                "Code": "Lbs",
                                "Description": "pounds"
                            },
                            "Weight": "1"
                        }
                    },

                    "DeliveryTimeInformation": {
                        "Pickup": {
                            "Date": "20180127"
                        },
                        "PackageBillType": "03"
                    }
                }
            }
        }
        res = requests.post('https://wwwcie.ups.com/rest/Rate', json=dictToSend)
        resDict = res.json()
        total_charges = resDict['RateResponse']['RatedShipment']['TotalCharges']
        summary_dict = resDict['RateResponse']['RatedShipment']['TimeInTransit']['ServiceSummary']

        arrivalDate = summary_dict['EstimatedArrival']['Arrival']['Date']
        arrivalTime = summary_dict['EstimatedArrival']['Arrival']['Time']

        businessDaysInTransit = summary_dict['EstimatedArrival']['BusinessDaysInTransit']

        pickupDate = summary_dict['EstimatedArrival']['Pickup']['Date']
        pickupTime = summary_dict['EstimatedArrival']['Pickup']['Time']

        dayOfWeek = summary_dict['EstimatedArrival']['DayOfWeek']


    return jsonify({"success": True})


@app.route('/userHistory')
def userHistory():

    # return from history table

    return jsonify({"success": True})


if __name__ == '__main__':
    app.run(debug = True)


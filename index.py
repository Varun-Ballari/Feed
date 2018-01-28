from flask import Flask, request, render_template, jsonify
import os
import ast
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
    finder = list(foodbanks.find({}, {"foodLast": 0, "_id": 0}))
    return jsonify({"success": True, "foodBankList" : finder})


#Choose which foodbank to deliver food to and get delivery estimates using UPS's Rate API
@app.route('/requestDropoff', methods=['POST'])
def requestDropoff():
    body = request.form
    how_long = body.get('how_long') #How long the food will last
    foodName = body.get('foodName') #How name of the food
    servings = body.get('servings') #How many people can the food serve
    userStreet = body.get('userStreet') # \
    userCity  = body.get('userCity')    # |
    userState = body.get('userState')   # | Location of the user
    userZip = body.get('userZip')       # /

    # Check if food bank will accept it
    # finder = list(foodbanks.find({"foodLast": {"$lt": int(how_long)} }, {"name" : 1, 
    #     "street": 1, "city": 1, "state": 1, "zip": 1}))


    finder = list(foodbanks.find({}, {"name" : 1, 
    "street": 1, "city": 1, "state": 1, "zip": 1}))

    chargeList = []
    summaryList = []
    arrivalList = []
    for fb in finder:
        fb_name = fb['name']
        fb_street = fb['street']
        fb_city = fb['city']
        fb_state = fb['state']
        fb_zip = fb['zip']

        print(index)
        print(fb_name)
        print(fb_street)
        print(fb_city)
        print(fb_state)
        print(fb_zip)
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
                            "AddressLine": ["350 Ferst drive"],
                            "City": "Atlanta",
                            "StateProvinceCode": "GA",
                            "PostalCode": "30332",
                            "CountryCode": "US"
                        }
                    },
                    "ShipTo": {
                        "Name": "Atlanta Community Food Bank",
                        "Address": {
                            "AddressLine": ["732 Joseph E. Lowery Blvd NW"],
                            "City": "Atlanta",
                            "StateProvinceCode": "GA",
                            "PostalCode": "30332",
                            "CountryCode": "US"
                        }
                    },
                    "ShipFrom": {
                        "Name": "Ship From Name",
                        "Address": {
                            "AddressLine": ["350 Ferst drive"],
                            "City": "Atlanta",
                            "StateProvinceCode": "GA",
                            "PostalCode": "30332",
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

        chargeList.append(total_charges)
        summaryList.append(summary_dict)
        arrivalList.append(arrivalDate + arrivalTime)

    # return the index of the earlier arrival date and time
    index = arrivalList.index(min(arrivalList))
    summary = summaryList[index]

    charge = chargeList[index]
    arrivalDate = summary_dict['EstimatedArrival']['Arrival']['Date']
    arrivalTime = summary_dict['EstimatedArrival']['Arrival']['Time']
    businessDaysInTransit = summary_dict['EstimatedArrival']['BusinessDaysInTransit']
    pickupDate = summary_dict['EstimatedArrival']['Pickup']['Date']
    pickupTime = summary_dict['EstimatedArrival']['Pickup']['Time']
    dayOfWeek = summary_dict['EstimatedArrival']['DayOfWeek']

    fb_name = finder[index]['name']
    fb_street = finder[index]['street']
    fb_city = finder[index]['city']
    fb_state = finder[index]['state']
    fb_zip = finder[index]['zip']
    return jsonify({"success": True})


@app.route('/userHistory', methods=['GET'])
def userHistory():
    email = request.args.get('email')
    finder = list(foodbanks.find({"email": email}, {"_id": 0}))
    return jsonify({"success": True, "userHistoryList" : finder})


if __name__ == '__main__':
    app.run(debug = True)


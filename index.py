from flask import Flask, request, render_template, jsonify
import os
import ast
import pymongo
import random
import requests
import geocoder
import datetime

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

# Testing purposes
#chosenFoodBank = "ATL Food Bank"
#chosenSummary = {u'EstimatedArrival': {u'Arrival': {u'Date': u'20180130', u'Time': u'230000'}, u'DayOfWeek': u'TUE', u'Pickup': {u'Date': u'20180127', u'Time': u'000000'}, u'CustomerCenterCutoff': u'000000', u'BusinessDaysInTransit': u'1'}, u'GuaranteedIndicator': u'', u'Service': {u'Description': u'UPS Ground'}, u'SaturdayDelivery': u'0'}
#chosenTotalCharge = "9.43"

# chosenFoodBank = None
# chosenSummary = None
# chosenTotalCharge = None

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
@app.route('/requestDropoff', methods=['GET'])
def requestDropoff():
    userLat = float(request.args.get('latitude'))
    userLong = float(request.args.get('longitude'))
    g = geocoder.google([userLat, userLong], method='reverse')
    userStreet = g.street
    userCity = g.city
    userState = g.state
    userZip = g.postal

#    print(userStreet)
#    print(userCity)
#    print(userState)
#    print(userZip)
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

#        print(fb_name)
#        print(fb_street)
#        print(fb_city)
#        print(fb_state)
#        print(fb_zip)
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
        
        total_charges = resDict['RateResponse']['RatedShipment']['TotalCharges']['MonetaryValue']
        summary_dict = resDict['RateResponse']['RatedShipment']['TimeInTransit']['ServiceSummary']
        arrivalDate = summary_dict['EstimatedArrival']['Arrival']['Date']
        arrivalTime = summary_dict['EstimatedArrival']['Arrival']['Time']

        chargeList.append(total_charges)
        summaryList.append(summary_dict)
        arrivalList.append(arrivalDate + arrivalTime)

    # return the index of the earlier arrival date and time
    index = arrivalList.index(min(arrivalList))

    chosenSummary = summaryList[index] #global variable
    chosenTotalCharge = chargeList[index] #global variable

    chosenFoodBank = finder[index]['name'] #global variable (so sendFood can access it)
    fb_street = finder[index]['street']
    fb_city = finder[index]['city']
    fb_state = finder[index]['state']
    fb_zip = finder[index]['zip']

    g = geocoder.google(fb_street + ", " + fb_city + " " + fb_state + ", US " + fb_zip)
    lat, lng = g.latlng
    return jsonify({"success": True, "latitude": lat, "longitude": lng, "name": chosenFoodBank})

#Place the UPS request
@app.route('/sendFood', methods=['POST'])
def sendFood():
    body = request.form
    foodName = body.get('foodName') #How name of the food
    serving = body.get('serving') #How many people can the food serve
    email = body.get('email') #email of sender
    fb_name = body.get('name') #name of Food Bank
    today = datetime.datetime.utcnow()

    userLat = float(body.get('myLat'))
    userLng = float(body.get('myLng'))
    g = geocoder.google([userLat, userLng], method='reverse')
    userStreet = g.street
    userCity = g.city
    userState = g.state
    userZip = g.postal

    fb_lat = float(body.get('toLat'))
    fb_lng = float(body.get('toLng'))
    g = geocoder.google([fb_lat, fb_lng], method='reverse')
    fb_street = g.street
    fb_city = g.city
    fb_state = g.state
    fb_zip = g.postal


    history.insert({
        'email': email,
        'foodBankName': fb_name,
        'serving': serving,
        'foodName': foodName,
        'Date': today
        })

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
        
    total_charges = resDict['RateResponse']['RatedShipment']['TotalCharges']['MonetaryValue']
    summary_dict = resDict['RateResponse']['RatedShipment']['TimeInTransit']['ServiceSummary']
    arrivalDate = summary_dict['EstimatedArrival']['Arrival']['Date']
    arrivalTime = summary_dict['EstimatedArrival']['Arrival']['Time']
    businessDaysInTransit = summary_dict['EstimatedArrival']['BusinessDaysInTransit']
    pickupDate = summary_dict['EstimatedArrival']['Pickup']['Date']
    pickupTime = summary_dict['EstimatedArrival']['Pickup']['Time']
    dayOfWeek = summary_dict['EstimatedArrival']['DayOfWeek']

    return jsonify({"success": True, "arrivalDate": arrivalDate, "arrivalTime": arrivalTime,
        "pickupDate": pickupDate, "pickupTime": pickupTime,
        "businessDaysInTransit": businessDaysInTransit, "dayOfWeek":dayOfWeek} )


@app.route('/userHistory', methods=['GET'])
def userHistory():
    email = request.args.get('email')
    finder = list(history.find({"email": email}, {"_id": 0}))
    serving_sum = 0
    for x in finder:
        sum += int(x["serving"])
    return jsonify({"success": True, "userHistoryList" : finder, "sum" : serving_sum})


if __name__ == '__main__':
    app.run(debug = True)

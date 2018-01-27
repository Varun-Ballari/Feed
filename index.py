from flask import Flask, request, render_template, jsonify
import os
import pymongo
import random


# CONSUMER_KEY = os.environ.get('CONSUMER_KEY') or keys['consumer_key']
# CONSUMER_SECRET = os.environ.get('CONSUMER_SECRET') or keys['consumer_secret']
# ACCESS_TOKEN = os.environ.get('ACCESS_TOKEN') or keys['access_token']
# ACCESS_TOKEN_SECRET = os.environ.get('ACCESS_TOKEN_SECRET') or keys['access_token_secret']




app = Flask(__name__)


USERNAME = os.environ.get('USERNAME') or 'feed'
PASSWORD = os.environ.get('PASSWORD') or 'cochack'

client = pymongo.MongoClient("mongodb://" + USERNAME + ":" + PASSWORD+ "@cluster0-shard-00-00-ckk4p.mongodb.net:27017,cluster0-shard-00-01-ckk4p.mongodb.net:27017,cluster0-shard-00-02-ckk4p.mongodb.net:27017/admin?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin")
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
        return jsonify({"success": True, "email" : finder[0]['email']})
    else:
        return jsonify({"success": False})



@app.route('/findDropoff', methods=['GET'])
def findDropoff():
    params = request.args
    how_old = params.get('how_old') #How old the food is
    how_long = params.get('how_long') #How long the food will last
    servings = params.get('servings') #How many people can the food serve

    db.runCommand({
        insert: "users",
        documents: [ { _id: 1, user: "abc123", status: "A" } ]
    })
    # Return best drop off location

    return jsonify({"success": True, "count" : 0})


@app.route('/userHistory')
def userHistory():

    # return from history table

    return jsonify({"success": True, "countryList" : countryList})


if __name__ == '__main__':
    app.run(debug = True)

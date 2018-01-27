from flask import Flask, request, render_template, jsonify
import os
import pymongo
import random

# from sklearn.feature_extraction.text import CountVectorizer

try:
    from keys import keys
except:
    print("Keys File not Found. Online Access")

# CONSUMER_KEY = os.environ.get('CONSUMER_KEY') or keys['consumer_key']
# CONSUMER_SECRET = os.environ.get('CONSUMER_SECRET') or keys['consumer_secret']
# ACCESS_TOKEN = os.environ.get('ACCESS_TOKEN') or keys['access_token']
# ACCESS_TOKEN_SECRET = os.environ.get('ACCESS_TOKEN_SECRET') or keys['access_token_secret']




app = Flask(__name__)

USERNAME = "feed"
PASSWORD = "cochack"

client = pymongo.MongoClient("mongodb://" + USERNAME + ":" + PASSWORD+ "@cluster0-shard-00-00-ckk4p.mongodb.net")
# client = pymongo.MongoClient("localhost", 27017)

# DELETE_DB_PASSWORD = os.environ.get('DELETE_DB_PASSWORD') or keys['delete_db_password']

db = client.Feed
users = db.Users
foodbanks = db.Foodbanks
history = db.History


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/users', methods=['GET'])
def login():
    user_info = request.args #request.form
    username = str(user_info.get('username'))
    password = str(user_info.get('password'))

    finder = users.find({}, {})

    # Check if user exists
    finder = users.find({"email": username, "password" : password }, {"email" : 1})
    finder = finder.toArray()
    if len(finder) == 1:
        return jsonify({"success": True, "count" : 1 })
    else:
        return jsonify({"success": False, "count" : len(finder)})


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
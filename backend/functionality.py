from flask import Flask, request, render_template, jsonify
import os
import pymongo
import pprint
import random
import pycountry

# from sklearn.feature_extraction.text import CountVectorizer
import numpy as np

try:
    from keys import keys
except:
    print("Keys File not Found. Online Access")

# CONSUMER_KEY = os.environ.get('CONSUMER_KEY') or keys['consumer_key']
# CONSUMER_SECRET = os.environ.get('CONSUMER_SECRET') or keys['consumer_secret']
# ACCESS_TOKEN = os.environ.get('ACCESS_TOKEN') or keys['access_token']
# ACCESS_TOKEN_SECRET = os.environ.get('ACCESS_TOKEN_SECRET') or keys['access_token_secret']

# auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
# auth.set_access_token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
# api = tweepy.API(auth)


# app = Flask(__name__)

# USERNAME = os.environ.get('USERNAME') or keys['username']
# PASSWORD = os.environ.get('PASSWORD') or keys['password']

# client = pymongo.MongoClient("mongodb://" + USERNAME + ":" + PASSWORD+ "@cluster0-shard-00-00-99szw.mongodb.net:27017,cluster0-shard-00-01-99szw.mongodb.net:27017,cluster0-shard-00-02-99szw.mongodb.net:27017/admin?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin")
# client = pymongo.MongoClient("localhost", 27017)

# DELETE_DB_PASSWORD = os.environ.get('DELETE_DB_PASSWORD') or keys['delete_db_password']

# db = client.CS4440
# coordinates = db.coordinates
# countries = db.countries
# countTweets = db.countTweets


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/users', methods=['GET'])
def login():
    user_info = request.args #request.form
    username = str(user_info.get('username'))
    password = str(user_info.get('password'))

    # CHECK IF USER EXISTS

        return jsonify({"everything": everything[:numWords], "finalList":finalList[:numWords], "words": wordsList[:numWords], "frequency": freqList[:numWords], "sumWords": int(sumWords)})
    else:
        return jsonify({"everything": everything, "finalList":finalList, "words": wordsList, "frequency": freqList, "sumWords": int(sumWords)})



@app.route('/findDropoff', methods=['GET'])
def findDropoff():
    params = request.args
    how_old = params.get('how_old') #How old the food is
    how_long = params.get('how_long') #How long the food will last
    servings = params.get('servings') #How many people can the food serve

    # Return best drop off location

    return jsonify({"success": True, "count" : 0})


@app.route('/userHistory')
def userHistory():

    # return from history table

    return jsonify({"success": True, "countryList" : countryList})


if __name__ == '__main__':
    app.run(debug = True)

from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

uri = "mongodb+srv://root:123456LILI@lili.dj6gkxo.mongodb.net/?retryWrites=true&w=majority&appName=LILI"

# Create a new client and connect to the server
client = MongoClient(uri, server_api=ServerApi('1'))

# Send a ping to confirm a successful connection
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)



import mysql.connector
from mysql.connector import Error

try:
    conn = mysql.connector.connect(
        host="maglev.proxy.rlwy.net",
        port=48289,
        user="root",
        password="kjtNngDcdosjnqdZmdADZIxOpyiiVKWF",
        database="railway"
    )

    cursor = conn.cursor()
    # cursor.execute("INSERT INTO household_tbl (house_Name, house_pic, house_address) VALUES (%s, %s, %s)", ("H1", "sss", "H1Adress"))
    # conn.commit()

    cursor.execute(("Select * from household_tbl"))
    data= cursor.fetchall()
    for i in data:
        print(i)


except Error as e:
    print("❌ Error while connecting to MySQL:", e)


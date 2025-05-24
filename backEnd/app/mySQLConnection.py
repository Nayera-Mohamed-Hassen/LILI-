import os
from dotenv import load_dotenv
import mysql.connector

load_dotenv()

def insert_HouseHold(name: str, pic: str, address: str) -> bool:
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=os.getenv("MYSQL_PORT"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )
        cursor = conn.cursor()

        query = "INSERT INTO household_tbl (house_Name, house_pic, house_address) VALUES (%s, %s, %s)"
        values = (name, pic, address)
        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print("Error inserting user:", e)
        return False

if __name__ == '__main__':
    print(insert_HouseHold("H1", "sss", "H1Adress"))

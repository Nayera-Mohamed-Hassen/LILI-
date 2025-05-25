import os
from datetime import datetime

from dotenv import load_dotenv
import mysql.connector

load_dotenv()


###########  insert house  #############
def insertHouseHold(name: str, pic: str, address: str) -> bool:
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




############ select house ################
def selectHouseHold(query:str = "") -> list:
    data = []
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=os.getenv("MYSQL_PORT"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )

        cursor = conn.cursor()
        if query == "":
            cursor.execute("SELECT * FROM household_tbl")
            data = cursor.fetchall()

        else:
            cursor.execute(query)  # Ensure `query` is safe or use parameters
            data = cursor.fetchall()

        cursor.close()
        conn.close()
        return data
    except Exception as e:
        print("Error fetching data:", e)



############ insert user #############

def insertUser(
    user_Name: str,
    user_role: str,
    user_password: str,
    user_birthday: str,  # Format: "YYYY-MM-DD"
    user_profilePic: str = None,
    user_email: str = "",
    user_phone: str = "",
    user_Height: float = None,
    user_weight: float = None,
    user_diet: str = "",
    user_gender: str = "",
    house_Id: int = None
) -> bool:
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=os.getenv("MYSQL_PORT"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )
        cursor = conn.cursor()

        sql = """
        INSERT INTO user_tbl (
            user_Name, user_role, user_password, user_birthday,
            user_profilePic, user_email, user_phone,
            user_Height, user_weight, user_diet, user_gender, house_Id
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        values = (
            user_Name,
            user_role,
            user_password,
            user_birthday,
            user_profilePic,
            user_email,
            user_phone,
            user_Height,
            user_weight,
            user_diet,
            user_gender,
            house_Id
        )

        cursor.execute(sql, values)
        conn.commit()
        cursor.close()
        conn.close()
        return True

    except Exception as e:
        print("Error inserting user:", e)
        return False


########## select user ##################


def selectUser(query: str = "",id:int = 0) -> list:
    data = []
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=os.getenv("MYSQL_PORT"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )

        cursor = conn.cursor(dictionary=True)

        if query != "":
            cursor.execute(query)
        elif id!=0:
            cursor.execute("SELECT * FROM user_tbl where user_Id = %s",(id,))
        else:
            cursor.execute("SELECT * FROM user_tbl")


        data = cursor.fetchall()
        cursor.close()
        conn.close()
        return data

    except Exception as e:
        print("Error fetching user data:", e)
        return []

######### insert notification   #################

def insert_notification(title: str, body: str, user_id: int, is_read: bool = False) -> bool:
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=os.getenv("MYSQL_PORT"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )
        cursor = conn.cursor()

        current_time = datetime.now().time().strftime('%H:%M:%S')  # 'HH:MM:SS'

        query = """
        INSERT INTO notification_tbl (not_title, not_body, not_isRead, not_timeStamp, user_Id)
        VALUES (%s, %s, %s, %s, %s)
        """
        values = (title, body, is_read, current_time, user_id)

        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print("Error inserting notification:", e)
        return False


################## select notification ######
def selectNotifications(query: str = "", id:int = 0) -> list:
    data = []
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=os.getenv("MYSQL_PORT"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )
        cursor = conn.cursor()

        if query != "":
            cursor.execute(query)
        elif id!=0:
            cursor.execute("SELECT * FROM task_tbl where user_Id = %s",(id,))
        else:
            cursor.execute("SELECT * FROM  notification_tbl")


        data = cursor.fetchall()
        cursor.close()
        conn.close()
        return data

    except Exception as e:
        print("Error fetching notifications:", e)
        return []





########### insert task #############
def insert_task(title: str, description: str, status: str, deadline: str, assigner_id: int, assigned_to_id: int) -> bool:
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=os.getenv("MYSQL_PORT"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )
        cursor = conn.cursor()

        query = """
        INSERT INTO task_tbl (task_title, task_description, task_status, task_deadline, assigner_Id, assignedTo_Id)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        values = (title, description, status, deadline, assigner_id, assigned_to_id)
        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print("Error inserting task:", e)
        return False




######### select task #########
def selectTasks(query: str = "",id: int = 0) -> list:
    data = []
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=os.getenv("MYSQL_PORT"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )
        cursor = conn.cursor()

        if query != "":
            cursor.execute(query)
        elif id!=0:
            cursor.execute("SELECT * FROM task_tbl where assignedTo_Id = %s",(id,))
        else:
            cursor.execute("SELECT * FROM task_tbl")


        data = cursor.fetchall()
        cursor.close()
        conn.close()
        return data

    except Exception as e:
        print("Error fetching tasks:", e)
        return []

############# insert allergy #############
def insertAllergy(allergy_name: str, user_Id: int) -> bool:
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=os.getenv("MYSQL_PORT"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )

        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO allergy_tbl (allergy_name, user_Id)
            VALUES (%s, %s)
        """, (allergy_name, user_Id))

        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print("Error inserting allergy:", e)
        return False

################# select allergy #####################
def selectAllergy(query: str = "",id: int = 0) -> list:
    data = []
    try:
        conn = mysql.connector.connect(
            host=os.getenv("MYSQL_HOST"),
            port=os.getenv("MYSQL_PORT"),
            user=os.getenv("MYSQL_USER"),
            password=os.getenv("MYSQL_PASSWORD"),
            database=os.getenv("MYSQL_DATABASE")
        )

        cursor = conn.cursor(dictionary=True)

        if query != "":
            cursor.execute(query)
            print("entered")
        elif not id == 0:
            cursor.execute("SELECT * FROM allergy_tbl where user_Id = %s", (id,))
        else:
            cursor.execute("SELECT * FROM allergy_tbl")

        data = cursor.fetchall()
        cursor.close()
        conn.close()
        return data

    except Exception as e:
        print("Error fetching allergy data:", e)
        return []





if __name__ == '__main__':
    #print(insertUser("hana","AppAdminstrator","1234","2003-06-24","sss","hanabassem@gmail.com","01111111",'169',"60","vegan","female","2"))
    #print(selectUser("select * from user_tbl where user_Id = 2"))
    #print(insert_task("end","total end","done","2025-07-01","1","2"))
    #print(selectTasks(id=2))
    print(insertAllergy("chocolate","2"))
    print(selectAllergy(id = 1))
    #print(selectNotifications())
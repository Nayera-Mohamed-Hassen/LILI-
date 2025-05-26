from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.mySQLConnection import insertUser, selectUser, insertAllergy, insertHouseHold, executeWriteQuery



router = APIRouter(prefix="/user", tags=["User"])

class HouseHold(BaseModel):
    name: str
    pic: str
    address: str
    email: str 


class UserLogin(BaseModel):
    email: str
    password: str

class UserSignup(BaseModel):
    name: str
    password: str
    birthday: str
    email: str
    phone: str
    profile_pic: str = ""
    height: float = None
    weight: float = None
    diet: str = "vegan"
    gender: str = "female"
    house_id: int = 1
    allergy: str = ""

@router.post("/signup")
def signup(user: UserSignup):
    # Insert user into the database
    success = insertUser(
        user_Name=user.name,
        user_password=user.password,
        user_birthday=user.birthday,
        user_email=user.email,
        user_phone=user.phone,
        user_profilePic=user.profile_pic,
        user_Height=user.height,
        user_weight=user.weight,
        user_diet=user.diet,
        user_gender=user.gender,
        house_Id=user.house_id
    )

    if not success:
        raise HTTPException(status_code=500, detail="Signup failed")

    # Retrieve user ID based on email
    print(user.email)
    # Assuming selectUser is a function that retrieves user ID based on email
    # Adjust the query to use parameterized queries to prevent SQL injection
    result = selectUser(
        'SELECT user_Id FROM user_tbl WHERE user_email = "' + user.email +'"' # use values or your function's correct arg
    )
    user_id = result[0]["user_Id"]

    if user_id is None:
        raise HTTPException(status_code=500, detail="Failed to retrieve user ID")

    # Insert allergies
    allergies = user.allergy.split(",") if user.allergy else []
    for a in allergies:
        if a.strip():
            insertAllergy(allergy_name=a.strip(), user_Id=user_id)

    return {"message": "User signed up successfully"}



@router.post("/login")
async def login(user: UserLogin):
    try:
        query = 'SELECT * FROM user_tbl WHERE user_email = "'+user.email + '"AND user_password = "'+ user.password + '"'
        result = selectUser(query=query)

        if result:
            return {"status": "success", "user_id": result[0]["user_Id"]}
        else:
            raise HTTPException(status_code=401, detail="Invalid email or password")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/household/create")
async def create_household(data: HouseHold):
    
    # 1. Insert the household
    success = insertHouseHold(data.name, data.pic, data.address)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to create household")

    # 2. Get household id by name (if insertHouseHold doesn't return it)
    house_result = selectUser(query=f'SELECT house_Id FROM household_tbl WHERE house_Name = "{data.name}"')

    if not house_result:
        raise HTTPException(status_code=404, detail="Household not found")

    house_id = house_result[0]["house_Id"]
    print(f"Household ID: {house_id}")

    # 3. Update the user's house_id
    update_query = f'UPDATE user_tbl SET house_Id = {house_id} WHERE user_email = "{data.email}"'

    print(f"Update Query: {update_query}")
    executeWriteQuery(query=update_query)  # run update using existing query function

    return {"message": "Household created", "house_id": house_id}

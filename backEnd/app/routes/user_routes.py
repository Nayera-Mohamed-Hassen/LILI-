from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.mySQLConnection import insertUser, insertAllergy, selectUser

router = APIRouter(prefix="/user", tags=["User"])

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

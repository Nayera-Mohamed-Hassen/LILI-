from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.mySQLConnection import insertUser  # import your db function

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

@router.post("/signup")
def signup(user: UserSignup):
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
    return {"message": "User signed up successfully"}

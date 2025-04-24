from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()
users = []

class User(BaseModel):
    name: str

@app.post("/dijkstra/users/")
async def create_user(user: User):
    user_dict = user.dict()
    user_dict["id"] = len(users)
    users.append(user_dict)
    return user_dict

@app.get("/dijkstra/users/")
async def read_users():
    return users

@app.get("/dijkstra/users/{user_id}")
async def read_user(user_id: int):
    return users[user_id] if user_id < len(users) else {"error": "User not found"}

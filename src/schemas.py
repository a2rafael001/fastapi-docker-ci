from pydantic import BaseModel, ConfigDict

class UserCreate(BaseModel):
    name: str


class User(BaseModel):
    id: int
    name: str

    class ConfigDict:
        from_attributes = True

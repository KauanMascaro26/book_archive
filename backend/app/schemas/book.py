from pydantic import BaseModel


class BookCreate(BaseModel):
    code: str
    title: str
    author: str


class BookResponse(BaseModel):
    id: int
    code: str
    title: str
    author: str
    available: bool

    class Config:
        from_attributes = True
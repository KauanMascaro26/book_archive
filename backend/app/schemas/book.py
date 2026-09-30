from pydantic import BaseModel


class BookCreate(BaseModel):
    code: str
    title: str
    author: str
    publisher: str | None = None
    year: int | None = None
    category: str | None = None
    description: str | None = None


class BookResponse(BaseModel):
    id: int
    code: str
    title: str
    author: str
    publisher: str | None = None
    year: int | None = None
    category: str | None = None
    description: str | None = None
    available: bool

    class Config:
        from_attributes = True
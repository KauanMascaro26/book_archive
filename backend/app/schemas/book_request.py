from datetime import datetime

from pydantic import BaseModel, ConfigDict


class BookRequestCreate(BaseModel):
    book_id: int


class BookRequestResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    book_id: int
    status: str
    requested_at: datetime


class PendingBookRequestResponse(BaseModel):
    id: int
    user_id: int
    user_name: str
    user_email: str
    book_id: int
    book_title: str
    book_code: str
    status: str
    requested_at: datetime

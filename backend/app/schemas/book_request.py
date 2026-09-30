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

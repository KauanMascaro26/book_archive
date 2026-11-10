
from datetime import datetime

from pydantic import BaseModel, ConfigDict


class MyLoanResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    book_id: int
    book_title: str
    book_code: str
    book_author: str
    loan_date: datetime
    due_date: datetime
    return_date: datetime | None
    status: str
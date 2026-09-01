from fastapi import FastAPI

from app.database import Base, engine
from app.models import Book, BookRequest, Loan, User

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Book Archive API",
    version="1.0.0",
)


@app.get("/")
def root():
    return {
        "message": "Book Archive API",
        "status": "online",
    }
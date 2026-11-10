from fastapi import FastAPI

from app.database import Base, engine
from app.models import Book, BookRequest, Loan, User
from app.routers import books, users, auth, book_requests, loans


Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Book Archive API",
    version="1.0.0",
)

app.include_router(books.router)
app.include_router(users.router)
app.include_router(auth.router)
app.include_router(book_requests.router)
app.include_router(loans.router)

@app.get("/")
def root():
    return {
        "message": "Book Archive API",
        "status": "online",
    }

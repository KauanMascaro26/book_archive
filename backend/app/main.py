import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from app.models import Book, BookRequest, Favorite, Loan, User
from app.routers import books, users, auth, book_requests, loans, favorites


Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Book Archive API",
    version="1.0.0",
)

allowed_origins = [
    origin.strip()
    for origin in os.getenv(
        "CORS_ORIGINS",
        "http://localhost:3000,http://localhost:5000,http://127.0.0.1:3000",
    ).split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(books.router)
app.include_router(users.router)
app.include_router(auth.router)
app.include_router(book_requests.router)
app.include_router(loans.router)
app.include_router(favorites.router)


@app.get("/")
def root():
    return {
        "message": "Book Archive API",
        "status": "online",
    }

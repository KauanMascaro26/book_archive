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

app.add_middleware(
    CORSMiddleware,
        allow_origin_regex=r"^https?://(localhost|127[.]0[.]0[.]1)(:[0-9]+)?$",
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

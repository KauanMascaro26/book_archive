from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.book import Book
from app.schemas.book import BookCreate, BookResponse

router = APIRouter(
    prefix="/books",
    tags=["Books"],
)


@router.post("/", response_model=BookResponse)
def create_book(book: BookCreate, db: Session = Depends(get_db)):
    existing_book = db.query(Book).filter(Book.code == book.code).first()

    if existing_book:
        raise HTTPException(
            status_code=400,
            detail="Book code already exists",
        )

    new_book = Book(
        code=book.code,
        title=book.title,
        author=book.author,
    )

    db.add(new_book)
    db.commit()
    db.refresh(new_book)

    return new_book


@router.get("/", response_model=list[BookResponse])
def get_books(db: Session = Depends(get_db)):
    return db.query(Book).all()


@router.get("/{book_id}", response_model=BookResponse)
def get_book(book_id: int, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()

    if not book:
        raise HTTPException(
            status_code=404,
            detail="Book not found",
        )

    return book


@router.put("/{book_id}", response_model=BookResponse)
def update_book(
    book_id: int,
    book_data: BookCreate,
    db: Session = Depends(get_db),
):
    book = db.query(Book).filter(Book.id == book_id).first()

    if not book:
        raise HTTPException(
            status_code=404,
            detail="Book not found",
        )

    existing_book = (
        db.query(Book)
        .filter(Book.code == book_data.code, Book.id != book_id)
        .first()
    )

    if existing_book:
        raise HTTPException(
            status_code=400,
            detail="Book code already exists",
        )

    book.code = book_data.code
    book.title = book_data.title
    book.author = book_data.author

    db.commit()
    db.refresh(book)

    return book


@router.delete("/{book_id}")
def delete_book(book_id: int, db: Session = Depends(get_db)):
    book = db.query(Book).filter(Book.id == book_id).first()

    if not book:
        raise HTTPException(
            status_code=404,
            detail="Book not found",
        )

    db.delete(book)
    db.commit()

    return {
        "message": "Book deleted successfully"
    }
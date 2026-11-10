from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from app.database import get_db
from app.models.book import Book
from app.models.loan import Loan
from app.models.request import BookRequest
from app.schemas.book import BookCreate, BookResponse
from app.core.dependencies import require_admin
from app.models.user import User

router = APIRouter(
    prefix="/books",
    tags=["Books"],
)


@router.post("/", response_model=BookResponse)
def create_book(
    book: BookCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
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
        publisher=book.publisher,
        year=book.year,
        category=book.category,
        description=book.description,
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
    current_user: User = Depends(require_admin),
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
    book.publisher = book_data.publisher
    book.year = book_data.year
    book.category = book_data.category
    book.description = book_data.description

    db.commit()
    db.refresh(book)

    return book


@router.delete("/{book_id}")
def delete_book(
    book_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    book = db.query(Book).filter(Book.id == book_id).first()

    if not book:
        raise HTTPException(
            status_code=404,
            detail="Book not found",
        )

    linked_requests = (
        db.query(BookRequest)
        .filter(BookRequest.book_id == book_id)
        .count()
    )
    linked_loans = (
        db.query(Loan)
        .filter(Loan.book_id == book_id)
        .count()
    )

    if linked_requests or linked_loans:
        raise HTTPException(
            status_code=409,
            detail=(
                "Este livro possui histórico de solicitações ou empréstimos "
                "e não pode ser excluído para preservar os registros da biblioteca."
            ),
        )

    try:
        db.delete(book)
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail=(
                "Não foi possível excluir este livro porque existem registros "
                "vinculados a ele."
            ),
        )

    return {
        "message": "Book deleted successfully"
    }
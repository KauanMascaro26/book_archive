from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user, require_admin
from app.database import get_db
from app.models.book import Book
from app.models.loan import Loan
from app.models.request import BookRequest
from app.models.user import User
from app.schemas.book_request import (
    BookRequestApproval,
    BookRequestCreate,
    BookRequestResponse,
    PendingBookRequestResponse,
)

router = APIRouter(
    prefix="/book-requests",
    tags=["Book Requests"],
)


@router.post(
    "/",
    response_model=BookRequestResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_book_request(
    request_data: BookRequestCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    book = db.query(Book).filter(Book.id == request_data.book_id).first()

    if book is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Book not found",
        )

    if not book.available:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Book is not available",
        )

    pending_request = (
        db.query(BookRequest)
        .filter(
            BookRequest.user_id == current_user.id,
            BookRequest.book_id == book.id,
            BookRequest.status == "PENDING",
        )
        .first()
    )

    if pending_request is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="You already have a pending request for this book",
        )

    book_request = BookRequest(
        user_id=current_user.id,
        book_id=book.id,
        status="PENDING",
    )

    db.add(book_request)
    db.commit()
    db.refresh(book_request)

    return book_request


@router.get(
    "/pending",
    response_model=list[PendingBookRequestResponse],
)
def get_pending_book_requests(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    requests = (
        db.query(BookRequest, User, Book)
        .join(User, BookRequest.user_id == User.id)
        .join(Book, BookRequest.book_id == Book.id)
        .filter(BookRequest.status == "PENDING")
        .order_by(BookRequest.requested_at.asc())
        .all()
    )

    return [
        {
            "id": book_request.id,
            "user_id": user.id,
            "user_name": user.name,
            "user_email": user.email,
            "book_id": book.id,
            "book_title": book.title,
            "book_code": book.code,
            "status": book_request.status,
            "requested_at": book_request.requested_at,
        }
        for book_request, user, book in requests
    ]


@router.patch("/{request_id}/approve")
def approve_book_request(
    request_id: int,
    approval_data: BookRequestApproval,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    book_request = (
        db.query(BookRequest)
        .filter(BookRequest.id == request_id)
        .first()
    )

    if book_request is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Book request not found",
        )

    if book_request.status != "PENDING":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Only pending requests can be approved",
        )

    book = db.query(Book).filter(Book.id == book_request.book_id).first()

    if book is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Book not found",
        )

    if not book.available:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Book is not available",
        )

    loan_date = datetime.utcnow()
    if approval_data.due_date.replace(tzinfo=None) <= loan_date:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Due date must be in the future",
        )

    loan = Loan(
        request_id=book_request.id,
        user_id=book_request.user_id,
        book_id=book_request.book_id,
        loan_date=loan_date,
        due_date=approval_data.due_date.replace(tzinfo=None),
        status="ACTIVE",
    )

    book_request.status = "APPROVED"
    book.available = False
    db.add(loan)
    db.commit()
    db.refresh(loan)

    return {
        "message": "Book request approved successfully",
        "request_id": book_request.id,
        "request_status": book_request.status,
        "loan_id": loan.id,
        "book_id": book.id,
        "book_available": book.available,
        "loan_date": loan.loan_date,
        "due_date": loan.due_date,
    }


@router.patch("/{request_id}/reject")
def reject_book_request(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    book_request = (
        db.query(BookRequest)
        .filter(BookRequest.id == request_id)
        .first()
    )

    if book_request is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Book request not found",
        )

    if book_request.status != "PENDING":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Only pending requests can be rejected",
        )

    book_request.status = "REJECTED"
    db.commit()
    db.refresh(book_request)

    return {
        "message": "Book request rejected successfully",
        "request_id": book_request.id,
        "status": book_request.status,
    }

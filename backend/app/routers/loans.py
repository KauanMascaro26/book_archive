
from datetime import datetime

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user, require_admin
from app.database import get_db
from app.models.book import Book
from app.models.loan import Loan
from app.models.user import User
from app.schemas.loan import MyLoanResponse

router = APIRouter(
    prefix="/loans",
    tags=["Loans"],
)


@router.get("/my-loans", response_model=list[MyLoanResponse])
def get_my_loans(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    loans = (
        db.query(Loan, Book)
        .join(Book, Loan.book_id == Book.id)
        .filter(Loan.user_id == current_user.id)
        .order_by(Loan.loan_date.desc())
        .all()
    )

    return [
        {
            "id": loan.id,
            "book_id": book.id,
            "book_title": book.title,
            "book_code": book.code,
            "book_author": book.author,
            "loan_date": loan.loan_date,
            "due_date": loan.due_date,
            "return_date": loan.return_date,
            "status": loan.status,
        }
        for loan, book in loans
    ]


@router.get("/admin")
def get_all_loans(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    loans = (
        db.query(Loan, Book, User)
        .join(Book, Loan.book_id == Book.id)
        .join(User, Loan.user_id == User.id)
        .order_by(Loan.loan_date.desc())
        .all()
    )

    results = []
    now = datetime.utcnow()

    for loan, book, user in loans:
        status = loan.status
        if status == "ACTIVE" and loan.due_date < now:
            status = "OVERDUE"

        results.append({
            "id": loan.id,
            "book_id": book.id,
            "book_title": book.title,
            "book_code": book.code,
            "book_author": book.author,
            "user_id": user.id,
            "user_name": user.name,
            "user_email": user.email,
            "loan_date": loan.loan_date,
            "due_date": loan.due_date,
            "return_date": loan.return_date,
            "status": status,
        })

    return results

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user
from app.database import get_db
from app.models.book import Book
from app.models.favorite import Favorite
from app.models.user import User
from app.schemas.book import BookResponse

router = APIRouter(prefix="/favorites", tags=["Favorites"])


@router.get("/", response_model=list[BookResponse])
def get_favorites(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return (
        db.query(Book)
        .join(Favorite, Favorite.book_id == Book.id)
        .filter(Favorite.user_id == current_user.id)
        .order_by(Favorite.id.desc())
        .all()
    )


@router.post("/{book_id}", status_code=status.HTTP_201_CREATED)
def add_favorite(
    book_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    book = db.query(Book).filter(Book.id == book_id).first()
    if book is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Book not found",
        )

    existing = (
        db.query(Favorite)
        .filter(
            Favorite.user_id == current_user.id,
            Favorite.book_id == book_id,
        )
        .first()
    )
    if existing is not None:
        return {"message": "Book is already in favorites"}

    db.add(Favorite(user_id=current_user.id, book_id=book_id))
    db.commit()
    return {"message": "Book added to favorites"}


@router.delete("/{book_id}")
def remove_favorite(
    book_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    favorite = (
        db.query(Favorite)
        .filter(
            Favorite.user_id == current_user.id,
            Favorite.book_id == book_id,
        )
        .first()
    )
    if favorite is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Favorite not found",
        )

    db.delete(favorite)
    db.commit()
    return {"message": "Book removed from favorites"}

from fastapi import FastAPI

app = FastAPI(
    title="Book Archive API",
    description="API for managing the Book Archive system",
    version="1.0.0"
)


@app.get("/")
def root():
    return {
        "message": "Book Archive API is running!"
    }
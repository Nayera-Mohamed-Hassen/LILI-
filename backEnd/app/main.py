from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routes import user_routes, transaction_routes  # Add transaction_routes import

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(user_routes.router)
app.include_router(transaction_routes.router)  # Add transaction routes

@app.get("/")
async def root():
    return {"message": "Welcome to LILI API"}

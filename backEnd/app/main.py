from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routes import user_routes, transaction_routes, notification_routes, ocr_routes, calendar_routes, emergency_routes  # Add emergency_routes import
from fastapi.exception_handlers import RequestValidationError
from fastapi.requests import Request
from fastapi.responses import JSONResponse
from .notification_jobs import start_scheduler

app = FastAPI()
start_scheduler()

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
app.include_router(notification_routes.router)  # Add notification routes
app.include_router(ocr_routes.router)  # Add OCR routes
app.include_router(calendar_routes.router)  # Add calendar routes
app.include_router(emergency_routes.router)  # Add emergency routes

@app.get("/")
async def root():
    return {"message": "Welcome to LILI API"}

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    print("Validation error:", exc.errors())
    print("Request body:", await request.body())
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors(), "body": exc.body},
    )

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import user_routes  # Import your route files

app = FastAPI()

# Allow Flutter app to call API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict this to your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all routers
app.include_router(user_routes.router)

@app.get("/")
def root():
    return {"message": "LILI backend is running"}

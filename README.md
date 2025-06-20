# LILI

## Overview
LILI is a smart home management platform with a Flutter frontend and a FastAPI backend. The backend now uses MongoDB (not MySQL) for all data storage. User IDs are handled as strings throughout the system.

## Backend (FastAPI + MongoDB)
- All data is stored in MongoDB.
- User, household, inventory, task, and notification collections use the same names as the old MySQL tables.
- User IDs and household IDs are always strings.

### Setup
1. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
2. **Set up environment variables:**
   - Create a `.env` file in `backEnd/app/` with:
     ```env
     MONGO_URI=your_mongodb_connection_string
     EMAIL_USER=your_gmail_address
     EMAIL_APP_PASSWORD=your_gmail_app_password
     ```
3. **Run the backend:**
   ```bash
   cd backEnd
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```

## Frontend (Flutter)
- All API calls use string user IDs.
- Make sure to run the backend before starting the app.

### Setup
1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```
2. **Run the app:**
   ```bash
   flutter run
   ```

## Notes
- The backend and frontend communicate via HTTP (default: `http://10.0.2.2:8000` for Android emulator).
- All endpoints requiring user or household IDs expect them as strings.
- If you encounter errors, check that your environment variables are set and MongoDB is running.
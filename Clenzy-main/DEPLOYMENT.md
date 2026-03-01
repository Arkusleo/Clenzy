# Clenzy Deployment Guide

This document outlines the professional deployment strategy for the Clenzy Smart Home Services platform. 
The system consists of a FastAPI backend and a Flutter web/mobile frontend.

## 1. Backend Deployment (Railway & Docker)

The backend (`backend/functions`) uses FastAPI, PostgreSQL, and is containerized using Docker. Railway is recommended for an automated, professional deployment.

### A. Railway Automation
Railway automatically detects the `Dockerfile` and `Procfile` present in `backend/functions`.
1. Make sure your repository is pushed to GitHub.
2. Go to [Railway](https://railway.app/), create a **New Project** > **Deploy from GitHub repo**.
3. Select your repository.
4. Railway will analyze the root. You need to configure it to deploy the `backend/functions` directory.
   - Go to Settings > Build > **Root Directory** and set it to `/backend/functions`.
   - Ensure the Start Command uses `uvicorn main:app --host 0.0.0.0 --port $PORT` (this is automatically picked up via the `Procfile` we updated).
5. **Add PostgreSQL**:
   - In Railway, click **New** > **Database** > **Add PostgreSQL**.
   - Copy the `DATABASE_URL` (usually starts with `postgresql://`).
6. **Set Environment Variables**:
   - Go to the Backend App > Variables.
   - Add `DATABASE_URL` (paste the URL you got from the PostgreSQL service).
   - Add `JWT_SECRET_KEY` (generate a random string, e.g., using `openssl rand -hex 32`).
   - Add `ALGORITHM` = `HS256`.
7. Once variables are set, Railway will automatically rebuild and deploy your backend.

### B. Traditional VPS Deployment (AWS EC2 / DigitalOcean)
If you prefer a VPS, use Docker Compose. An example `docker-compose.yml` can be set up in the root:
```yaml
version: '3.8'
services:
  web:
    build: backend/functions
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/clenzy
      - JWT_SECRET_KEY=yoursecret
    depends_on:
      - db
  db:
      image: postgres:15
      environment:
        - POSTGRES_USER=user
        - POSTGRES_PASSWORD=password
        - POSTGRES_DB=clenzy
      ports:
        - "5432:5432"
      volumes:
        - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```

## 2. Frontend Deployment (Vercel or Firebase Hosting)

The frontend is built with Flutter and deployed as a Web app.

### A. Update API Endpoints
Before deploying, change the `baseUrl` in `lib/services/job_service_client.dart` and any other service file from `http://127.0.0.1:8000/api` to your live Railway backend URL (e.g., `https://clenzy-backend-production.up.railway.app/api`).

Change the WebSocket URL from `ws://127.0.0.1:8000/api/ws/jobs` to `wss://clenzy-backend-production.up.railway.app/api/ws/jobs`.

### B. Build for Web
Run the following command in the `frontend/` directory to build the production-ready web files:
```bash
flutter build web --release
```
This generates the optimized files in `frontend/build/web`.

### C. Deploy to Firebase Hosting (Recommended for Flutter Web)
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize Firebase in the `frontend` folder: `firebase init hosting`
   - Select your Firebase project.
   - Set the public directory to `build/web`.
   - Configure as a single-page app (Rewrite all urls to index.html): `Yes`.
   - Don't overwrite `index.html`.
4. Deploy: `firebase deploy`

### D. Deploy to Vercel
1. Install Vercel CLI: `npm i -g vercel`
2. Navigate to `frontend/build/web`.
3. Run `vercel` and follow the prompts.

## 3. Production Readiness Checklist

✅ **Security:**
- CORS is configured properly in `main.py` (`allow_origins=["*"]` during dev, change to your specific frontend domain in prod).
- JWT Authentication is implemented for sensitive routes.
- Passwords are encrypted using `bcrypt`.

✅ **Database:**
- `app/database.py` handles connection pooling. Always use the PostgreSQL URI in production.

✅ **Real-time Updates:**
- WebSockets securely communicate state changes across users. Ensure your production environment supports WebSocket connections (Railway supports this out of the box).

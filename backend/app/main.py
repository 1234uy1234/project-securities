from fastapi import FastAPI, HTTPException, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os
from .config import settings
from .database import engine, Base, SessionLocal
from .models import User, UserRole
from .auth import get_password_hash
from .routes import auth, users, patrol_tasks, patrol_records, locations, stats, qr_codes, checkin, face_auth, face_storage, reports, test_tasks, test_qr, push, notifications

# Database tables will be created on startup

app = FastAPI(
    title="MANHTOAN PLASTIC - Hệ thống Tuần tra",
    description="Hệ thống tuần tra thông minh sử dụng mã QR và GPS",
    version="1.0.0"
)

# CORS middleware - read allowed origins from settings
cors_origins = getattr(settings, 'allowed_origins', [])
print(f"🔧 CORS Settings: {cors_origins}")
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for uploads - moved after custom endpoints
app.mount("/uploads", StaticFiles(directory=settings.upload_dir), name="uploads")

# Create API router with prefix
api_router = APIRouter(prefix="/api")

# Include routers under API prefix
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(patrol_tasks.router)
api_router.include_router(patrol_records.router)
api_router.include_router(locations.router)
api_router.include_router(stats.router)
api_router.include_router(qr_codes.router)
api_router.include_router(checkin.router)
api_router.include_router(face_auth.router)
api_router.include_router(face_storage.router)
api_router.include_router(reports.router)

# Include the main API router
app.include_router(api_router)

# Include test router
app.include_router(test_tasks.router)
app.include_router(test_qr.router)

# Include push notification router
app.include_router(push.router, prefix="/api/push", tags=["push-notifications"])

# Include notification router
app.include_router(notifications.router, prefix="/api/notifications", tags=["notifications"])

@app.get("/")
async def root():
    return {
        "message": "MANHTOAN PLASTIC - Hệ thống Tuần tra API",
        "version": "1.0.0",
        "docs": "/docs"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/test-db")
async def test_db():
    try:
        db = SessionLocal()
        user = db.query(User).filter(User.username == "admin").first()
        db.close()
        if user:
            return {"status": "success", "user": user.username, "role": user.role}
        else:
            return {"status": "error", "message": "Admin user not found"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

# Serve uploaded files
@app.get("/uploads/{file_path:path}")
async def serve_upload(file_path: str):
    file_location = os.path.join(settings.upload_dir, file_path)
    if os.path.exists(file_location):
        return FileResponse(file_location)
    else:
        raise HTTPException(status_code=404, detail="File not found")

if __name__ == "__main__":
    import uvicorn
    import os
    # BẮT BUỘC chạy HTTPS port 8000 với mkcert certificate
    key_path = "localhost+3-key.pem"
    cert_path = "localhost+3.pem"
    print(f"🔐 SSL Key: {key_path}")
    print(f"🔐 SSL Cert: {cert_path}")
    print(f"🔐 Key exists: {os.path.exists(key_path)}")
    print(f"🔐 Cert exists: {os.path.exists(cert_path)}")
    
    # BẮT BUỘC chạy HTTPS - KHÔNG FALLBACK HTTP
    print("🔐 BẮT BUỘC Starting HTTPS server with mkcert...")
    uvicorn.run(app, host="0.0.0.0", port=8000, ssl_keyfile=key_path, ssl_certfile=cert_path)

# Bootstrap admin on startup if none exists
# Comment out startup event for now
# @app.on_event("startup")
# async def startup_event():
#     try:
#         # Create database tables
#         Base.metadata.create_all(bind=engine)
#         print("Database tables created successfully")
#         
#         # Bootstrap admin user
#         db = SessionLocal()
#         try:
#             existing = db.query(User).filter(User.username == "admin").first()
#             if not existing:
#                 admin = User(
#                     username="admin",
#                     email="admin@manhtoan.com",
#                     password_hash=get_password_hash("admin123"),
#                     role=UserRole.ADMIN,
#                     full_name="Administrator",
#                     phone="0123456789",
#                     is_active=True,
#                 )
#                 db.add(admin)
#                 db.commit()
#                 print("Admin user created successfully")
#             else:
#                 print("Admin user already exists")
#         except Exception as e:
#             print(f"Error creating admin user: {e}")
#         finally:
#             db.close()
#     except Exception as e:
#         print(f"Error during startup: {e}")
#         print("Continuing to run despite database errors...")

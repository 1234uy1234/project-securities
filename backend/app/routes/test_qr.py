from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from ..database import get_db

router = APIRouter(prefix="/test-qr", tags=["test qr"])

@router.get("/")
async def test_qr_codes(db: Session = Depends(get_db)):
    """Test QR codes với raw SQL"""
    try:
        result = db.execute(text("SELECT id, content, qr_type FROM qr_codes LIMIT 5"))
        rows = result.fetchall()
        return {
            "success": True,
            "data": [{"id": row[0], "content": row[1], "qr_type": row[2]} for row in rows]
        }
    except Exception as e:
        return {"success": False, "error": str(e)}

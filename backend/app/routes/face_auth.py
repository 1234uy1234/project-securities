from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
import base64
import json

from ..database import get_db
from ..models import User, UserFaceData
from ..services.simple_face_service import SimpleFaceService
from ..auth import get_current_user, get_current_user_optional, require_manager_or_admin
# from ..schemas import UserResponse  # Không cần thiết

router = APIRouter(prefix="/face-auth", tags=["Face Authentication"])

face_service = SimpleFaceService()

@router.get("/status")
async def get_face_auth_status(
    current_user: User = Depends(get_current_user_optional),
    db: Session = Depends(get_db)
):
    """
    Kiểm tra trạng thái face auth cho user hiện tại
    """
    try:
        if not current_user:
            return {
                "has_face_data": False,
                "message": "Chưa đăng nhập"
            }
        
        # Kiểm tra xem user có face data không
        face_data = db.query(UserFaceData).filter(UserFaceData.user_id == current_user.id).first()
        
        if face_data:
            return {
                "has_face_data": True,
                "registered_at": face_data.created_at.isoformat() if face_data.created_at else None,
                "message": "Đã đăng ký khuôn mặt"
            }
        else:
            return {
                "has_face_data": False,
                "message": "Chưa đăng ký khuôn mặt"
            }
            
    except Exception as e:
        print(f"Error checking face auth status: {e}")
        return {
            "has_face_data": False,
            "message": "Lỗi kiểm tra trạng thái"
        }

@router.post("/register")
async def register_face(
    image_data: str = Form(...),  # Base64 encoded image
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Đăng ký khuôn mặt cho user hiện tại
    """
    try:
        # Chuyển đổi base64 thành OpenCV image
        image = face_service.image_from_base64(image_data)
        if image is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Không thể xử lý ảnh. Vui lòng kiểm tra định dạng base64."
            )
        
        # Kiểm tra xem user đã có khuôn mặt chưa
        existing_face = db.query(UserFaceData).filter(UserFaceData.user_id == current_user.id).first()
        if existing_face:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Tài khoản này đã có khuôn mặt được đăng ký. Vui lòng xóa khuôn mặt cũ trước khi đăng ký mới."
            )
        
        # Xử lý đăng ký khuôn mặt
        result = face_service.process_face_registration(image, current_user.id)
        
        if not result["success"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=result["message"]
            )
        
        # Kiểm tra xem khuôn mặt này đã được đăng ký cho tài khoản khác chưa
        # Lấy tất cả face encodings đã có
        all_face_data = db.query(UserFaceData).filter(UserFaceData.is_active == True).all()
        
        if all_face_data:
            # Chuyển đổi binary data thành face encodings
            known_encodings = []
            user_ids = []
            
            for face_data in all_face_data:
                try:
                    encoding = face_service.decode_face_from_binary(face_data.face_encoding)
                    known_encodings.append(encoding)
                    user_ids.append(face_data.user_id)
                except Exception as e:
                    print(f"Error decoding face data for user {face_data.user_id}: {e}")
                    continue
            
            if known_encodings:
                # So sánh với khuôn mặt mới
                new_encoding = face_service.decode_face_from_binary(result["face_encoding"])
                
                for i, known_encoding in enumerate(known_encodings):
                    if face_service.compare_faces(known_encoding, new_encoding, threshold=0.15):
                        # Tìm user đã có khuôn mặt này
                        existing_user = db.query(User).filter(User.id == user_ids[i]).first()
                        if existing_user:
                            raise HTTPException(
                                status_code=status.HTTP_400_BAD_REQUEST,
                                detail=f"Khuôn mặt này đã được đăng ký cho tài khoản '{existing_user.username}' (ID: {existing_user.id}). Mỗi khuôn mặt chỉ có thể đăng ký cho 1 tài khoản."
                            )
        
        # Lưu vào database
        
        # Tạo dữ liệu mới
        face_data = UserFaceData(
            user_id=current_user.id,
            face_encoding=result["face_encoding"],
            face_image_path=result["image_path"],
            is_active=True
        )
        
        db.add(face_data)
        db.commit()
        db.refresh(face_data)
        
        # Tạo token cho user sau khi đăng ký thành công
        from ..auth import create_access_token
        access_token = create_access_token(data={"sub": current_user.username})
        
        return {
            "success": True,
            "message": "Đăng ký khuôn mặt thành công",
            "face_data_id": face_data.id,
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": current_user.id,
                "username": current_user.username,
                "email": current_user.email,
                "full_name": current_user.full_name,
                "role": current_user.role,
                "is_active": current_user.is_active,
                "created_at": current_user.created_at
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

@router.post("/verify")
async def verify_face(
    image_data: str = Form(...),  # Base64 encoded image
    username: str = Form(None),  # Username để xác định tài khoản cần verify (optional)
    db: Session = Depends(get_db)
):
    """
    Xác thực khuôn mặt - nếu có username thì verify tài khoản cụ thể, 
    nếu không có username thì tìm tài khoản phù hợp
    """
    try:
        # Chuyển đổi base64 thành OpenCV image
        image = face_service.image_from_base64(image_data)
        if image is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Không thể xử lý ảnh. Vui lòng kiểm tra định dạng base64."
            )
        
        # Nếu có username, verify tài khoản cụ thể
        if username:
            user = db.query(User).filter(User.username == username).first()
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Không tìm thấy tài khoản"
                )
            
            # Lấy face data của user này
            face_data = db.query(UserFaceData).filter(
                UserFaceData.user_id == user.id,
                UserFaceData.is_active == True
            ).first()
            
            if not face_data:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Tài khoản này chưa đăng ký khuôn mặt"
                )
            
            # Chuyển đổi binary data thành face encoding
            try:
                known_encoding = face_service.decode_face_from_binary(face_data.face_encoding)
            except Exception as e:
                print(f"Error decoding face data for user {user.id}: {e}")
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Không thể đọc dữ liệu khuôn mặt"
                )
            
            # Xác thực khuôn mặt với encoding của user này
            result = face_service.process_face_verification_single(image, known_encoding, user.id)
            
            if not result["success"]:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail=result["message"]
                )
        else:
            # Không có username, tìm tài khoản phù hợp
            all_face_data = db.query(UserFaceData).filter(UserFaceData.is_active == True).all()
            
            if not all_face_data:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Chưa có tài khoản nào đăng ký khuôn mặt"
                )
            
            # So sánh với tất cả tài khoản
            best_match = None
            best_confidence = 0.0
            
            for face_data in all_face_data:
                try:
                    known_encoding = face_service.decode_face_from_binary(face_data.face_encoding)
                    result = face_service.process_face_verification_single(image, known_encoding, face_data.user_id)
                    
                    if result["success"] and result.get("confidence", 0.0) > best_confidence:
                        best_match = face_data
                        best_confidence = result.get("confidence", 0.0)
                        
                except Exception as e:
                    print(f"Error verifying face for user {face_data.user_id}: {e}")
                    continue
            
            if not best_match:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Không tìm thấy khuôn mặt phù hợp"
                )
            
            # Lấy thông tin user của khuôn mặt phù hợp nhất
            user = db.query(User).filter(User.id == best_match.user_id).first()
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Không tìm thấy tài khoản"
                )
            
            result = {"success": True, "confidence": best_confidence}
        
        print(f"FACE AUTH DEBUG: User verified - ID: {user.id}, Username: {user.username}, Full name: {user.full_name}")
        
        # Tạo access token cho face authentication
        from ..auth import create_access_token
        access_token = create_access_token(data={"sub": user.username})
        
        print(f"FACE AUTH DEBUG: Token created for user {user.username}")
        
        return {
            "success": True,
            "message": "Xác thực khuôn mặt thành công",
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "username": user.username,
                "full_name": user.full_name,
                "email": user.email,
                "phone": user.phone,
                "role": user.role,
                "is_active": user.is_active,
                "created_at": user.created_at.isoformat() if user.created_at else None,
                "updated_at": user.updated_at.isoformat() if user.updated_at else None
            },
            "confidence": result.get("confidence", 0.0)
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

@router.get("/status")
async def get_face_auth_status(
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """
    Kiểm tra trạng thái đăng ký khuôn mặt
    - Nếu có authentication: trả về thông tin của user hiện tại
    - Nếu không có authentication: trả về thông tin tổng quát
    """
    try:
        print(f"DEBUG: current_user = {current_user}")
        
        # Nếu có authentication, trả về thông tin của user hiện tại
        if current_user:
            print(f"DEBUG: User authenticated: {current_user.username} (ID: {current_user.id})")
            face_data = db.query(UserFaceData).filter(
                UserFaceData.user_id == current_user.id,
                UserFaceData.is_active == True
            ).first()
            
            if face_data:
                print(f"DEBUG: User {current_user.username} has face data")
                return {
                    "has_face_data": True,
                    "registered_at": face_data.created_at,
                    "image_path": face_data.face_image_path,
                    "user_id": current_user.id,
                    "username": current_user.username,
                    "message": f"User {current_user.username} đã đăng ký khuôn mặt"
                }
            else:
                print(f"DEBUG: User {current_user.username} has no face data")
                return {
                    "has_face_data": False,
                    "user_id": current_user.id,
                    "username": current_user.username,
                    "message": f"User {current_user.username} chưa đăng ký khuôn mặt"
                }
        
        # Nếu không có authentication, trả về thông tin tổng quát
        print("DEBUG: No authentication, returning general info")
        face_data_count = db.query(UserFaceData).filter(UserFaceData.is_active == True).count()
        
        if face_data_count > 0:
            return {
                "has_face_data": True,
                "message": f"Có {face_data_count} user đã đăng ký khuôn mặt"
            }
        else:
            return {
                "has_face_data": False,
                "message": "Chưa có user nào đăng ký khuôn mặt"
            }
            
    except Exception as e:
        print(f"DEBUG: Error in status endpoint: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

@router.get("/user-status")
async def get_user_face_auth_status(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Kiểm tra trạng thái đăng ký khuôn mặt của user hiện tại (cần authentication)
    """
    try:
        face_data = db.query(UserFaceData).filter(
            UserFaceData.user_id == current_user.id,
            UserFaceData.is_active == True
        ).first()
        
        if face_data:
            return {
                "has_face_data": True,
                "registered_at": face_data.created_at,
                "image_path": face_data.face_image_path
            }
        else:
            return {
                "has_face_data": False,
                "message": "Chưa đăng ký khuôn mặt"
            }
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

@router.post("/update")
async def update_face(
    image_data: str = Form(...),  # Base64 encoded image
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Cập nhật khuôn mặt cho user hiện tại (xóa cũ và đăng ký mới)
    """
    try:
        # Chuyển đổi base64 thành OpenCV image
        image = face_service.image_from_base64(image_data)
        if image is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Không thể xử lý ảnh. Vui lòng kiểm tra định dạng base64."
            )
        
        # Xóa dữ liệu cũ nếu có
        existing_face = db.query(UserFaceData).filter(UserFaceData.user_id == current_user.id).first()
        if existing_face:
            # Xóa file ảnh cũ
            if existing_face.face_image_path:
                import os
                try:
                    if os.path.exists(existing_face.face_image_path):
                        os.remove(existing_face.face_image_path)
                except Exception as e:
                    print(f"Error deleting old face image: {e}")
            
            # Xóa record cũ
            db.delete(existing_face)
            db.commit()
        
        # Xử lý đăng ký khuôn mặt mới
        result = face_service.process_face_registration(image, current_user.id)
        
        if not result["success"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=result["message"]
            )
        
        # Kiểm tra xem khuôn mặt này đã được đăng ký cho tài khoản khác chưa
        all_face_data = db.query(UserFaceData).filter(UserFaceData.is_active == True).all()
        
        if all_face_data:
            # Chuyển đổi binary data thành face encodings
            known_encodings = []
            user_ids = []
            
            for face_data in all_face_data:
                try:
                    encoding = face_service.decode_face_from_binary(face_data.face_encoding)
                    known_encodings.append(encoding)
                    user_ids.append(face_data.user_id)
                except Exception as e:
                    print(f"Error decoding face data for user {face_data.user_id}: {e}")
                    continue
            
            if known_encodings:
                # So sánh với khuôn mặt mới
                new_encoding = face_service.decode_face_from_binary(result["face_encoding"])
                
                for i, known_encoding in enumerate(known_encodings):
                    if face_service.compare_faces(known_encoding, new_encoding, threshold=0.15):
                        # Tìm user đã có khuôn mặt này
                        existing_user = db.query(User).filter(User.id == user_ids[i]).first()
                        if existing_user:
                            raise HTTPException(
                                status_code=status.HTTP_400_BAD_REQUEST,
                                detail=f"Khuôn mặt này đã được đăng ký cho tài khoản '{existing_user.username}' (ID: {existing_user.id}). Mỗi khuôn mặt chỉ có thể đăng ký cho 1 tài khoản."
                            )
        
        # Tạo dữ liệu mới
        face_data = UserFaceData(
            user_id=current_user.id,
            face_encoding=result["face_encoding"],
            face_image_path=result["image_path"],
            is_active=True
        )
        
        db.add(face_data)
        db.commit()
        
        return {
            "success": True,
            "message": "Cập nhật khuôn mặt thành công",
            "image_path": result["image_path"]
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

@router.delete("/unregister")
async def unregister_face(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Xóa dữ liệu khuôn mặt của user hiện tại
    """
    try:
        face_data = db.query(UserFaceData).filter(UserFaceData.user_id == current_user.id).first()
        
        if not face_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Chưa đăng ký khuôn mặt"
            )
        
        # Xóa file ảnh nếu có
        if face_data.face_image_path:
            import os
            try:
                if os.path.exists(face_data.face_image_path):
                    os.remove(face_data.face_image_path)
            except Exception as e:
                print(f"Error deleting face image: {e}")
        
        # Xóa dữ liệu từ database
        db.delete(face_data)
        db.commit()
        
        return {
            "success": True,
            "message": "Xóa dữ liệu khuôn mặt thành công"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

@router.get("/admin/stats")
async def get_face_auth_stats(
    current_user: User = Depends(require_manager_or_admin),
    db: Session = Depends(get_db)
):
    """
    Thống kê đăng ký khuôn mặt (chỉ admin/manager)
    """
    try:
        total_users = db.query(User).count()
        users_with_face_data = db.query(UserFaceData).filter(UserFaceData.is_active == True).count()
        
        return {
            "total_users": total_users,
            "users_with_face_data": users_with_face_data,
            "registration_rate": round((users_with_face_data / total_users * 100) if total_users > 0 else 0, 2)
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

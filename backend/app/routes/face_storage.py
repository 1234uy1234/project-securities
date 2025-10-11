from fastapi import APIRouter, HTTPException, status, Depends, Form, File, UploadFile
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import User, UserFaceData
from ..services.simple_face_service import SimpleFaceService
import base64
import os
import uuid
import numpy as np
import cv2
from datetime import datetime

router = APIRouter(prefix="/face-storage", tags=["Face Storage"])

face_service = SimpleFaceService()

@router.post("/test-face")
async def test_face_endpoint(
    image_data: str = Form(...),
    username: str = Form(...)
):
    """
    Test endpoint để kiểm tra face registration
    """
    try:
        print(f"🔍 TEST: Username: {username}")
        print(f"🔍 TEST: Image data length: {len(image_data)}")
        print(f"🔍 TEST: First 100 chars: {image_data[:100]}")
        
        # Test với base64 data cố định
        test_base64 = "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k="
        
        print(f"🔍 TEST: Using test base64, length: {len(test_base64)}")
        
        # Decode base64 với padding
        missing_padding = len(test_base64) % 4
        if missing_padding:
            test_base64 += '=' * (4 - missing_padding)
        
        image_bytes = base64.b64decode(test_base64)
        print(f"🔍 TEST: Image bytes length: {len(image_bytes)}")
        
        # Chuyển đổi thành numpy array
        nparr = np.frombuffer(image_bytes, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if image is None:
            return {"success": False, "message": "Không thể decode ảnh"}
        
        print(f"✅ TEST: Image decoded successfully, shape: {image.shape}")
        
        # Test face processing
        result = face_service.process_face_registration(image, 2)
        print(f"🔍 TEST: Face processing result: {result}")
        
        return {
            "success": True,
            "message": "Test thành công",
            "image_shape": image.shape,
            "username": username,
            "face_result": result
        }
        
    except Exception as e:
        print(f"❌ TEST: Error: {str(e)}")
        return {"success": False, "message": f"Lỗi: {str(e)}"}

@router.post("/test-save-face")
async def test_save_face_endpoint(
    username: str = Form(...),
    db: Session = Depends(get_db)
):
    """
    Test endpoint để kiểm tra việc lưu face encoding vào database
    """
    try:
        print(f"🔍 TEST SAVE: Username: {username}")
        
        # Tìm user
        user = db.query(User).filter(User.username == username).first()
        if not user:
            return {"success": False, "message": f"Không tìm thấy user '{username}'"}
        
        print(f"✅ TEST SAVE: Found user {username} (ID: {user.id})")
        
        # Tạo face encoding giả - thử với string thay vì bytes
        import base64
        fake_face_encoding = base64.b64encode(b"fake_face_data").decode('utf-8')
        print(f"🔍 TEST SAVE: Fake face encoding type: {type(fake_face_encoding)}")
        print(f"🔍 TEST SAVE: Fake face encoding length: {len(fake_face_encoding)}")
        
        # Test lưu vào database - thử với string thay vì bytes
        face_data = UserFaceData(
            user_id=user.id,
            face_encoding=fake_face_encoding,  # Keep as string
            face_image_path="test.jpg",
            is_active=True
        )
        
        db.add(face_data)
        db.commit()
        db.refresh(face_data)
        
        print(f"✅ TEST SAVE: Face data saved successfully (ID: {face_data.id})")
        
        return {
            "success": True,
            "message": "Test save thành công",
            "face_data_id": face_data.id,
            "username": username
        }
        
    except Exception as e:
        print(f"❌ TEST SAVE: Error: {str(e)}")
        db.rollback()
        return {"success": False, "message": f"Lỗi: {str(e)}"}

@router.post("/save-face")
async def save_face_to_database(
    image_data: str = Form(...),  # Base64 encoded image
    username: str = Form(...),    # Username để lưu ảnh
    db: Session = Depends(get_db)
):
    """
    Lưu ảnh khuôn mặt trực tiếp vào database không cần token
    """
    try:
        print(f"🔍 FACE STORAGE: Saving face for user: {username}")
        print(f"🔍 FACE STORAGE: Image data length: {len(image_data)}")
        
        # Tìm user trong database
        user = db.query(User).filter(User.username == username).first()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Không tìm thấy user '{username}'"
            )
        
        print(f"✅ FACE STORAGE: Found user {username} (ID: {user.id})")
        
        # Xử lý ảnh - đơn giản hóa
        try:
            # Loại bỏ data URL prefix nếu có
            if ',' in image_data:
                base64_data = image_data.split(',')[1]
            else:
                base64_data = image_data
            
            print(f"🔍 FACE STORAGE: Base64 data length: {len(base64_data)}")
            
            # Decode base64 với padding
            missing_padding = len(base64_data) % 4
            if missing_padding:
                base64_data += '=' * (4 - missing_padding)
            
            image_bytes = base64.b64decode(base64_data)
            print(f"🔍 FACE STORAGE: Image bytes length: {len(image_bytes)}")
            
            # Chuyển đổi thành numpy array
            nparr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if image is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Không thể decode ảnh từ dữ liệu base64"
                )
            
            print(f"✅ FACE STORAGE: Image decoded successfully, shape: {image.shape}")
            
        except Exception as e:
            print(f"❌ FACE STORAGE: Error decoding image: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Lỗi decode ảnh: {str(e)}"
            )
        
        # Tạo face encoding
        try:
            result = face_service.process_face_registration(image, user.id)
            if not result["success"]:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=result["message"]
                )
            
            print(f"🔍 FACE STORAGE: Face encoding type: {type(result['face_encoding'])}")
            print(f"🔍 FACE STORAGE: Face encoding length: {len(result['face_encoding']) if hasattr(result['face_encoding'], '__len__') else 'N/A'}")
            
        except Exception as e:
            print(f"❌ FACE STORAGE: Error processing face: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Lỗi xử lý khuôn mặt: {str(e)}"
            )
        
        # Kiểm tra xem user đã có khuôn mặt chưa
        existing_face = db.query(UserFaceData).filter(
            UserFaceData.user_id == user.id,
            UserFaceData.is_active == True
        ).first()
        
        try:
            if existing_face:
                # Cập nhật khuôn mặt cũ
                print(f"🔄 FACE STORAGE: Updating existing face for user {username}")
                existing_face.face_encoding = result["face_encoding"]
                existing_face.face_image_path = result["image_path"]
                existing_face.updated_at = datetime.utcnow()
                db.commit()
                db.refresh(existing_face)
                face_data_id = existing_face.id
            else:
                # Tạo khuôn mặt mới
                print(f"🆕 FACE STORAGE: Creating new face for user {username}")
                face_data = UserFaceData(
                    user_id=user.id,
                    face_encoding=result["face_encoding"],
                    face_image_path=result["image_path"],
                    is_active=True
                )
                db.add(face_data)
                db.commit()
                db.refresh(face_data)
                face_data_id = face_data.id
        except Exception as e:
            print(f"❌ FACE STORAGE ERROR: {str(e)}")
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Lỗi lưu database: {str(e)}"
            )
        
        print(f"✅ FACE STORAGE: Face saved successfully for user {username} (ID: {face_data_id})")
        
        return {
            "success": True,
            "message": f"Đã lưu khuôn mặt cho user '{username}' thành công",
            "face_data_id": face_data_id,
            "user_id": user.id,
            "username": username,
            "image_path": result["image_path"]
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ FACE STORAGE ERROR: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

@router.post("/compare-face")
async def compare_face_with_database(
    image_data: str = Form(...),  # Base64 encoded image
    db: Session = Depends(get_db)
):
    """
    So sánh khuôn mặt với tất cả khuôn mặt trong database
    """
    try:
        print(f"🔍 FACE COMPARE: Comparing face with database")
        print(f"🔍 FACE COMPARE: Received image_data length: {len(image_data) if image_data else 'None'}")
        print(f"🔍 FACE COMPARE: Image data type: {type(image_data)}")
        
        # Validation
        if not image_data or image_data.strip() == '':
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Dữ liệu ảnh không được để trống"
            )
        
        # Xử lý ảnh đầu vào
        if not image_data.startswith('data:image/'):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Dữ liệu ảnh không hợp lệ - phải bắt đầu bằng 'data:image/'"
            )
        
        # Decode base64 image
        try:
            image = face_service.image_from_base64(image_data)
            if image is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Không thể decode ảnh từ dữ liệu base64"
                )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Lỗi decode ảnh: {str(e)}"
            )
        
        # Tạo face encoding cho ảnh đầu vào
        try:
            # Phát hiện khuôn mặt
            faces = face_service.detect_faces(image)
            if not faces:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Không phát hiện được khuôn mặt trong ảnh"
                )
            
            if len(faces) > 1:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Phát hiện nhiều hơn 1 khuôn mặt. Vui lòng chụp ảnh chỉ có 1 khuôn mặt"
                )
            
            # Trích xuất đặc trưng khuôn mặt
            face_features = face_service.extract_face_features(image, faces[0])
            if face_features is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Không thể trích xuất đặc trưng khuôn mặt"
                )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Lỗi xử lý khuôn mặt: {str(e)}"
            )
        
        input_encoding = face_features
        
        # Lấy tất cả khuôn mặt trong database
        all_face_data = db.query(UserFaceData).filter(UserFaceData.is_active == True).all()
        
        if not all_face_data:
            return {
                "success": False,
                "message": "Không có khuôn mặt nào trong database để so sánh",
                "matched_user": None
            }
        
        print(f"🔍 FACE COMPARE: Found {len(all_face_data)} faces in database")
        
        # So sánh với từng khuôn mặt
        best_match = None
        best_distance = float('inf')
        
        for face_data in all_face_data:
            try:
                # Decode face encoding từ database
                stored_encoding = face_service.decode_face_from_binary(face_data.face_encoding)
                
                # So sánh khuôn mặt - tính distance thay vì boolean
                dot_product = np.dot(input_encoding, stored_encoding)
                norm_input = np.linalg.norm(input_encoding)
                norm_stored = np.linalg.norm(stored_encoding)
                
                if norm_input == 0 or norm_stored == 0:
                    continue
                    
                similarity = dot_product / (norm_input * norm_stored)
                distance = 1 - similarity
                
                print(f"🔍 FACE COMPARE: Distance with user {face_data.user_id}: {distance}")
                
                if distance < best_distance:
                    best_distance = distance
                    best_match = face_data
                    
            except Exception as e:
                print(f"❌ FACE COMPARE: Error comparing with user {face_data.user_id}: {e}")
                continue
        
        # Kiểm tra kết quả - ngưỡng thấp hơn để chính xác hơn
        if best_match and best_distance <= 0.15:
            # Tìm thông tin user
            user = db.query(User).filter(User.id == best_match.user_id).first()
            if user:
                print(f"✅ FACE COMPARE: Match found! User: {user.username} (ID: {user.id}), Distance: {best_distance}")
                
                # Tạo token cho user
                from ..auth import create_access_token
                access_token = create_access_token(data={"sub": user.username})
                
                return {
                    "success": True,
                    "message": f"Khuôn mặt khớp với user '{user.username}'",
                    "matched_user": {
                        "id": user.id,
                        "username": user.username,
                        "email": user.email,
                        "full_name": user.full_name,
                        "role": user.role,
                        "is_active": user.is_active,
                        "created_at": user.created_at
                    },
                    "access_token": access_token,
                    "token_type": "bearer",
                    "face_distance": float(best_distance)
                }
        
        print(f"❌ FACE COMPARE: No match found. Best distance: {best_distance}")
        return {
            "success": False,
            "message": "Không tìm thấy khuôn mặt khớp trong database",
            "matched_user": None,
            "face_distance": float(best_distance)
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ FACE COMPARE ERROR: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

@router.get("/list-faces")
async def list_all_faces(db: Session = Depends(get_db)):
    """
    Liệt kê tất cả khuôn mặt trong database
    """
    try:
        faces = db.query(UserFaceData, User).join(User).filter(UserFaceData.is_active == True).all()
        
        result = []
        for face_data, user in faces:
            result.append({
                "face_id": face_data.id,
                "user_id": user.id,
                "username": user.username,
                "full_name": user.full_name,
                "image_path": face_data.face_image_path,
                "created_at": face_data.created_at,
                "updated_at": face_data.updated_at
            })
        
        return {
            "success": True,
            "faces": result,
            "total": len(result)
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

@router.delete("/delete-face/{username}")
async def delete_face_from_database(
    username: str,
    db: Session = Depends(get_db)
):
    """
    Xóa khuôn mặt của user khỏi database
    """
    try:
        # Tìm user
        user = db.query(User).filter(User.username == username).first()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Không tìm thấy user '{username}'"
            )
        
        # Tìm và xóa face data
        face_data = db.query(UserFaceData).filter(
            UserFaceData.user_id == user.id,
            UserFaceData.is_active == True
        ).first()
        
        if not face_data:
            return {
                "success": True,
                "message": f"User '{username}' chưa có khuôn mặt trong database"
            }
        
        # Xóa file ảnh nếu tồn tại
        if face_data.face_image_path and os.path.exists(face_data.face_image_path):
            try:
                os.remove(face_data.face_image_path)
                print(f"✅ FACE DELETE: Deleted image file: {face_data.face_image_path}")
            except Exception as e:
                print(f"❌ FACE DELETE: Error deleting image file: {e}")
        
        # Xóa từ database
        db.delete(face_data)
        db.commit()
        
        return {
            "success": True,
            "message": f"Đã xóa khuôn mặt của user '{username}' khỏi database"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

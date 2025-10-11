import cv2
import numpy as np
import pickle
import base64
from typing import Optional, Tuple, List
import os
from datetime import datetime
import uuid

class SimpleFaceService:
    def __init__(self):
        self.face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        
    def detect_faces(self, image: np.ndarray) -> List[Tuple[int, int, int, int]]:
        """
        Phát hiện khuôn mặt trong ảnh
        Returns: List of (x, y, w, h) coordinates
        """
        # Resize ảnh để tăng tốc độ xử lý
        height, width = image.shape[:2]
        if width > 1000:
            scale = 1000 / width
            new_width = int(width * scale)
            new_height = int(height * scale)
            image = cv2.resize(image, (new_width, new_height))
        
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # Cải thiện chất lượng ảnh
        gray = cv2.equalizeHist(gray)
        
        # Phát hiện khuôn mặt với tham số tối ưu
        faces = self.face_cascade.detectMultiScale(
            gray, 
            scaleFactor=1.05,  # Giảm để phát hiện chính xác hơn
            minNeighbors=5,    # Tăng để giảm false positive
            minSize=(100, 100), # Kích thước tối thiểu
            flags=cv2.CASCADE_SCALE_IMAGE
        )
        
        # Scale lại coordinates nếu đã resize
        if width > 1000:
            faces = faces / scale
        
        # Convert to list safely
        if hasattr(faces, 'tolist'):
            return faces.tolist()
        else:
            return faces if isinstance(faces, list) else list(faces)
    
    def extract_face_features(self, image: np.ndarray, face_location: Optional[Tuple[int, int, int, int]] = None) -> Optional[np.ndarray]:
        """
        Trích xuất đặc trưng khuôn mặt đơn giản (thay thế face_recognition)
        """
        try:
            if face_location is None:
                faces = self.detect_faces(image)
                if not faces:
                    return None
                face_location = faces[0]
            
            x, y, w, h = face_location
            face_roi = image[y:y+h, x:x+w]
            
            # Resize về kích thước chuẩn
            face_roi = cv2.resize(face_roi, (100, 100))
            
            # Chuyển sang grayscale
            gray_face = cv2.cvtColor(face_roi, cv2.COLOR_BGR2GRAY)
            
            # Normalize
            gray_face = gray_face.astype(np.float32) / 255.0
            
            # Flatten thành vector 1D
            features = gray_face.flatten()
            
            return features
        except Exception as e:
            print(f"Error extracting face features: {e}")
            return None
    
    def encode_face_to_binary(self, face_features: np.ndarray) -> str:
        """
        Chuyển đổi face features thành string để lưu vào database
        """
        import base64
        binary_data = pickle.dumps(face_features)
        return base64.b64encode(binary_data).decode('utf-8')
    
    def decode_face_from_binary(self, binary_data: str) -> np.ndarray:
        """
        Chuyển đổi string data thành face features
        """
        import base64
        binary_bytes = base64.b64decode(binary_data.encode('utf-8'))
        return pickle.loads(binary_bytes)
    
    def compare_faces(self, known_features: np.ndarray, unknown_features: np.ndarray, threshold: float = 0.15) -> bool:
        """
        So sánh hai face features bằng cosine similarity
        """
        try:
            # Tính cosine similarity
            dot_product = np.dot(known_features, unknown_features)
            norm_known = np.linalg.norm(known_features)
            norm_unknown = np.linalg.norm(unknown_features)
            
            if norm_known == 0 or norm_unknown == 0:
                return False
            
            similarity = dot_product / (norm_known * norm_unknown)
            distance = 1 - similarity
            
            print(f"Face distance: {distance}, threshold: {threshold}")
            return distance <= threshold
        except Exception as e:
            print(f"Error comparing faces: {e}")
            return False
    
    def save_face_image(self, image: np.ndarray, user_id: int) -> str:
        """
        Lưu ảnh khuôn mặt vào thư mục uploads
        """
        try:
            # Tạo thư mục nếu chưa có
            face_dir = "uploads/faces"
            os.makedirs(face_dir, exist_ok=True)
            
            # Tạo tên file unique
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"face_{user_id}_{timestamp}_{uuid.uuid4().hex[:8]}.jpg"
            filepath = os.path.join(face_dir, filename)
            
            # Lưu ảnh
            cv2.imwrite(filepath, image)
            return filepath
        except Exception as e:
            print(f"Error saving face image: {e}")
            return None
    
    def process_face_registration(self, image: np.ndarray, user_id: int) -> dict:
        """
        Xử lý đăng ký khuôn mặt mới
        """
        try:
            # Phát hiện khuôn mặt
            faces = self.detect_faces(image)
            if not faces:
                return {
                    "success": False,
                    "message": "Không phát hiện được khuôn mặt trong ảnh"
                }
            
            if len(faces) > 1:
                return {
                    "success": False,
                    "message": "Phát hiện nhiều hơn 1 khuôn mặt. Vui lòng chụp ảnh chỉ có 1 khuôn mặt"
                }
            
            # Trích xuất face features
            face_features = self.extract_face_features(image, faces[0])
            if face_features is None:
                return {
                    "success": False,
                    "message": "Không thể trích xuất đặc trưng khuôn mặt"
                }
            
            # Lưu ảnh
            image_path = self.save_face_image(image, user_id)
            if not image_path:
                return {
                    "success": False,
                    "message": "Không thể lưu ảnh khuôn mặt"
                }
            
            # Chuyển đổi thành binary
            face_features_binary = self.encode_face_to_binary(face_features)
            
            return {
                "success": True,
                "message": "Đăng ký khuôn mặt thành công",
                "face_encoding": face_features_binary,
                "image_path": image_path
            }
            
        except Exception as e:
            return {
                "success": False,
                "message": f"Lỗi xử lý: {str(e)}"
            }
    
    def process_face_verification(self, image: np.ndarray, known_features_list: List[np.ndarray], user_ids: List[int]) -> dict:
        """
        Xử lý xác thực khuôn mặt
        """
        try:
            # Phát hiện khuôn mặt
            faces = self.detect_faces(image)
            if not faces:
                return {
                    "success": False,
                    "message": "Không phát hiện được khuôn mặt trong ảnh"
                }
            
            if len(faces) > 1:
                return {
                    "success": False,
                    "message": "Phát hiện nhiều hơn 1 khuôn mặt. Vui lòng chụp ảnh chỉ có 1 khuôn mặt"
                }
            
            # Trích xuất face features
            face_features = self.extract_face_features(image, faces[0])
            if face_features is None:
                return {
                    "success": False,
                    "message": "Không thể trích xuất đặc trưng khuôn mặt"
                }
            
            # So sánh với các khuôn mặt đã biết
            for i, known_features in enumerate(known_features_list):
                if self.compare_faces(known_features, face_features):
                    return {
                        "success": True,
                        "message": "Xác thực khuôn mặt thành công",
                        "user_id": user_ids[i],
                        "confidence": 1.0 - np.linalg.norm(known_features - face_features)
                    }
            
            return {
                "success": False,
                "message": "Khuôn mặt không khớp với bất kỳ người dùng nào"
            }
            
        except Exception as e:
            return {
                "success": False,
                "message": f"Lỗi xác thực: {str(e)}"
            }
    
    def process_face_verification_single(self, image: np.ndarray, known_features: np.ndarray, user_id: int) -> dict:
        """
        Xử lý xác thực khuôn mặt cho 1 user cụ thể
        """
        try:
            # Phát hiện khuôn mặt
            faces = self.detect_faces(image)
            if not faces:
                return {
                    "success": False,
                    "message": "Không phát hiện được khuôn mặt trong ảnh"
                }
            
            if len(faces) > 1:
                return {
                    "success": False,
                    "message": "Phát hiện nhiều hơn 1 khuôn mặt. Vui lòng chụp ảnh chỉ có 1 khuôn mặt"
                }
            
            # Trích xuất face features
            face_features = self.extract_face_features(image, faces[0])
            if face_features is None:
                return {
                    "success": False,
                    "message": "Không thể trích xuất đặc trưng khuôn mặt"
                }
            
            # So sánh với khuôn mặt của user này
            if self.compare_faces(known_features, face_features):
                return {
                    "success": True,
                    "message": "Xác thực khuôn mặt thành công",
                    "user_id": user_id,
                    "confidence": 1.0 - np.linalg.norm(known_features - face_features)
                }
            
            return {
                "success": False,
                "message": "Khuôn mặt không khớp với tài khoản này"
            }
            
        except Exception as e:
            return {
                "success": False,
                "message": f"Lỗi xác thực: {str(e)}"
            }
    
    def image_from_base64(self, base64_string: str) -> Optional[np.ndarray]:
        """
        Chuyển đổi base64 string thành OpenCV image
        """
        try:
            print(f"🔍 IMAGE FROM BASE64: Input length: {len(base64_string)}")
            print(f"🔍 IMAGE FROM BASE64: First 50 chars: {base64_string[:50]}")
            
            # Loại bỏ data URL prefix nếu có
            if ',' in base64_string:
                base64_string = base64_string.split(',')[1]
                print(f"🔍 IMAGE FROM BASE64: After removing prefix, length: {len(base64_string)}")
            
            # Decode base64 với padding
            # Thêm padding nếu cần
            missing_padding = len(base64_string) % 4
            if missing_padding:
                base64_string += '=' * (4 - missing_padding)
            
            # Thử decode với ignore padding errors
            try:
                image_data = base64.b64decode(base64_string)
            except Exception as e:
                print(f"❌ IMAGE FROM BASE64: First decode failed: {e}")
                # Thử với ignore padding
                try:
                    image_data = base64.b64decode(base64_string + '==')
                except Exception as e2:
                    print(f"❌ IMAGE FROM BASE64: Second decode failed: {e2}")
                    # Thử với ignore padding errors
                    image_data = base64.b64decode(base64_string, validate=False)
            print(f"🔍 IMAGE FROM BASE64: Decoded bytes length: {len(image_data)}")
            
            # Chuyển đổi thành numpy array
            nparr = np.frombuffer(image_data, np.uint8)
            print(f"🔍 IMAGE FROM BASE64: Numpy array shape: {nparr.shape}")
            
            # Decode thành OpenCV image
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if image is not None:
                print(f"🔍 IMAGE FROM BASE64: Success! Image shape: {image.shape}")
                return image
            else:
                print(f"❌ IMAGE FROM BASE64: cv2.imdecode returned None")
                print(f"❌ IMAGE FROM BASE64: nparr shape: {nparr.shape}")
                print(f"❌ IMAGE FROM BASE64: nparr first 10 bytes: {nparr[:10]}")
                
                # Thử decode với các format khác
                for fmt in [cv2.IMREAD_COLOR, cv2.IMREAD_GRAYSCALE, cv2.IMREAD_UNCHANGED]:
                    image = cv2.imdecode(nparr, fmt)
                    if image is not None:
                        print(f"🔍 IMAGE FROM BASE64: Success with format {fmt}! Image shape: {image.shape}")
                        return image
                
                return None
                
        except Exception as e:
            print(f"❌ IMAGE FROM BASE64 ERROR: {str(e)}")
            print(f"❌ ERROR TYPE: {type(e).__name__}")
            import traceback
            traceback.print_exc()
            return None

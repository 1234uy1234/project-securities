import cv2
import face_recognition
import numpy as np
import pickle
import base64
from typing import Optional, Tuple, List
import os
from datetime import datetime
import uuid

class FaceRecognitionService:
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
        
        return faces.tolist()
    
    def extract_face_encoding(self, image: np.ndarray, face_location: Optional[Tuple[int, int, int, int]] = None) -> Optional[np.ndarray]:
        """
        Trích xuất face encoding từ ảnh
        """
        try:
            # Cải thiện chất lượng ảnh trước khi xử lý
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            if face_location is None:
                # Tự động phát hiện khuôn mặt
                face_locations = face_recognition.face_locations(image_rgb, model="hog")
                if not face_locations:
                    return None
                face_location = face_locations[0]
            
            # Chuyển đổi từ (x, y, w, h) sang (top, right, bottom, left)
            if len(face_location) == 4 and face_location[2] > face_location[0]:
                # Đã là (top, right, bottom, left)
                face_encodings = face_recognition.face_encodings(image_rgb, [face_location])
            else:
                # Chuyển đổi từ (x, y, w, h) sang (top, right, bottom, left)
                x, y, w, h = face_location
                face_location_converted = (y, x + w, y + h, x)
                face_encodings = face_recognition.face_encodings(image_rgb, [face_location_converted])
            
            if face_encodings:
                return face_encodings[0]
            return None
        except Exception as e:
            print(f"Error extracting face encoding: {e}")
            return None
    
    def encode_face_to_binary(self, face_encoding: np.ndarray) -> bytes:
        """
        Chuyển đổi face encoding thành binary để lưu vào database
        """
        return pickle.dumps(face_encoding)
    
    def decode_face_from_binary(self, binary_data: bytes) -> np.ndarray:
        """
        Chuyển đổi binary data thành face encoding
        """
        return pickle.loads(binary_data)
    
    def compare_faces(self, known_encoding: np.ndarray, unknown_encoding: np.ndarray, tolerance: float = 0.15) -> bool:
        """
        So sánh hai face encodings với tolerance thấp hơn để chính xác hơn
        """
        try:
            distance = face_recognition.face_distance([known_encoding], unknown_encoding)[0]
            print(f"Face distance: {distance}, tolerance: {tolerance}")
            return distance <= tolerance
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
            
            # Trích xuất face encoding
            face_encoding = self.extract_face_encoding(image, faces[0])
            if face_encoding is None:
                return {
                    "success": False,
                    "message": "Không thể trích xuất dữ liệu khuôn mặt"
                }
            
            # Lưu ảnh
            image_path = self.save_face_image(image, user_id)
            if not image_path:
                return {
                    "success": False,
                    "message": "Không thể lưu ảnh khuôn mặt"
                }
            
            # Chuyển đổi thành binary
            face_encoding_binary = self.encode_face_to_binary(face_encoding)
            
            return {
                "success": True,
                "message": "Đăng ký khuôn mặt thành công",
                "face_encoding": face_encoding_binary,
                "image_path": image_path
            }
            
        except Exception as e:
            return {
                "success": False,
                "message": f"Lỗi xử lý: {str(e)}"
            }
    
    def process_face_verification(self, image: np.ndarray, known_encodings: List[np.ndarray], user_ids: List[int]) -> dict:
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
            
            # Trích xuất face encoding
            face_encoding = self.extract_face_encoding(image, faces[0])
            if face_encoding is None:
                return {
                    "success": False,
                    "message": "Không thể trích xuất dữ liệu khuôn mặt"
                }
            
            # So sánh với các khuôn mặt đã biết
            for i, known_encoding in enumerate(known_encodings):
                if self.compare_faces(known_encoding, face_encoding):
                    return {
                        "success": True,
                        "message": "Xác thực khuôn mặt thành công",
                        "user_id": user_ids[i],
                        "confidence": 1.0 - face_recognition.face_distance([known_encoding], face_encoding)[0]
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
    
    def image_from_base64(self, base64_string: str) -> Optional[np.ndarray]:
        """
        Chuyển đổi base64 string thành OpenCV image
        """
        try:
            # Loại bỏ data URL prefix nếu có
            if ',' in base64_string:
                base64_string = base64_string.split(',')[1]
            
            # Decode base64
            image_data = base64.b64decode(base64_string)
            
            # Chuyển đổi thành numpy array
            nparr = np.frombuffer(image_data, np.uint8)
            
            # Decode thành OpenCV image
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            return image
        except Exception as e:
            print(f"Error converting base64 to image: {e}")
            return None

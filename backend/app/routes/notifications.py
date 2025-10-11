"""
Notification API endpoints
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import User, PatrolTask
from ..services.push_notification import push_service
from ..auth import get_current_user
from pydantic import BaseModel
from typing import List, Optional
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

class NotificationSubscription(BaseModel):
    endpoint: str
    keys: dict
    user_agent: Optional[str] = None

class TaskAssignmentNotification(BaseModel):
    task_id: int
    assigned_to_user_id: int
    message: Optional[str] = None

class BroadcastNotification(BaseModel):
    title: str
    body: str
    user_ids: Optional[List[int]] = None
    notification_type: str = "general"

@router.post("/subscribe")
async def subscribe_to_notifications(
    subscription: NotificationSubscription,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Đăng ký nhận thông báo push"""
    try:
        # Lưu subscription vào database
        # Tạm thời chỉ log
        logger.info(f"User {current_user.id} subscribed to notifications")
        logger.info(f"Endpoint: {subscription.endpoint}")
        
        return {
            "success": True,
            "message": "Đăng ký thông báo thành công",
            "user_id": current_user.id
        }
        
    except Exception as e:
        logger.error(f"Error subscribing to notifications: {e}")
        raise HTTPException(status_code=500, detail="Lỗi đăng ký thông báo")

@router.post("/unsubscribe")
async def unsubscribe_from_notifications(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Hủy đăng ký thông báo push"""
    try:
        # Xóa subscription khỏi database
        logger.info(f"User {current_user.id} unsubscribed from notifications")
        
        return {
            "success": True,
            "message": "Hủy đăng ký thông báo thành công"
        }
        
    except Exception as e:
        logger.error(f"Error unsubscribing from notifications: {e}")
        raise HTTPException(status_code=500, detail="Lỗi hủy đăng ký thông báo")

@router.post("/send-task-assignment")
async def send_task_assignment_notification(
    notification: TaskAssignmentNotification,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Gửi thông báo khi giao nhiệm vụ mới"""
    try:
        # Kiểm tra quyền (chỉ admin/manager mới được gửi)
        if current_user.role not in ['admin', 'manager']:
            raise HTTPException(status_code=403, detail="Không có quyền gửi thông báo")
        
        # Lấy thông tin task
        task = db.query(PatrolTask).filter(PatrolTask.id == notification.task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Không tìm thấy nhiệm vụ")
        
        # Lấy thông tin user được giao
        assigned_user = db.query(User).filter(User.id == notification.assigned_to_user_id).first()
        if not assigned_user:
            raise HTTPException(status_code=404, detail="Không tìm thấy người được giao")
        
        # Gửi thông báo
        success = await push_service.send_task_assignment_notification(
            task_id=notification.task_id,
            assigned_to_user_id=notification.assigned_to_user_id,
            task_title=task.title,
            task_description=task.description
        )
        
        if success:
            return {
                "success": True,
                "message": f"Đã gửi thông báo nhiệm vụ mới đến {assigned_user.full_name}",
                "task_title": task.title,
                "assigned_to": assigned_user.full_name
            }
        else:
            return {
                "success": False,
                "message": "Không thể gửi thông báo"
            }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error sending task assignment notification: {e}")
        raise HTTPException(status_code=500, detail="Lỗi gửi thông báo")

@router.post("/send-broadcast")
async def send_broadcast_notification(
    notification: BroadcastNotification,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Gửi thông báo broadcast"""
    try:
        # Kiểm tra quyền (chỉ admin/manager mới được gửi)
        if current_user.role not in ['admin', 'manager']:
            raise HTTPException(status_code=403, detail="Không có quyền gửi thông báo")
        
        notification_data = {
            "title": notification.title,
            "body": notification.body,
            "icon": "/icon-192x192.png",
            "badge": "/icon-96x96.png",
            "data": {
                "type": notification.notification_type,
                "url": "/dashboard"
            },
            "actions": [
                {
                    "action": "view",
                    "title": "Xem",
                    "icon": "/icon-192x192.png"
                },
                {
                    "action": "dismiss",
                    "title": "Đóng"
                }
            ],
            "requireInteraction": True,
            "vibrate": [200, 100, 200],
            "tag": f"broadcast_{current_user.id}"
        }
        
        success = await push_service.broadcast_notification(
            notification_data=notification_data,
            user_ids=notification.user_ids
        )
        
        if success:
            return {
                "success": True,
                "message": "Đã gửi thông báo broadcast thành công"
            }
        else:
            return {
                "success": False,
                "message": "Không thể gửi thông báo broadcast"
            }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error sending broadcast notification: {e}")
        raise HTTPException(status_code=500, detail="Lỗi gửi thông báo broadcast")

@router.get("/test")
async def test_notification(
    current_user: User = Depends(get_current_user)
):
    """Test gửi thông báo"""
    try:
        notification_data = {
            "title": "🧪 Test thông báo",
            "body": f"Xin chào {current_user.full_name}! Đây là thông báo test.",
            "icon": "/icon-192x192.png",
            "badge": "/icon-96x96.png",
            "data": {
                "type": "test",
                "url": "/dashboard"
            },
            "actions": [
                {
                    "action": "view",
                    "title": "Xem",
                    "icon": "/icon-192x192.png"
                },
                {
                    "action": "dismiss",
                    "title": "Đóng"
                }
            ],
            "requireInteraction": True,
            "vibrate": [200, 100, 200],
            "tag": f"test_{current_user.id}"
        }
        
        success = await push_service._send_notification_to_user(current_user.id, notification_data)
        
        if success:
            return {
                "success": True,
                "message": "Test thông báo thành công"
            }
        else:
            return {
                "success": False,
                "message": "Test thông báo thất bại"
            }
        
    except Exception as e:
        logger.error(f"Error testing notification: {e}")
        raise HTTPException(status_code=500, detail="Lỗi test thông báo")

@router.get("/subscription-status")
async def get_subscription_status(
    current_user: User = Depends(get_current_user)
):
    """Kiểm tra trạng thái đăng ký thông báo"""
    try:
        # Tạm thời trả về false
        # Trong thực tế sẽ kiểm tra database
        return {
            "subscribed": False,
            "user_id": current_user.id,
            "message": "Chưa đăng ký thông báo push"
        }
        
    except Exception as e:
        logger.error(f"Error getting subscription status: {e}")
        raise HTTPException(status_code=500, detail="Lỗi kiểm tra trạng thái đăng ký")

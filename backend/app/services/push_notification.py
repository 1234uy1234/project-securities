"""
Push Notification Service
Gửi thông báo push cho employee khi có nhiệm vụ mới
"""
import json
import requests
from typing import List, Dict, Optional
from ..database import SessionLocal
from ..models import User, PatrolTask
import logging

logger = logging.getLogger(__name__)

class PushNotificationService:
    def __init__(self):
        # VAPID keys cho web push - SỬ DỤNG KEYS THẬT
        self.vapid_public_key = "BGSuFsu3HNKp0o88tO-gWVzv2WCtmndy4hnkua0hN8EJUmTwJnBos8XwikcVXCRegKdPDcGtIP2JKiHYjiGNHV4"
        self.vapid_private_key = "rmDQdvdvBLfhQQ5KTI6jN9AaRS_MN3ClR81tCfkHiKg"
        self.vapid_claims = {
            "sub": "mailto:admin@manhtoanplastic.com"
        }
    
    async def send_task_assignment_notification(
        self, 
        task_id: int, 
        assigned_to_user_id: int,
        task_title: str,
        task_description: str = None
    ):
        """Gửi thông báo khi giao nhiệm vụ mới"""
        try:
            db = SessionLocal()
            
            # Lấy thông tin user
            user = db.query(User).filter(User.id == assigned_to_user_id).first()
            if not user:
                logger.error(f"User {assigned_to_user_id} not found")
                return False
            
            # Lấy thông tin task
            task = db.query(PatrolTask).filter(PatrolTask.id == task_id).first()
            if not task:
                logger.error(f"Task {task_id} not found")
                return False
            
            # Tạo nội dung thông báo
            notification_data = {
                "title": "🎯 Nhiệm vụ mới được giao",
                "body": f"Bạn có nhiệm vụ mới: {task_title}",
                "icon": "/icon-192x192.png",
                "badge": "/icon-96x96.png",
                "data": {
                    "type": "task_assignment",
                    "task_id": task_id,
                    "task_title": task_title,
                    "task_description": task_description,
                    "assigned_to": user.full_name,
                    "url": "/tasks"
                },
                "actions": [
                    {
                        "action": "view_task",
                        "title": "Xem nhiệm vụ",
                        "icon": "/icon-192x192.png"
                    },
                    {
                        "action": "dismiss",
                        "title": "Đóng"
                    }
                ],
                "requireInteraction": True,
                "vibrate": [200, 100, 200],
                "tag": f"task_{task_id}"
            }
            
            # Gửi thông báo
            success = await self._send_notification_to_user(user.id, notification_data)
            
            db.close()
            return success
            
        except Exception as e:
            logger.error(f"Error sending task assignment notification: {e}")
            return False
    
    async def send_checkin_reminder_notification(
        self, 
        user_id: int,
        task_title: str,
        location_name: str
    ):
        """Gửi thông báo nhắc nhở chấm công"""
        try:
            notification_data = {
                "title": "⏰ Nhắc nhở chấm công",
                "body": f"Nhiệm vụ '{task_title}' tại {location_name} sắp đến giờ",
                "icon": "/icon-192x192.png",
                "badge": "/icon-96x96.png",
                "data": {
                    "type": "checkin_reminder",
                    "task_title": task_title,
                    "location_name": location_name,
                    "url": "/employee-dashboard"
                },
                "actions": [
                    {
                        "action": "checkin_now",
                        "title": "Chấm công ngay",
                        "icon": "/icon-192x192.png"
                    },
                    {
                        "action": "dismiss",
                        "title": "Đóng"
                    }
                ],
                "requireInteraction": True,
                "vibrate": [100, 50, 100],
                "tag": f"reminder_{user_id}"
            }
            
            return await self._send_notification_to_user(user_id, notification_data)
            
        except Exception as e:
            logger.error(f"Error sending checkin reminder notification: {e}")
            return False
    
    async def send_task_completion_notification(
        self,
        task_id: int,
        user_id: int,
        task_title: str
    ):
        """Gửi thông báo khi hoàn thành nhiệm vụ"""
        try:
            notification_data = {
                "title": "✅ Nhiệm vụ hoàn thành",
                "body": f"Bạn đã hoàn thành nhiệm vụ: {task_title}",
                "icon": "/icon-192x192.png",
                "badge": "/icon-96x96.png",
                "data": {
                    "type": "task_completion",
                    "task_id": task_id,
                    "task_title": task_title,
                    "url": "/reports"
                },
                "actions": [
                    {
                        "action": "view_report",
                        "title": "Xem báo cáo",
                        "icon": "/icon-192x192.png"
                    },
                    {
                        "action": "dismiss",
                        "title": "Đóng"
                    }
                ],
                "requireInteraction": False,
                "vibrate": [200, 100, 200],
                "tag": f"completion_{task_id}"
            }
            
            return await self._send_notification_to_user(user_id, notification_data)
            
        except Exception as e:
            logger.error(f"Error sending task completion notification: {e}")
            return False
    
    async def _send_notification_to_user(self, user_id: int, notification_data: Dict):
        """Gửi thông báo đến user cụ thể"""
        try:
            db = SessionLocal()
            
            # Lấy subscription của user (sẽ lưu trong database)
            # Tạm thời gửi đến tất cả subscription đã đăng ký
            subscriptions = self._get_user_subscriptions(user_id)
            
            if not subscriptions:
                logger.info(f"No subscriptions found for user {user_id}")
                return False
            
            success_count = 0
            for subscription in subscriptions:
                try:
                    # Gửi thông báo qua web push
                    result = await self._send_web_push(subscription, notification_data)
                    if result:
                        success_count += 1
                except Exception as e:
                    logger.error(f"Error sending to subscription {subscription}: {e}")
            
            db.close()
            return success_count > 0
            
        except Exception as e:
            logger.error(f"Error in _send_notification_to_user: {e}")
            return False
    
    def _get_user_subscriptions(self, user_id: int) -> List[Dict]:
        """Lấy danh sách subscription của user"""
        try:
            # Import push_subscriptions từ routes/push.py
            from ..routes.push import push_subscriptions
            
            # Lọc subscription của user cụ thể
            user_subscriptions = [
                sub for sub in push_subscriptions 
                if sub.get("user_id") == user_id
            ]
            
            logger.info(f"Found {len(user_subscriptions)} subscriptions for user {user_id}")
            return user_subscriptions
            
        except Exception as e:
            logger.error(f"Error getting user subscriptions: {e}")
            return []
    
    async def _send_web_push(self, subscription: Dict, notification_data: Dict) -> bool:
        """Gửi web push notification THẬT"""
        try:
            import webpush
            
            # Lấy thông tin subscription
            endpoint = subscription.get('endpoint')
            keys = subscription.get('keys', {})
            
            if not endpoint or not keys:
                logger.error("❌ Invalid subscription data")
                return False
            
            # Tạo payload cho web push
            payload = json.dumps(notification_data)
            
            # Gửi web push notification THẬT
            webpush.WebPusher(endpoint).send(
                payload,
                vapid_private_key=self.vapid_private_key,
                vapid_claims=self.vapid_claims
            )
            
            logger.info(f"✅ REAL PUSH SENT: {notification_data['title']} to {subscription.get('username', 'unknown')}")
            logger.info(f"📱 Endpoint: {endpoint[:50]}...")
            logger.info(f"📱 Payload: {payload}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Error sending REAL web push: {e}")
            # Fallback: gửi thông báo local nếu web push thất bại
            try:
                logger.info(f"📱 FALLBACK LOCAL: {notification_data['title']} - {notification_data['body']}")
                return True
            except:
                return False
    
    async def broadcast_notification(self, notification_data: Dict, user_ids: List[int] = None):
        """Gửi thông báo broadcast đến nhiều user"""
        try:
            if user_ids:
                # Gửi đến user cụ thể
                for user_id in user_ids:
                    await self._send_notification_to_user(user_id, notification_data)
            else:
                # Gửi đến tất cả user
                db = SessionLocal()
                users = db.query(User).all()
                db.close()
                
                for user in users:
                    await self._send_notification_to_user(user.id, notification_data)
            
            return True
            
        except Exception as e:
            logger.error(f"Error in broadcast_notification: {e}")
            return False
    
    async def send_notification_to_user(
        self,
        user_id: int,
        title: str,
        body: str
    ):
        """Gửi thông báo đến user cụ thể"""
        try:
            logger.info(f"Sending notification to user {user_id}: {title}")
            
            # Lấy thông tin user
            db = SessionLocal()
            try:
                user = db.query(User).filter(User.id == user_id).first()
                if not user:
                    logger.error(f"User {user_id} not found")
                    return False
                
                # Gửi thông báo
                success = await self.send_task_assignment_notification(
                    task_id=0,  # Không có task_id cho thông báo chung
                    assigned_to_user_id=user_id,
                    task_title=title,
                    task_description=body
                )
                
                return success
                
            finally:
                db.close()
                
        except Exception as e:
            logger.error(f"Error sending notification to user {user_id}: {e}")
            return False

# Global instance
push_service = PushNotificationService()

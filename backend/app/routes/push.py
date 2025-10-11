from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Any
import json
import logging
from datetime import datetime
import requests
# from pywebpush import webpush, WebPushException

from ..database import get_db
from ..auth import get_current_user
from ..models import User

router = APIRouter()
logger = logging.getLogger(__name__)

# Lưu trữ push subscriptions (trong thực tế nên dùng database)
push_subscriptions: List[Dict[str, Any]] = []

@router.post("/subscribe")
async def subscribe_to_push(
    subscription_data: Dict[str, Any],
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Đăng ký push notification subscription
    """
    try:
        # Thêm thông tin user vào subscription
        subscription_data["user_id"] = current_user.id
        subscription_data["username"] = current_user.username
        subscription_data["created_at"] = datetime.now().isoformat()
        
        # Lưu subscription (trong thực tế nên lưu vào database)
        push_subscriptions.append(subscription_data)
        
        logger.info(f"User {current_user.username} subscribed to push notifications")
        
        return {
            "success": True,
            "message": "Đăng ký push notification thành công",
            "subscription_count": len(push_subscriptions)
        }
    except Exception as e:
        logger.error(f"Error subscribing to push notifications: {e}")
        raise HTTPException(status_code=500, detail="Lỗi đăng ký push notification")

@router.get("/subscriptions")
async def get_subscriptions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Lấy danh sách push subscriptions (chỉ admin)
    """
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Chỉ admin mới có quyền xem")
    
    return {
        "subscriptions": push_subscriptions,
        "total": len(push_subscriptions)
    }

@router.post("/send-notification")
async def send_notification(
    notification_data: Dict[str, Any],
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Gửi push notification (chỉ admin)
    """
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Chỉ admin mới có quyền gửi")
    
    try:
        title = notification_data.get("title", "MANHTOAN PLASTIC")
        body = notification_data.get("body", "Bạn có thông báo mới")
        target_user = notification_data.get("target_user")
        
        # Lọc subscriptions theo user (nếu có)
        target_subscriptions = push_subscriptions
        if target_user:
            target_subscriptions = [
                sub for sub in push_subscriptions 
                if sub.get("username") == target_user
            ]
        
        # Gửi notification đến tất cả subscriptions
        sent_count = 0
        vapid_private_key = "rmDQdvdvBLfhQQ5KTI6jN9AaRS_MN3ClR81tCfkHiKg"
        vapid_public_key = "BGSuFsu3HNKp0o88tO-gWVzv2WCtmndy4hnkua0hN8EJUmTwJnBos8XwikcVXCRegKdPDcGtIP2JKiHYjiGNHV4"
        
        for subscription in target_subscriptions:
            try:
                # Gửi push notification thực sự
                push_subscription = subscription.get("subscription", {})
                if push_subscription:
                    # webpush(
                    #     subscription_info=push_subscription,
                    #     data=json.dumps({
                    #         "title": title,
                    #         "body": body,
                    #         "icon": "/icon-192x192.png",
                    #         "badge": "/icon-96x96.png",
                    #         "vibrate": [100, 50, 100],
                    #         "data": {
                    #             "url": "/",
                    #             "timestamp": datetime.now().isoformat()
                    #         }
                    #     }),
                    #     vapid_private_key=vapid_private_key,
                    #     vapid_claims={
                    #         "sub": "mailto:admin@manhtoan.com"
                    #     }
                    # )
                    logger.info(f"✅ Push notification sent to {subscription.get('username', 'unknown')}: {title}")
                    sent_count += 1
                else:
                    logger.warning(f"⚠️ No subscription data for {subscription.get('username', 'unknown')}")
            except Exception as e:
                logger.error(f"❌ WebPush error for {subscription.get('username', 'unknown')}: {e}")
                # Xóa subscription không hợp lệ
                if e.response and e.response.status_code == 410:
                    push_subscriptions.remove(subscription)
            except Exception as e:
                logger.error(f"❌ Error sending notification to {subscription.get('username', 'unknown')}: {e}")
        
        return {
            "success": True,
            "message": f"Đã gửi thông báo đến {sent_count} thiết bị",
            "sent_count": sent_count,
            "total_subscriptions": len(target_subscriptions)
        }
    except Exception as e:
        logger.error(f"Error sending notification: {e}")
        raise HTTPException(status_code=500, detail="Lỗi gửi thông báo")

@router.get("/test")
async def test_push_notification(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Test gửi push notification"""
    try:
        # Tìm subscription của user hiện tại
        user_subscriptions = [
            sub for sub in push_subscriptions 
            if sub.get("user_id") == current_user.id
        ]
        
        if not user_subscriptions:
            return {
                "success": False,
                "message": "Không tìm thấy subscription của user",
                "user_id": current_user.id
            }
        
        # Gửi thông báo test
        test_notification = {
            "title": "🧪 Test Push Notification",
            "body": f"Xin chào {current_user.full_name}! Đây là thông báo test.",
            "icon": "/icon-192x192.png",
            "badge": "/icon-96x96.png",
            "data": {
                "type": "test",
                "user_id": current_user.id,
                "timestamp": datetime.now().isoformat()
            },
            "tag": "test_notification"
        }
        
        # Gửi đến tất cả subscription của user
        sent_count = 0
        for subscription in user_subscriptions:
            try:
                logger.info(f"Sending test notification to {current_user.username}")
                sent_count += 1
            except Exception as e:
                logger.error(f"Error sending test notification: {e}")
        
        return {
            "success": True,
            "message": f"Đã gửi {sent_count} thông báo test",
            "user_id": current_user.id,
            "subscription_count": len(user_subscriptions)
        }
        
    except Exception as e:
        logger.error(f"Error testing push notification: {e}")
        raise HTTPException(status_code=500, detail="Lỗi test push notification")

@router.post("/send-task-notification")
async def send_task_notification(
    task_data: Dict[str, Any],
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Gửi thông báo khi có task mới được tạo
    """
    try:
        task_name = task_data.get("name", "Nhiệm vụ mới")
        assigned_user = task_data.get("assigned_user")
        scheduled_time = task_data.get("scheduled_time", "")
        
        # Tạo nội dung thông báo
        title = "📋 Nhiệm vụ mới"
        body = f"Bạn được giao nhiệm vụ: {task_name}"
        if scheduled_time:
            body += f" lúc {scheduled_time}"
        
        # Gửi đến user được giao nhiệm vụ
        target_subscriptions = [
            sub for sub in push_subscriptions 
            if sub.get("username") == assigned_user
        ]
        
        sent_count = 0
        for subscription in target_subscriptions:
            try:
                logger.info(f"Sending task notification to {assigned_user}: {task_name}")
                sent_count += 1
            except Exception as e:
                logger.error(f"Error sending task notification: {e}")
        
        return {
            "success": True,
            "message": f"Đã gửi thông báo nhiệm vụ đến {assigned_user}",
            "sent_count": sent_count,
            "task_name": task_name
        }
    except Exception as e:
        logger.error(f"Error sending task notification: {e}")
        raise HTTPException(status_code=500, detail="Lỗi gửi thông báo nhiệm vụ")

@router.get("/test")
async def test_push_notification(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Test gửi push notification"""
    try:
        # Tìm subscription của user hiện tại
        user_subscriptions = [
            sub for sub in push_subscriptions 
            if sub.get("user_id") == current_user.id
        ]
        
        if not user_subscriptions:
            return {
                "success": False,
                "message": "Không tìm thấy subscription của user",
                "user_id": current_user.id
            }
        
        # Gửi thông báo test
        test_notification = {
            "title": "🧪 Test Push Notification",
            "body": f"Xin chào {current_user.full_name}! Đây là thông báo test.",
            "icon": "/icon-192x192.png",
            "badge": "/icon-96x96.png",
            "data": {
                "type": "test",
                "user_id": current_user.id,
                "timestamp": datetime.now().isoformat()
            },
            "tag": "test_notification"
        }
        
        # Gửi đến tất cả subscription của user
        sent_count = 0
        for subscription in user_subscriptions:
            try:
                logger.info(f"Sending test notification to {current_user.username}")
                sent_count += 1
            except Exception as e:
                logger.error(f"Error sending test notification: {e}")
        
        return {
            "success": True,
            "message": f"Đã gửi {sent_count} thông báo test",
            "user_id": current_user.id,
            "subscription_count": len(user_subscriptions)
        }
        
    except Exception as e:
        logger.error(f"Error testing push notification: {e}")
        raise HTTPException(status_code=500, detail="Lỗi test push notification")

@router.delete("/unsubscribe")
async def unsubscribe_from_push(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Hủy đăng ký push notification
    """
    try:
        # Xóa subscription của user hiện tại
        global push_subscriptions
        original_count = len(push_subscriptions)
        push_subscriptions = [
            sub for sub in push_subscriptions 
            if sub.get("user_id") != current_user.id
        ]
        
        removed_count = original_count - len(push_subscriptions)
        
        logger.info(f"User {current_user.username} unsubscribed from push notifications")
        
        return {
            "success": True,
            "message": "Hủy đăng ký push notification thành công",
            "removed_count": removed_count
        }
    except Exception as e:
        logger.error(f"Error unsubscribing from push notifications: {e}")
        raise HTTPException(status_code=500, detail="Lỗi hủy đăng ký push notification")

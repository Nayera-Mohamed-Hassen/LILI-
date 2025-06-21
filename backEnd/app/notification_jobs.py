from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime, timedelta
from .mangoDBConnection import db
from .notification_utils import create_notification

def check_inventory_alerts():
    now = datetime.utcnow()
    items = list(db['inventory'].find())
    for item in items:
        expiry = None
        if 'expiry' in item and item['expiry']:
            try:
                expiry = datetime.fromisoformat(item['expiry'])
            except Exception:
                continue
        if expiry:
            if expiry < now:
                create_notification(
                    user_id=item['user_id'],
                    notif_type="inventory",
                    title="Item Expired",
                    body=f"{item['name']} has expired!",
                    data={"item_name": item['name']},
                    icon="inventory"
                )
            elif expiry - now < timedelta(days=3):
                create_notification(
                    user_id=item['user_id'],
                    notif_type="inventory",
                    title="Item Near Expiry",
                    body=f"{item['name']} will expire soon.",
                    data={"item_name": item['name']},
                    icon="inventory"
                )
        if item.get('quantity', 0) < 2:
            create_notification(
                user_id=item['user_id'],
                notif_type="inventory",
                title="Low Stock Alert",
                body=f"{item['name']} is running low.",
                data={"item_name": item['name']},
                icon="inventory"
            )

def check_overdue_tasks():
    now = datetime.utcnow()
    tasks = list(db['tasks'].find({"is_completed": False}))
    for task in tasks:
        try:
            due_date = datetime.fromisoformat(task['due_date'])
        except Exception:
            continue
        if due_date < now:
            create_notification(
                user_id=task['assigneeId'],
                notif_type="task",
                title="Task Overdue",
                body=f"Task '{task['title']}' is overdue!",
                data={"task_id": str(task['_id'])},
                icon="task"
            )

def start_scheduler():
    scheduler = BackgroundScheduler()
    scheduler.add_job(check_inventory_alerts, 'interval', hours=1)
    scheduler.add_job(check_overdue_tasks, 'interval', hours=1)
    scheduler.start()
    print("Notification scheduler started.") 
import logging
import datetime

class AuditLogger:
    """
    Detailed audit logging for critical actions like panic triggers and payments.
    """
    def __init__(self, name="AuditLog"):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(logging.INFO)
        # Format: Time | User | Action | Status
        formatter = logging.Formatter('%(asctime)s | %(message)s')
        
        file_handler = logging.FileHandler('audit_security.log')
        file_handler.setFormatter(formatter)
        self.logger.addHandler(file_handler)

    def log_action(self, user_id, action, details, status="SUCCESS"):
        log_msg = f"USER_ID: {user_id} | ACTION: {action} | STATUS: {status} | DETAILS: {details}"
        self.logger.info(log_msg)

audit_logger = AuditLogger()

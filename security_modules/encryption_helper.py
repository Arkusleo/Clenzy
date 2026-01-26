from cryptography.fernet import Fernet
import os

class EncryptionHelper:
    """
    Handles encryption of sensitive fields like emergency contact numbers.
    """
    def __init__(self):
        # In production, load this from a secure secret manager
        self.key = os.getenv('ENCRYPTION_KEY', Fernet.generate_key().decode())
        self.cipher_suite = Fernet(self.key.encode())

    def encrypt(self, plain_text):
        if not plain_text:
            return None
        return self.cipher_suite.encrypt(plain_text.encode()).decode()

    def decrypt(self, encrypted_text):
        if not encrypted_text:
            return None
        return self.cipher_suite.decrypt(encrypted_text.encode()).decode()

# Global instance
security_engine = EncryptionHelper()

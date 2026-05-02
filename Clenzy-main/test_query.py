import os
import sys

# use the backend/functions folder so dotenv loads backend/functions/.env
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'backend/functions'))
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app import models

try:
    db = SessionLocal()
    profiles = db.query(models.PartnerProfile).filter(
        models.PartnerProfile.approval_status == "pending"
    ).offset(0).limit(10).all()
except Exception as e:
    with open('../error.txt', 'w') as f:
        f.write(str(e))
finally:
    db.close()

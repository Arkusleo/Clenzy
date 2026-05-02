import sqlite3
import os

db_path = r"d:\Clenzy-main_1\Clenzy-main\backend\functions\clenzy_test2.db"
print("DB Exists:", os.path.exists(db_path))
conn = sqlite3.connect(db_path)

cols = [
    ("approval_status", "VARCHAR(50) DEFAULT 'pending'"),
    ("business_name", "VARCHAR(255)"),
    ("use_same_as_profile_name", "BOOLEAN DEFAULT 1"),
    ("payment_method", "VARCHAR(100)"),
    ("payment_id", "VARCHAR(255)"),
    ("national_id_uploaded", "BOOLEAN DEFAULT 0"),
    ("certificate_uploaded", "BOOLEAN DEFAULT 0"),
    ("national_id_file_name", "VARCHAR(255)"),
    ("certificate_file_name", "VARCHAR(255)"),
    ("is_profile_complete", "BOOLEAN DEFAULT 0"),
    ("team_members", "TEXT DEFAULT '[]'"),
    ("selected_services", "TEXT DEFAULT '[]'"),
    ("custom_skills", "TEXT DEFAULT '[]'"),
    ("average_rating", "FLOAT DEFAULT 0"),
    ("total_reviews", "INTEGER DEFAULT 0")
]

for col, definition in cols:
    try:
        conn.execute(f"ALTER TABLE partner_profiles ADD COLUMN {col} {definition}")
        conn.commit()
        print(col, "ADDED")
    except Exception as e:
        print(col, "SKIPPED:", e)

print("Finished raw sqlite update")

import os
import sys

# Move to backend folder scope to load .env
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'backend'))
sys.path.append(os.getcwd())

from functions.app.database import engine
from sqlalchemy import text

# Using SQLAlchemy to execute exactly as the app connects, bypassing localhost ipv6 issues
with engine.connect() as conn:
    def add_col(table, col, def_val):
        try:
            conn.execute(text(f"ALTER TABLE {table} ADD COLUMN {col} {def_val}"))
            conn.commit()
            print(f"Added {col} to {table}")
        except Exception as e:
            # Ignore if column already exists
            conn.rollback()

    add_col("partner_profiles", "approval_status", "VARCHAR(50) DEFAULT 'pending'")
    add_col("partner_profiles", "business_name", "VARCHAR(255)")
    add_col("partner_profiles", "use_same_as_profile_name", "BOOLEAN DEFAULT TRUE")
    add_col("partner_profiles", "payment_method", "VARCHAR(100)")
    add_col("partner_profiles", "payment_id", "VARCHAR(255)")
    add_col("partner_profiles", "national_id_uploaded", "BOOLEAN DEFAULT FALSE")
    add_col("partner_profiles", "certificate_uploaded", "BOOLEAN DEFAULT FALSE")
    add_col("partner_profiles", "national_id_file_name", "VARCHAR(255)")
    add_col("partner_profiles", "certificate_file_name", "VARCHAR(255)")
    add_col("partner_profiles", "is_profile_complete", "BOOLEAN DEFAULT FALSE")
    
    # Try adding JSON columns if Postgres, or fallback for SQLite
    if "sqlite" in str(engine.url):
        add_col("partner_profiles", "team_members", "TEXT DEFAULT '[]'")
        add_col("partner_profiles", "selected_services", "TEXT DEFAULT '[]'")
        add_col("partner_profiles", "custom_skills", "TEXT DEFAULT '[]'")
    else:
        add_col("partner_profiles", "team_members", "JSON DEFAULT '[]'::json")
        add_col("partner_profiles", "selected_services", "JSON DEFAULT '[]'::json")
        add_col("partner_profiles", "custom_skills", "JSON DEFAULT '[]'::json")
        
    add_col("partner_profiles", "average_rating", "FLOAT DEFAULT 0.0")
    add_col("partner_profiles", "total_reviews", "INTEGER DEFAULT 0")

    print("- DB columns verified and updated!")

import psycopg2

conn = psycopg2.connect("postgresql://user:password@localhost/payment")
conn.autocommit = True
cur = conn.cursor()

def add_col(table, col, def_val):
    try:
        cur.execute(f"ALTER TABLE {table} ADD COLUMN {col} {def_val}")
        print(f"Added {col} to {table}")
    except Exception as e:
        pass # Probably already exists

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
add_col("partner_profiles", "team_members", "JSON DEFAULT '[]'")
add_col("partner_profiles", "selected_services", "JSON DEFAULT '[]'")
add_col("partner_profiles", "custom_skills", "JSON DEFAULT '[]'")
add_col("partner_profiles", "average_rating", "FLOAT DEFAULT 0.0")
add_col("partner_profiles", "total_reviews", "INTEGER DEFAULT 0")

print("Done")

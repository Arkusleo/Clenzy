import os
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv

load_dotenv()

# Use direct node connection to bypass Windows DNS SRV timeouts
MONGO_URL = os.getenv("MONGO_URL", "mongodb://clenzy_admin:clenzysecure123@ac-4trbsyj-shard-00-00.jp6h69r.mongodb.net:27017,ac-4trbsyj-shard-00-01.jp6h69r.mongodb.net:27017,ac-4trbsyj-shard-00-02.jp6h69r.mongodb.net:27017/?ssl=true&replicaSet=atlas-n2tzv9-shard-0&authSource=admin&retryWrites=true&w=majority")

# Ensure the database name is specified, either in the URI or explicitly here
# If not in URI, default to "clenzy"
db_name = "clenzy"

client = None

async def get_database():
    """Dependency to get the database instance."""
    global client
    if client is None:
        client = AsyncIOMotorClient(MONGO_URL)
    return client[db_name]

# Helper to easily convert ObjectId to string in responses
def str_object_id(obj_id):
    return str(obj_id) if obj_id else None
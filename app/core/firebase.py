import firebase_admin
from firebase_admin import credentials
import os
import logging

logger = logging.getLogger(__name__)

# def init_firebase():
#     if firebase_admin._apps:
#         return  # 이미 초기화됨
#
#     if os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
#         logger.info("Initializing Firebase with service account file")
#         cred = credentials.Certificate(
#             os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
#         )
#         firebase_admin.initialize_app(cred)
#     else:
#         logger.info("Initializing Firebase with GCP default credentials")
#         firebase_admin.initialize_app()

def init_firebase():
    if firebase_admin._apps:
        return

    logger.info("Initializing Firebase with GCP default credentials")
    firebase_admin.initialize_app()
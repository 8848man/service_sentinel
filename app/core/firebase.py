# import firebase_admin
# from firebase_admin import credentials
# import os
# import logging
#
# logger = logging.getLogger(__name__)
#
# # def init_firebase():
# #     if firebase_admin._apps:
# #         return  # 이미 초기화됨
# #
# #     if os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
# #         logger.info("Initializing Firebase with service account file")
# #         cred = credentials.Certificate(
# #             os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
# #         )
# #         firebase_admin.initialize_app(cred)
# #     else:
# #         logger.info("Initializing Firebase with GCP default credentials")
# #         firebase_admin.initialize_app()
#
# def init_firebase():
#     if firebase_admin._apps:
#         return
#
#     logger.info("Initializing Firebase with service account credentials")
#     firebase_admin.initialize_app()

import os
import json
import logging
from firebase_admin import credentials
import firebase_admin

logger = logging.getLogger(__name__)


def init_firebase():
    if firebase_admin._apps:
        return

    firebase_json = os.getenv("FIREBASE_CREDENTIALS_JSON")

    if firebase_json:
        logger.info("Using Firebase credentials from environment variable")
        cred_dict = json.loads(firebase_json)
        logger.info(f"Firebase project: {cred_dict.get('project_id')}")
        cred = credentials.Certificate(cred_dict)
        firebase_admin.initialize_app(cred)
    else:
        logger.info("Using default credentials")
        firebase_admin.initialize_app()

    app = firebase_admin.get_app()
    logger.info(f"✅ Firebase initialized with project: {app.project_id}")
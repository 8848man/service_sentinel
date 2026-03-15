# Tech Stack

## Backend (Python)
See `requirements.txt` for full dependency list.

- **Web framework**: FastAPI 0.110.0
- **ASGI server**: Uvicorn 0.29.0
- **ORM**: SQLAlchemy 2.0.25
- **Migrations**: Alembic 1.13.1
- **Validation**: Pydantic 2.6.1
- **HTTP client**: HTTPX 0.27.0 (with HTTP/2)
- **Scheduling**: APScheduler 3.10.4
- **Auth**: python-jose (JWT), passlib (bcrypt), firebase-admin
- **Testing**: pytest, pytest-asyncio

## Frontend (Flutter)
See `pubspec.yaml` for full dependency list.

- **Flutter SDK**: >=3.3.0
- **State management**: Riverpod 2.5.1 (with code generation)
- **Routing**: go_router 14.2.0
- **Network**: Dio 5.4.3
- **Local storage**: shared_preferences, flutter_secure_storage, Hive
- **Code generation**: build_runner, freezed, json_serializable
- **i18n**: flutter_localizations + intl

## Infrastructure
- **Database**: PostgreSQL
- **ASGI server**: Uvicorn

## External Services
- **Auth**: Firebase Auth + Google Sign-In
- **Push notifications**: FCM (firebase_messaging / firebase-admin)
- **AI**: Google Gemini (google-generativeai 0.3.2)

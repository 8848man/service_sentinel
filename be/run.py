#!/usr/bin/env python
"""
Quick start script for ServiceSentinel Backend
"""
import os
import sys


def check_env_file():
    """Check if .env file exists, create from template if not"""
    if not os.path.exists('.env'):
        if os.path.exists('.env.example'):
            print("⚠️  .env file not found. Creating from .env.example...")
            with open('.env.example', 'r') as example:
                with open('.env', 'w') as env:
                    env.write(example.read())
            print("✅ .env file created. Please edit it with your configuration.")
            return False
        else:
            print("❌ Neither .env nor .env.example found!")
            return False
    return True


def check_requirements():
    """Check if requirements are installed"""
    try:
        import fastapi
        import sqlalchemy
        import httpx
        import apscheduler
        print("✅ All required packages are installed")
        return True
    except ImportError as e:
        print(f"❌ Missing package: {e.name}")
        print("Run: pip install -r requirements.txt")
        return False


def main():
    """Main entry point"""
    print("=" * 50)
    print("ServiceSentinel Backend - Quick Start")
    print("=" * 50)
    print()

    # Check environment
    if not check_env_file():
        print("\n⚠️  Please configure .env file and run again")
        return

    # Check requirements
    if not check_requirements():
        print("\n⚠️  Please install requirements and run again")
        return

    print("\n" + "=" * 50)
    print("Starting ServiceSentinel...")
    print("=" * 50)
    print("\nAPI Documentation will be available at:")
    print("  📖 http://localhost:8000/docs")
    print("  📖 http://localhost:8000/redoc")
    print("\nPress Ctrl+C to stop\n")

    # Run uvicorn
    os.system("uvicorn app.main:app --reload --host 0.0.0.0 --port 8000")


if __name__ == "__main__":
    main()

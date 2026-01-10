#!/usr/bin/env python
"""
Verification script for ServiceSentinel setup
Run this to check if everything is configured correctly
"""

import os
import sys


def check_python_version():
    """Check if Python version is compatible"""
    print("🐍 Checking Python version...")
    version = sys.version_info
    if version.major == 3 and version.minor >= 10:
        print(f"   ✅ Python {version.major}.{version.minor}.{version.micro} - OK")
        return True
    else:
        print(f"   ❌ Python {version.major}.{version.minor}.{version.micro} - Requires Python 3.10+")
        return False


def check_required_files():
    """Check if all required files exist"""
    print("\n📁 Checking required files...")
    required_files = [
        "requirements.txt",
        ".env.example",
        "app/main.py",
        "app/core/config.py",
        "app/core/database.py",
    ]

    all_exist = True
    for file_path in required_files:
        if os.path.exists(file_path):
            print(f"   ✅ {file_path}")
        else:
            print(f"   ❌ {file_path} - Missing!")
            all_exist = False

    return all_exist


def check_env_file():
    """Check if .env file exists"""
    print("\n⚙️  Checking environment configuration...")
    if os.path.exists('.env'):
        print("   ✅ .env file exists")
        return True
    else:
        print("   ⚠️  .env file not found")
        print("   ℹ️  Run: cp .env.example .env (or copy on Windows)")
        return False


def check_dependencies():
    """Check if required packages are installed"""
    print("\n📦 Checking dependencies...")

    packages = {
        'fastapi': 'FastAPI',
        'sqlalchemy': 'SQLAlchemy',
        'pydantic': 'Pydantic',
        'uvicorn': 'Uvicorn',
        'httpx': 'httpx',
        'apscheduler': 'APScheduler',
    }

    all_installed = True
    for package, name in packages.items():
        try:
            __import__(package)
            print(f"   ✅ {name}")
        except ImportError:
            print(f"   ❌ {name} - Not installed")
            all_installed = False

    if not all_installed:
        print("\n   ℹ️  Run: pip install -r requirements.txt")

    return all_installed


def check_database_config():
    """Check database configuration"""
    print("\n🗄️  Checking database configuration...")

    if not os.path.exists('.env'):
        print("   ⚠️  Cannot check - .env file not found")
        return False

    with open('.env', 'r') as f:
        content = f.read()
        if 'DATABASE_URL' in content:
            print("   ✅ DATABASE_URL configured")
            return True
        else:
            print("   ⚠️  DATABASE_URL not found in .env")
            return False


def check_directory_structure():
    """Check if directory structure is correct"""
    print("\n📂 Checking directory structure...")

    directories = [
        "app",
        "app/api",
        "app/core",
        "app/models",
        "app/repositories",
        "app/schemas",
        "app/services",
        "tests",
    ]

    all_exist = True
    for directory in directories:
        if os.path.isdir(directory):
            print(f"   ✅ {directory}/")
        else:
            print(f"   ❌ {directory}/ - Missing!")
            all_exist = False

    return all_exist


def print_summary(results):
    """Print summary of checks"""
    print("\n" + "="*50)
    print("📊 VERIFICATION SUMMARY")
    print("="*50)

    total = len(results)
    passed = sum(results.values())

    for check, status in results.items():
        icon = "✅" if status else "❌"
        print(f"{icon} {check}")

    print("="*50)
    print(f"Passed: {passed}/{total}")

    if passed == total:
        print("\n🎉 All checks passed! You're ready to go!")
        print("\nNext steps:")
        print("1. Run: python run.py")
        print("2. Visit: http://localhost:8000/docs")
    else:
        print("\n⚠️  Some checks failed. Please fix the issues above.")
        print("\nQuick fix commands:")
        print("1. pip install -r requirements.txt")
        print("2. cp .env.example .env")
        print("3. Edit .env with your configuration")


def main():
    """Main verification function"""
    print("="*50)
    print("🔍 ServiceSentinel Setup Verification")
    print("="*50)

    results = {
        "Python Version": check_python_version(),
        "Required Files": check_required_files(),
        "Environment File": check_env_file(),
        "Dependencies": check_dependencies(),
        "Database Config": check_database_config(),
        "Directory Structure": check_directory_structure(),
    }

    print_summary(results)

    # Return 0 if all passed, 1 otherwise
    return 0 if all(results.values()) else 1


if __name__ == "__main__":
    sys.exit(main())

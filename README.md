# Jedweli Mobile 🗓️

A schedule management mobile application designed to help users efficiently organize their schedules. This project was developed as part of a university assignment, with both a Flutter frontend and a Django backend that handles scheduling, user authentication, and data management.

## Table of Contents

- [📖Project Overview](#project-overview)
- [⚙️Backend Setup](#backend-setup)
- [📱Frontend Setup](#frontend-setup)

## 📖Project Overview

Jedweli Mobile allows users to:

- Create, update, and delete schedules for various activities
- Create, update, and delete classes or events
- Share schedules with others and grant them access

The app consists of:
- A Flutter frontend (built using Dart)
- A Django REST Framework backend (Python)

## ⚙️Backend Setup

To run the Django backend, follow these steps:

1. Navigate to the backend folder:
```bash
cd backend
pipenv install
pipenv shell
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

The API should now be running at `http://0.0.0.0:8000/`

## 📱Frontend Setup

To run the Flutter mobile app, follow these steps:

1. Navigate to the frontend folder:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:

For Android:
```bash
flutter run --android
```

For iOS:
```bash
flutter run --ios
```

## 🚀 Happy Coding & Thank You for Reviewing!

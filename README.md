# Agency Manager 

**Agency Manager** is a full-stack production-ready application designed to streamline operations for digital agencies. Built with **Flutter (Frontend)** and **Django (Backend)**, it offers a complete suite of tools for project tracking, financial management, and client relations.

## Key Features

### 1. Smart Dashboard & Analytics
- **Real-time Stats:** Track active vs. completed projects instantly.
- **Financial Overview:** View Total Revenue, Expenses, and Net Profit calculations in real-time.
- **Risk Analysis:** Automatic "High Risk" alerts for projects with approaching deadlines but low progress.

### 2. Financial Management (Expense & Profit)
- **Budget vs. Expense:** Track project budgets and log detailed expenses (e.g., Server costs, Assets).
- **Profit Calculation:** Automatically calculates **Net Profit** (Budget - Expense) and displays it with color-coded indicators (Green for Profit, Red for Loss).

### 3. Automated PDF Invoicing
- **One-Click Invoice:** Generates professional PDF invoices with "ScalerVerse" branding.
- **Detailed Breakdown:** Includes project details, itemized expense history, and grand totals.
- **Shareable:** Ready to print or email to clients directly from the app.

### 4. CRM & Client Communication
- **Direct Actions:** Call or Email clients directly from the app.
- **Client Rating System:** Rate clients (1-5 Stars) to keep track of experience.
- **Resource Management:** Store and access multiple project links (Figma, Drive, Trello) in one place.

### 5. Project Lifecycle Management
- **Phase Tracking:** Update project status (Planning -> Designing -> Development -> Testing -> Deployed).
- **Progress Slider:** Visual slider to track completion percentage (0-100%).
- **History Log:** Keeps a detailed history of all expenses added to a project.

---

## Tech Stack

- **Frontend:** Flutter (Dart), Material Design 3, Provider, PDF & Printing packages.
- **Backend:** Django REST Framework (Python), SQLite (Dev).
- **Architecture:** MVVM (Frontend), REST API (Communication).

---

##  How to Run Locally

### 1. Backend Setup (Django)
```bash
# Navigate to backend folder
cd agency_backend

# Install dependencies (ensure venv is active)
pip install django djangorestframework django-cors-headers

# Run Migrations
python manage.py makemigrations
python manage.py migrate

# Start Server
python manage.py runserver 0.0.0.0:8000

```

### 2. Frontend Setup (Flutter)

```bash
# Navigate to app folder
cd agency_app

# Get dependencies
flutter pub get

# Run App (Ensure Backend is running)
flutter run
```

###  Developed By

**Md. Shafiul Alam Sagar**
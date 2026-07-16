🚗 CarWash Pro - Flutter & Node.js
CarWash Pro is a modern, full-stack mobile application designed to connect customers with nearby car wash services. It features real-time GPS tracking, Google Maps integration, an automated booking system, and a comprehensive Admin Dashboard to manage the entire workflow.

Built specifically with the Ethiopian market in mind, featuring local phone number validation and reverse-geocoding for accurate address fetching.

FlutterNode.jsMySQLLicense

✨ Features
📱 Customer App
Instant Booking Form: No registration required. Customers can book a wash in seconds using Name, Phone, and Vehicle Type.
GPS Location: Automatically fetches the customer's exact location.
Ethiopian Phone Validation: Strict regex validation for Ethiopian phone numbers (e.g., 0912345678 or +251912345678).
Nearby Search: Interactive Google Maps integration to view approved car washes nearby.
Reverse Geocoding: Automatically converts raw GPS coordinates into readable street addresses (e.g., "Bole, Addis Ababa").
Premium UI: Clean, modern UI with a professional "Fast & Energetic" blue theme and floating card designs.
🛠️ Admin Dashboard (Secret Access)
3-Step Workflow System:
Pending: View incoming requests, edit details, assign a worker, and approve.
Approved: View approved jobs and mark them as washed.
Washed/Completed: View completed jobs and print/save PDF receipts.
Direct Calling: One-tap button to call the customer directly from the app.
Location Tracking: View the exact GPS address of the customer.
PDF Receipt Generation: Generate and print professional receipts for washed cars.
Data Editing: Admins can correct typos in customer names, change times, or update vehicle types before approving.
🛠️ Tech Stack
Frontend: Flutter, Dart
Backend: Node.js, Express.js
Database: MySQL (MariaDB), mysql2 (Promise-based)
State Management: Provider
Maps & Location: google_maps_flutter, geolocator
API Integration: dio (HTTP Client)
Utilities: url_launcher (Calling/Maps), printing & pdf (Receipts), intl (Date formatting)
Geocoding: OpenStreetMap Nominatim API (Free)
📂 Project Structure
├── carwash-backend/          # Node.js Server│   ├── src/│   │   ├── config/│   │   │   └── database.js   # MySQL Connection Pool│   │   ├── controllers/│   │   │   ├── authController.js│   │   │   ├── bookingController.js│   │   │   └── carWashController.js│   │   ├── routes/│   │   │   ├── authRoutes.js│   │   │   ├── bookingRoutes.js│   │   │   └── carWashRoutes.js│   │   └── app.js│   ├── .env                  # Environment Variables│   └── package.json│└── carwash_app/              # Flutter Application    ├── lib/    │   ├── main.dart    │   ├── models/            # Data Models    │   ├── screens/    │   │   ├── auth/          # (Removed, no login needed)    │   │   ├── booking/       # Customer booking form    │   │   ├── carwash/       # Map & details    │   │   └── admin/         # Admin dashboard & details    │   ├── services/          # API & Dio services    │   ├── providers/         # State management    │   └── utils/             # Constants    └── pubspec.yaml
🚀 Getting Started
Prerequisites
Node.js (v18+ recommended for native fetch)
Flutter SDK
MySQL Server / MariaDB
Android Studio / VS Code
A physical Android device or Emulator.
1. Database Setup
Open your MySQL client (Workbench, phpMyAdmin, etc.) and run the database.sql file to create the schema and tables.
(Note: Make sure to create the database carwash_db first).

2. Backend Setup
# Navigate to the backend folder
cd carwash-backend

# Install dependencies
npm install

# Configure environment variables
# Rename .env.example to .env and add your DB credentials and JWT secret
npm run dev
The server will start on http://localhost:3001.

3. Flutter App Setup
# Navigate to the app folder
cd carwash_app

# Install dependencies
flutter pub get

# Update IP Address!
# IMPORTANT: Go to lib/services/api_service.dart and lib/utils/constants.dart
# Change the IP address (e.g., 192.168.1.X) to your computer's local IP.

# Run the app
flutter run
🔑 Environment Variables
Create a .env file in the carwash-backend directory:
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=carwash_db

JWT_SECRET=your_super_secret_jwt_key
📡 API Endpoints
Bookings (Public)
POST /api/bookings - Create a new guest booking.
GET /api/bookings?status=pending - Get bookings by status (Used by Admin).
PUT /api/bookings/:id - Update booking status/details (Used by Admin).
Car Washes (Public)
GET /api/carwashes - Get all active car washes for the map.
Auth (Currently Disabled in UI)
POST /api/auth/register
POST /api/auth/login
📸 Screenshots
(Add screenshots of your app here! For example:)

Splash Screen with Blue Gradient
Customer Booking Form
Google Maps View with Red Pins
Admin Dashboard (3 Tabs)
PDF Receipt Generation
🚧 Future Enhancements
Payment Gateway Integration: Add Telebirr or CBE Birr payment options.
Push Notifications: Notify admin instantly when a new request arrives.
Cloud Hosting: Deploy backend to Render/Railway and app to Google Play Store.
Admin Authentication: Secure the admin panel with a proper login system instead of a hardcoded password.
Car Wash Provider App: A separate app for car wash owners to manage their own bookings.
🤝 Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

📝 License
This project is licensed under the MIT License.

Made with ❤️ in Ethiopia

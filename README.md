FitSugar 
A Flutter-based mobile application for tracking sugar content in food products
FitSugar helps health-conscious users monitor their daily sugar intake by providing an easy way to search for food products and track their sugar content over time.


✨ Features
🔍 Product Search & Tracking

Barcode Scanning: Scan product barcodes to instantly get nutritional information
Text Search: Search for food products by name using the Open Food Facts database
Auto-Save: Automatically saves product information to your personal history

📊 Sugar Analytics

Weekly Chart: Visual representation of your daily sugar intake over the past 7 days
History Tracking: Complete log of all food entries with timestamps
Color-Coded Levels: Sugar amounts are color-coded (Green: ≤5g, Orange: 5-10g, Red: >20g)

👤 User Management

Firebase Authentication: Secure user registration and login
Profile Management: Edit personal information and account settings
Remember Me: Convenient login with saved credentials
Offline Support: App works offline with local data caching

🎨 Modern UI/UX

Material Design: Clean, intuitive interface with pink accent theme
Responsive Layout: Optimized for various screen sizes
Smooth Animations: Polished user experience with transitions
Dark/Light Support: Adaptive design elements

🛠️ Technical Stack
Frontend

Flutter - Cross-platform mobile development
Provider - State management
Material Design - UI components and theming

Backend & Services

Firebase Authentication - User management
Cloud Firestore - Real-time database for user data
Open Food Facts API - Product nutrition database
Connectivity Plus - Network status monitoring

Key Packages

firebase_core & firebase_auth - Firebase integration
cloud_firestore - Database operations
barcode_scan2 - QR/Barcode scanning functionality
fl_chart - Data visualization for sugar intake charts
connectivity_plus - Network connectivity detection
http - API communications
shared_preferences - Local data persistence

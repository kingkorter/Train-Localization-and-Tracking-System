# 🚆 Train Localization and Tracking System

This project implements a **Train Localization and Tracking System** using:

- **Embedded system (C++)** – code in `train_localization.ino`
- **Flutter mobile app (Dart)** – displays real-time train location, calculates distances, and visualizes danger zones on a map
- **Cloud interface (ThingSpeak)** – optional web dashboard for monitoring

The system combines GPS and RFID data to track the train’s movement and supports **emergency alerts**.

---

## 📱 Mobile App Features

1. **Real-Time Location**
   - Displays the train’s longitude and latitude (updates every 20 seconds)
   - Falls back to RFID-based location if GPS is unavailable

2. **Distance to Destination**
   - Enter destination coordinates
   - App calculates distance from current train location

3. **Map Visualization**
   - Map shows current location and danger zones
   - Red markers indicate danger zones

4. **Emergency Alerts**
   - When the embedded system triggers an emergency, the app displays an alert
   - Authorities are notified automatically (if configured)

---

## 🌐 Web Dashboard (Optional)

- The system can send location data to ThingSpeak:
  - Example: https://thingspeak.com/channels/2322010
- Use for monitoring historical data or analytics

---

## 🛠️ Technologies Used

- **Embedded C++** (Arduino)
- **Flutter & Dart** (Mobile app)
- **ThingSpeak API** (Web dashboard)
- **GPS & RFID integration**

---

## 📌 Notes

- The embedded system code is in `embedded/train_localization.ino`.
- The mobile app can be run independently for simulation or testing.
- No hardware is required to explore the app or review the code.

---

## 👤 Author

**King Korter**

This project demonstrates skills in:
- Embedded systems
- Mobile app development (Flutter/Dart)
- IoT-based tracking and alerts
- Integration of GPS/RFID with cloud monitoring

---

## 📜 License

Educational and research purposes only.


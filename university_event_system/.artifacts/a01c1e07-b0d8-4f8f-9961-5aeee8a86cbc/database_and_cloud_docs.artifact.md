# 📄 Database Architecture & Google Cloud Drive Working Guide

This artifact provides a complete technical documentation of the SQLite local database system and Google Cloud Drive Backup & Restore integration for the **University Event Management System**.

---

## 🗄️ 1. SQLite Database Architecture

The local database is stored as **`university_events.db`** using SQLite.

### 📐 Table Structures & Schemas

#### 1. `users` Table
Stores authentication and profile details for all three roles (**admin**, **student**, **guard**).

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique User ID |
| `name` | `TEXT` | `NOT NULL` | Full Name |
| `roll_number` | `TEXT` | `UNIQUE` | Roll Number (Students only, e.g. `FA24-BSE-127`) |
| `email` | `TEXT` | `UNIQUE NOT NULL` | Login Email Address |
| `password_hash` | `TEXT` | `NOT NULL` | SHA-256 Hashed Password |
| `password_salt` | `TEXT` | `NOT NULL` | 16-byte Cryptographic Salt |
| `role` | `TEXT` | `NOT NULL` | Access Role (`admin`, `student`, `guard`) |

#### 2. `events` Table
Stores university event schedules, venues, ticket pricing, and capacity.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique Event ID |
| `title` | `TEXT` | `NOT NULL` | Event Title |
| `description` | `TEXT` | `NOT NULL` | Detailed Description |
| `category` | `TEXT` | `NOT NULL` | Category (`Academic`, `Sports`, `Cultural`, etc.) |
| `event_date` | `TEXT` | `NOT NULL` | Date (`YYYY-MM-DD`) |
| `event_time` | `TEXT` | `NOT NULL` | Time (`HH:MM AM/PM`) |
| `venue` | `TEXT` | `NOT NULL` | Event Location / Hall |
| `ticket_price` | `REAL` | `NOT NULL` | Ticket Price in PKR |
| `capacity` | `INTEGER` | `NOT NULL` | Maximum Seats / Capacity |
| `created_by` | `INTEGER` | `FOREIGN KEY (users.id)` | Admin User ID who created the event |

#### 3. `registrations` Table
Tracks student registrations for events.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique Registration ID |
| `student_id` | `INTEGER` | `FOREIGN KEY (users.id)` | Student ID |
| `event_id` | `INTEGER` | `FOREIGN KEY (events.id)` | Event ID |
| `status` | `TEXT` | `NOT NULL` | Registration Status (`Pending`, `Approved`, `Rejected`) |
| `registration_date` | `TEXT` | `NOT NULL` | Timestamp |

#### 4. `payments` Table
Tracks student payment submissions and admin verification status.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique Payment ID |
| `registration_id` | `INTEGER` | `FOREIGN KEY (registrations.id)` | Linked Registration ID |
| `amount` | `REAL` | `NOT NULL` | Amount Paid |
| `payment_method` | `TEXT` | `NOT NULL` | Payment Method (`EasyPaisa`, `JazzCash`, `Bank`) |
| `transaction_reference` | `TEXT` | `NOT NULL` | Transaction Reference / TID |
| `payment_status` | `TEXT` | `NOT NULL` | Verification Status (`Pending`, `Verified`, `Rejected`) |
| `verified_by` | `INTEGER` | `FOREIGN KEY (users.id)` | Admin ID who verified the payment |
| `verified_at` | `TEXT` | `NULLABLE` | Verification Timestamp |

#### 5. `tickets` Table
Stores issued digital tickets, verification tokens for QR codes, and entry status.

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Unique Ticket ID |
| `registration_id` | `INTEGER` | `FOREIGN KEY (registrations.id)` | Linked Registration ID |
| `ticket_code` | `TEXT` | `UNIQUE NOT NULL` | Formatted Ticket Code (e.g., `EVT-000001`) |
| `verification_token` | `TEXT` | `UNIQUE NOT NULL` | Encrypted QR Verification Token |
| `ticket_status` | `TEXT` | `NOT NULL` | Entry Status (`Valid`, `Used`, `Cancelled`) |
| `issued_at` | `TEXT` | `NOT NULL` | Issue Timestamp |
| `used_at` | `TEXT` | `NULLABLE` | Gate Entry Scan Timestamp |
| `verified_by` | `INTEGER` | `FOREIGN KEY (users.id)` | Security Guard ID who scanned the ticket |

---

## ☁️ 2. Google Cloud Drive Integration System

The cloud backup module [`GoogleDriveService`](file:///C:/Users/fiaza/.gemini/antigravity/scratch/university_event_system/lib/services/google_drive_service.dart) provides database cloud sync.

### 🔄 Backup Algorithm Step-by-Step (`uploadBackup`)

1. **OAuth 2.0 Token Check:**
   - Obtains an authenticated `http.Client` using `GoogleSignInAccount.authorizationClient`.
   - Requests `drive.file` and `drive.appdataScope` scopes.
2. **Local DB File Access:**
   - Gets path `join(await getDatabasesPath(), 'university_events.db')`.
   - Opens local file as byte stream (`File.openRead()`).
3. **Google Drive Search:**
   - Searches Google Drive for an existing file named `university_events_backup.db`:
     ```dart
     driveApi.files.list(q: "name = 'university_events_backup.db' and trashed = false");
     ```
4. **Cloud Write:**
   - If found, executes `driveApi.files.update(...)` to overwrite the existing backup.
   - If not found, executes `driveApi.files.create(...)` to create a new backup file.

### 📥 Restore Algorithm Step-by-Step (`restoreBackup`)

1. **Fetch Backup:**
   - Locates `university_events_backup.db` on Google Drive.
   - Downloads media bytes using `drive.DownloadOptions.fullMedia`.
2. **Safely Release SQLite Lock:**
   - Calls `DatabaseHelper.instance.close()` to release file handles.
3. **Write & Reopen:**
   - Overwrites local `university_events.db` file with downloaded bytes (`writeAsBytes`).
   - Re-opens database connection `DatabaseHelper.instance.database`.

---

## 🛠️ 3. Google Cloud Console Setup Steps

1. Enable **Google Drive API** in [Google Cloud Console](https://console.cloud.google.com/).
2. Create **OAuth 2.0 Web Client ID** & **Android Client ID**.
3. Register Android Package Name: `com.university.events.university_event_system` and SHA-1 Fingerprint.
4. Copy Web Client ID to `_webClientId` in `google_drive_service.dart`.

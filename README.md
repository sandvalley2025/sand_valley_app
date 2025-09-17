# 🏜️ Sand Valley App

**Sand Valley** is a Flutter-based mobile application built to manage and display agricultural resources—fertilizers, insecticides, seeds—and provide direct communication options. It features:

- 🔐 Secure, role-based admin login system (`admin` & `master`)
- 🔄 OTP-based password reset
- 🌵 Beautiful desert-themed UI
- 🧩 Modular routing structure for easy maintenance

---

## 📦 Version `v1.0.4` Updates

- ✅ **New Communication Management Section**:

  - `/communication-eng` screen with full CRUD (Create, Read, Update, Delete) support.
  - Backend integration with:
    - `POST /add-eng-data`
    - `GET /get-communication-eng/:id`
    - `POST /update-communication-eng/:placeId/:engId`
    - `DELETE /delete-communication-eng/:placeId/:engId`
  - UI includes:
    - Toggleable "Add Engineer" form with image picker, name, and phone
    - Expandable engineer cards with edit/delete capabilities
    - Styled search bar (same as Admin page)

- ✅ **Communication Categories System**:

  - Master can add new communication categories
  - Connected to backend via `POST /add-communication`
  - Uses modular `AddCommunicationSection` component with Save/Cancel actions

- ✅ **Fertilizer Nested Type Add Section**:

  - New UI section to add nested fertilizer types under existing types
  - Backend API integrated:
    - `POST /api/auth/add-fertilizer-nested-type`
  - Includes:
    - Image picker with preview
    - Validation: image, name, company, and description required
    - Polished Save/Cancel buttons with inline loading
    - Error handling with user-friendly snackbars
  - Modular widget: `AddNestedFertilizerTypeSection`

- ✅ UI Polishing:
  - Updated card designs for communication section
  - Image preview and validation in add/edit modes
  - Optimized loading and error handling indicators

---

## 📂 Project Structure

lib/<br>
├── main.dart # App entry point with Provider & SecureStorage<br>
├── routes/<br>
│ └── app_routes.dart # All named route paths<br>
├── screens/<br>
│ ├── splash/<br>
│ │ └── splash_screen.dart<br>
│ ├── home/<br>
│ │ └── home_screen.dart<br>
│ ├── admin/<br>
│ │ ├── admin_login_screen.dart<br>
│ │ ├── admin_page.dart<br>
│ │ ├── master_admin_page.dart # 🆕 Updated with 4 routing buttons<br>
│ │ ├── forgot_password_screen.dart<br>
│ │ ├── otp_screen.dart<br>
│ │ └── reset_password_screen.dart<br>
│ ├── Communicate/<br>
│ │ ├── communicate_main.dart<br>
│ │ ├── communicate_eng.dart # 🆕 Full CRUD communication engineers<br>
│ │ ├── add_communication_section.dart # 🆕 Add communication category<br>
│ │ └── communicate_call.dart<br>
│ ├── Fertilizer/<br>
│ │ ├── fertilizer_main.dart<br>
│ │ ├── fertilizer_type_one.dart<br>
│ │ ├── fertilizer_type_two.dart<br>
│ │ ├── fertilizer_description.dart<br>
│ │ └── add_nested_fertilizer_type_section.dart # 🆕 Add nested fertilizer types<br>
│ ├── Insecticide/<br>
│ │ ├── insecticide_main.dart<br>
│ │ ├── insecticide_type.dart<br>
│ │ └── insecticide_description.dart<br>
│ └── seeds/<br>
│ ├── seed_main.dart<br>
│ ├── seed_type.dart<br>
│ └── seed_description.dart<br>
├── components/<br>
│ ├── account_settings_section.dart<br>
│ ├── add_account_section.dart<br>
│ └── view_users_section.dart<br>
└── widgets/<br>
└── background_container.dart # Reusable background container + theme<br>

---

## 🚀 Features

### 🔐 Secure Admin Login

- Email/password authentication via secure Node.js backend
- `admin` → Admin Dashboard
- `master` → Master Admin Dashboard (with advanced controls)
- SecureStorage for tokens and role
- Password visibility toggle and form validation

### 🔁 OTP-Based Password Reset

- Enter email/username → API sends OTP
- OTP screen with:
  - 6-digit smart input
  - Resend button with loading and 60s cooldown
- Reset password securely with validation

### 📱 UI & UX Design

- Orange theme: `#F7941D`
- Poppins font
- Material 3 widgets and styling
- Responsive and clean layout
- Reusable background containers

### 📦 Modular Screens

- Communicate: phone, communication engineers, and text support
- Fertilizer, Insecticide, Seeds: type + description with dynamic data
- Dashboard components separated for reusability
- Expandable cards, modular add/edit sections, image picker

---

## 🔧 Dependencies

dependencies:
flutter:
sdk: flutter
provider: ^6.0.5
flutter_secure_storage: ^8.0.0
http: ^0.13.6
image_picker: ^1.0.4

---

## 👨‍💻 Author

Fares Mohameda <br>
Frontend & Backend Developer (MERN | Flutter)<br>
📧 fares.dev.m@gmail.com<br>
🔗 GitHub: fares12358<br>

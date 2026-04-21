# POULTRY_APP Technical Documentation

## 1. Project Overview

### Summary

`POULTRY_APP` is a multi-application commerce workspace built around a poultry retail and operations business. The repository contains three real product components:

- `mobile/`: the main Flutter application used by shoppers/customers and, in some cases, staff.
- `backend/`: the Node.js and Express REST API that powers catalog, authentication, orders, analytics, and administration.
- `admin-dashboard/`: a React and TypeScript browser-based admin panel for internal operations.

In addition to those three components, the repository root also contains a separate Flutter starter scaffold (`lib/`, `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`, `test/`). That root scaffold appears to be a default template and is not the main production application. The actual business application lives under `mobile/`.

### Core Purpose

The platform supports two primary business use cases:

- Customer shopping:
  Customers can browse poultry products, view prices and promotions, add items to cart, provide delivery information, place orders, and review past orders by phone number.

- Administrative operations:
  Staff members can log in to manage products, orders, customers, districts, promotions, flash offers, inventory-related data, and reporting.

### Business Logic

At a business level, the system is designed to support a direct-to-customer poultry sales workflow:

1. Product data is created and maintained by administrators.
2. Customers browse available products and promotional offers.
3. Customers place either guest orders or authenticated orders.
4. The backend validates stock, pricing, and promotions.
5. The system creates an order, reduces stock, stores the delivery data, and exposes the order for operational follow-up.
6. Admin users manage the order lifecycle from pending through delivery or cancellation.

The implementation strongly reflects a local/regional retail model with manual delivery fulfillment and no integrated online payment gateway.

## 2. System Architecture

### High-Level Architecture

The system is a classic three-tier application:

1. Presentation Layer
   - Flutter mobile app in `mobile/`
   - React admin dashboard in `admin-dashboard/`

2. Application Layer
   - Express REST API in `backend/`

3. Data Layer
   - MongoDB database accessed through Mongoose models

### Architectural Style

The backend follows a layered REST architecture:

- `routes/` handle HTTP endpoints
- `middleware/` handles authentication and shared request concerns
- `services/` contains business logic such as order placement, promotion validation, and notification sending
- `models/` defines MongoDB entities
- `config/` initializes infrastructure such as database, Cloudinary, and Firebase Admin

The Flutter mobile app follows a feature-oriented modular structure:

- shared framework concerns live in `core/`
- transport and models live in `data/`
- user-facing and admin-facing flows live under `features/`
- localization resources live under `l10n/`

The React admin dashboard follows a conventional SPA architecture:

- routing in `App.tsx`
- request handling in `src/api/`
- auth state in `src/context/`
- screens in `src/pages/`
- shared layout components in `src/layout/`

### Main Runtime Interactions

#### Mobile App to Backend

- The mobile app communicates with the backend over HTTP using JSON.
- It resolves the API base URL through Flutter `--dart-define=API_BASE=...` or local defaults.
- It uses guest mode for shopping by default, and staff mode for in-app admin access.
- Session, cart, locale, and customer profile data are persisted locally using `SharedPreferences`.

#### Admin Dashboard to Backend

- The admin dashboard uses Axios to call `/api/...` endpoints.
- It stores the admin JWT and user info in `localStorage`.
- Protected routes are enforced in the front-end and additionally protected on the backend using authentication middleware.

#### Backend to Database and External Services

- MongoDB stores users, products, orders, promotions, districts, flash offers, and order sequencing.
- Cloudinary is used for media upload/storage for admin product management.
- Firebase Admin is used server-side for push notification sending to registered FCM tokens.

### Architecture Notes

- The system has both web admin and in-app staff administration capabilities.
- Customer shopping in Flutter is primarily implemented as guest shopping, even when a customer account exists.
- Payment processing is not integrated; checkout is operational/manual rather than gateway-based.
- Firebase client setup is not present in the mobile repo, even though the backend supports FCM token registration and push sending. This suggests notification support is incomplete or planned.

## 3. Folder Structure Explanation

## Repository Root

- `.cursor/`
  Cursor-specific configuration and rules for AI-assisted development.

- `admin-dashboard/`
  React admin web application used by staff to manage business data and operations.

- `backend/`
  Node.js REST API and domain/business logic.

- `mobile/`
  Main Flutter production application.

- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`, `lib/`, `test/`
  Root Flutter scaffold. This appears to be a template app and not the main production mobile implementation.

- `docker-compose.yml`
  Local infrastructure helper for starting MongoDB in Docker.

- `pubspec.yaml`
  Root Flutter scaffold package configuration, separate from `mobile/pubspec.yaml`.

## `mobile/`

### `mobile/lib/`

- `app.dart`
  Main application composition entry. Wires providers, restores session/cart, selects the current shell, and initializes localization/theme.

- `core/`
  Cross-cutting concerns such as API base resolution, app theme, constants, locale handling, and responsive layout helpers.

- `data/`
  Shared API client and domain models used across features.

- `features/`
  Feature-first module organization.

- `l10n/`
  Internationalization resources and generated localization classes for English and Arabic.

- `widgets/`
  Reusable presentation widgets used across screens.

### `mobile/lib/features/`

- `admin/`
  In-app staff/admin features including products, orders, users, customers, districts, stock, flash offers, and reports.

- `auth/`
  Login, sign-up, local customer profile persistence, and session state.

- `cart/`
  Cart models and cart state persistence.

- `common/`
  Shared feature-level widgets such as WhatsApp integration UI.

- `orders/`
  Customer order history and order detail views.

- `profile/`
  Customer profile display and logout flow.

- `shell/`
  Main shopper shell and application navigation structure.

- `shop/`
  Product browsing, product details, cart, checkout, flash offers, and repository methods.

- `splash/`
  Splash/loading experience while restoring app state.

## `backend/`

### `backend/src/`

- `app.js`
  Express app setup, middleware registration, route mounting, CORS handling, and error middleware.

- `server.js`
  Process startup, database connection, Cloudinary configuration, Firebase Admin initialization, and server binding.

- `config/`
  Infrastructure initialization such as MongoDB, Cloudinary, and Firebase Admin.

- `middleware/`
  Shared request middleware, especially authentication and admin authorization.

- `models/`
  Mongoose schemas and collections.

- `routes/`
  Public, authenticated customer, and admin-only HTTP route definitions.

- `services/`
  Business logic services such as order placement, promotions, and notifications.

- `scripts/`
  Seed scripts for demo users, admin account, catalog data, and districts.

- `utils/`
  Utility helpers such as localized product naming.

### `backend/src/routes/admin/`

Contains admin-only CRUD and operational endpoints, including:

- users
- products
- orders
- customers
- promotions
- analytics
- upload
- flash offers
- districts

## `admin-dashboard/`

### `admin-dashboard/src/`

- `App.tsx`
  Route tree and route guarding.

- `api/`
  Axios client and request configuration.

- `context/`
  React context for auth and session state.

- `layout/`
  Shared admin shell layout.

- `pages/`
  Core admin screens such as login, dashboard, orders, products, customers, promotions, analytics, and users.

- `ui/`
  Shared admin dashboard UI components.

- `assets/`
  Static assets for the admin application.

## 4. Features Breakdown

## Customer-Facing Features

### 4.1 Welcome and Entry Flow

User perspective:
- Users can start shopping immediately as guests.
- Users can sign in with phone and password.
- New users can create an account.
- In demo mode, the app can expose demo admin and demo customer shortcuts.

System perspective:
- The app starts in a welcome/login page if no active session is restored.
- `AuthController` decides whether the user is in guest shopping mode or staff mode.
- Customer login does not primarily switch the app into a fully token-based customer mode; instead, it hydrates guest shopping data and continues through the shopping experience.

### 4.2 Product Browsing

User perspective:
- Customers can browse available poultry products.
- They can search by keyword.
- They can review promotional/flash offer content.

System perspective:
- Product data is loaded through `ShopRepository.fetchProducts()`.
- The repository calls `/api/products` with optional filters.
- In demo mode, products are loaded from in-app mock data.

### 4.3 Product Details

User perspective:
- Customers can open a product detail page to review pricing, stock-related constraints, images, and quantity options.

System perspective:
- Product details are loaded through `/api/products/:id`.
- UI logic enforces quantity selection based on stock and `maxOrderQty`.

### 4.4 Cart Management

User perspective:
- Customers can add items to cart, adjust quantity, remove items, and review subtotal.

System perspective:
- `CartController` stores cart lines in memory and persists them in `SharedPreferences`.
- Cart state is restored when the app launches.

### 4.5 Sign-Up and Customer Profile Capture

User perspective:
- Customers can create an account by entering name, family name, phone, password, district, city, address, and optional delivery notes.

System perspective:
- Registration is performed through `POST /api/auth/register`.
- The app also persists customer contact and address details locally for checkout continuity.

### 4.6 Checkout and Order Placement

User perspective:
- Customers proceed to checkout from the cart.
- They provide or reuse saved delivery information.
- They submit an order and are redirected to order history after success.

System perspective:
- The primary Flutter flow uses guest order creation through `POST /api/orders/guest`.
- The backend validates products, quantities, stock, and optional promo code rules.
- Stock is decremented during order creation.
- Order number generation occurs server-side.

### 4.7 Order History

User perspective:
- Customers can review previous orders associated with their phone number.

System perspective:
- The app queries `/api/orders/guest/by-phone/:phone`.
- Authenticated customer order endpoints also exist, but the visible customer flow is centered around guest order history.

### 4.8 Profile

User perspective:
- Customers can review locally stored profile and address information.
- They can log out and clear the local session/cart state.

System perspective:
- Profile data is derived largely from locally saved customer data.
- Logout clears staff session, guest session, local profile, cart, and last-order local values.

### 4.9 Localization

User perspective:
- The application supports English and Arabic.
- Users can switch language directly from an overlay control.

System perspective:
- `LocaleController` manages the selected locale.
- Localization is generated via Flutter localization tooling.
- Product names/descriptions support multilingual fields.

### 4.10 WhatsApp Support Shortcut

User perspective:
- Users can access a WhatsApp support/contact action from the app shell.

System perspective:
- `url_launcher` is used to deep-link into WhatsApp.

## Admin / Staff Features

### 4.11 Staff Authentication

User perspective:
- Staff log in with phone and password to access administrative functionality.

System perspective:
- Staff authentication uses `/api/auth/login` in Flutter and `/api/admin/auth/login` in the React dashboard.
- Staff roles include `admin`, `app_admin`, and `ops_admin`.
- Role checking determines whether admin screens are available.

### 4.12 Order Management

User perspective:
- Staff can view all orders, inspect order details, update order status, assign delivery handlers, and provide cancellation reasons.

System perspective:
- Admin endpoints expose order lists, details, status update actions, and delivery assignment actions.
- Order statuses include `pending`, `confirmed`, `preparing`, `on_the_way`, `delivered`, and `cancelled`.

### 4.13 Product Management

User perspective:
- Staff can create, edit, activate/deactivate, and manage product catalog entries including prices, images, descriptions, stock, and multilingual fields.

System perspective:
- Product CRUD is available through `/api/admin/products`.
- Upload support is available through `/api/admin/upload`.
- Cloudinary is used when image upload configuration is present.

### 4.14 Customer Management

User perspective:
- Staff can browse customer records and inspect customer-level details.

System perspective:
- Customer management is provided under `/api/admin/customers`.
- Customers are stored in the `User` model with `role: customer`.

### 4.15 User Management

User perspective:
- Administrators can manage staff users and operational access.

System perspective:
- User CRUD is available under `/api/admin/users`.

### 4.16 Promotions and Flash Offers

User perspective:
- Customers see discounts and time-limited offers.
- Staff can create and manage promotional campaigns.

System perspective:
- Standard promo codes are managed through `/api/admin/promotions`.
- Flash offers are managed through `/api/admin/flash-offers`.
- Flash offers contain timing, quantity, and usage controls.

### 4.17 District Management

User perspective:
- Staff can control delivery service regions/districts.

System perspective:
- Districts are managed under `/api/admin/districts`.
- District data is also exposed publicly for customer-side selection.

### 4.18 Reporting and Analytics

User perspective:
- Staff can review high-level operational metrics and reports.

System perspective:
- Analytics endpoints include summary, sales, products, customers, and orders.
- Admin reporting is available both in Flutter admin screens and the React dashboard.

## 5. User Flow

## 5.1 Customer Shopping Flow

1. User opens the Flutter app.
2. The app restores locale, auth/session mode, and cart from `SharedPreferences`.
3. If no active session exists, the app shows the welcome/login screen.
4. The user chooses one of:
   - start shopping as guest
   - sign in with phone/password
   - create a new account
5. The user lands in the main shopper shell.
6. The user browses products, searches, and opens product detail screens.
7. The user adds one or more items to the cart.
8. The user reviews the cart and proceeds to checkout.
9. If required customer/contact data is missing, the app prompts for sign-up or profile completion.
10. The app submits the order to the backend.
11. The backend validates stock and promotion rules, creates the order, and returns the order payload.
12. The app clears the cart and navigates the user to order history or confirmation flow.

## 5.2 Returning Customer Flow

1. The app restores previously saved local customer data.
2. The user enters the shopping shell directly if shopping mode is still active.
3. The user can continue shopping, check order history by saved phone, or review profile data.

## 5.3 Staff Flow in Flutter

1. Staff signs in through the mobile login flow.
2. The backend returns a staff token and role.
3. `AuthController` stores the staff session.
4. The app routes the session to `AdminShell`.
5. Staff navigates between orders, products, customers, reports, and other admin modules.

## 5.4 Staff Flow in Web Admin Dashboard

1. Staff opens the admin dashboard.
2. The login screen posts credentials to `/api/admin/auth/login`.
3. JWT and user data are persisted in `localStorage`.
4. Protected routes become available.
5. Staff uses dashboard pages for operational management.

## 6. API / Backend Integration

## 6.1 API Style

- Protocol: HTTP/JSON
- Server framework: Express
- Authentication: Bearer JWT
- Authorization: middleware-based role enforcement
- Data format: JSON request/response bodies

## 6.2 Public and Customer-Facing Endpoints

### Health

- `GET /health`
  Returns API health status.

### Authentication

- `POST /api/auth/register`
  Registers a customer account.

- `POST /api/auth/login`
  Logs in a user. Depending on role, the client treats the response as customer or staff access.

### Catalog and Discovery

- `GET /api/products`
  Lists products, optionally filtered.

- `GET /api/products/:id`
  Returns product details.

- `GET /api/flash-offers`
  Lists current flash offers.

- `GET /api/districts`
  Lists available districts.

### Guest Order Flow

- `POST /api/orders/guest`
  Creates a guest order.

- `GET /api/orders/guest/by-phone/:phone`
  Returns guest order history by phone number.

## 6.3 Authenticated Customer Endpoints

- `GET /api/me`
  Returns current customer profile.

- `PATCH /api/me`
  Updates current customer profile.

- `POST /api/me/fcm-token`
  Registers a device notification token.

- `DELETE /api/me/fcm-token`
  Removes a device notification token.

- `POST /api/orders`
  Creates an authenticated customer order.

- `GET /api/orders`
  Lists authenticated customer orders.

- `GET /api/orders/:id`
  Gets a single order.

## 6.4 Admin Endpoints

### Admin Authentication

- `POST /api/admin/auth/login`

### Admin Modules

- `GET/POST/PATCH/DELETE /api/admin/users`
- `GET/POST/PATCH/DELETE /api/admin/products`
- `GET /api/admin/orders`
- `GET /api/admin/orders/:id`
- `PATCH /api/admin/orders/:id/status`
- `PATCH /api/admin/orders/:id/delivery`
- `GET/POST/PATCH/DELETE /api/admin/customers`
- `GET /api/admin/customers/:id`
- `GET/POST/PATCH/DELETE /api/admin/promotions`
- `GET /api/admin/analytics/summary`
- `GET /api/admin/analytics/sales`
- `GET /api/admin/analytics/products`
- `GET /api/admin/analytics/customers`
- `GET /api/admin/analytics/orders`
- `POST /api/admin/upload`
- `GET/POST/PATCH/DELETE /api/admin/flash-offers`
- `PATCH /api/admin/flash-offers/:id/toggle`
- `GET/POST/PATCH/DELETE /api/admin/districts`

## 6.5 Backend Data Flow

### Product Retrieval

1. Client requests products from `/api/products`.
2. Backend queries the `Product` collection.
3. Backend serializes the matching records.
4. Client renders product cards and details.

### Order Placement

1. Client submits order payload.
2. Backend validates product IDs and requested quantities.
3. Backend checks stock and maximum order quantity per product.
4. Backend computes subtotal, delivery fee, and optional promotion discount.
5. Backend decrements inventory.
6. Backend creates the order document.
7. Backend increments promotion usage if applicable.
8. Backend optionally sends push notifications for authenticated customer orders.
9. Backend returns the created order to the client.

### Media Upload

1. Admin dashboard or admin flow uploads an image.
2. Backend receives the upload via admin upload route.
3. Backend forwards media to Cloudinary.
4. Cloudinary URL is stored with the product.

## 7. Data Models

## 7.1 User

Purpose:
- Represents both customers and staff/admin users.

Important fields:
- `phone`
- `email`
- `passwordHash`
- `name`
- `familyName`
- `role`
- `city`
- `district`
- `addressDetail`
- `deliveryNotes`
- `fcmTokens`
- `addresses`
- timestamps

Roles:
- `customer`
- `admin`
- `app_admin`
- `ops_admin`

## 7.2 Product

Purpose:
- Represents a sellable poultry catalog item.

Important fields:
- `name`
- `nameEn`
- `nameAr`
- `slug`
- `description`
- `descriptionEn`
- `descriptionAr`
- `images`
- `price`
- `salePrice`
- `weightValue`
- `weightUnit`
- `stock`
- `maxOrderQty`
- `category`
- `isActive`
- timestamps

## 7.3 Order

Purpose:
- Represents a customer or guest purchase transaction.

Important fields:
- `orderNumber`
- `customerId`
- `guestName`
- `guestPhone`
- `items`
- `status`
- `deliveryAddress`
- `assignedDelivery`
- `promoCode`
- `discountAmount`
- `subtotal`
- `deliveryFee`
- `total`
- `notes`
- `cancellationReason`
- timestamps

Embedded order item snapshot fields:
- `productId`
- `name`
- `price`
- `quantity`
- `weightSnapshot`
- `image`

## 7.4 Promotion

Purpose:
- Defines promo-code based discounts.

Important fields:
- `code`
- `discountType`
- `discountValue`
- `minOrderAmount`
- `maxDiscount`
- `expiresAt`
- `isActive`
- `usageLimit`
- `usageCount`

## 7.5 FlashOffer

Purpose:
- Defines time-bounded promotional offers over one or more products.

Important fields:
- `title`
- `imageUrl`
- `productIds`
- `originalPrice`
- `discountedPrice`
- `startsAt`
- `endsAt`
- `maxQtyPerOrder`
- `totalAvailable`
- `totalUsed`
- `isEnabled`

## 7.6 District

Purpose:
- Represents a delivery/service district.

Important fields:
- `name`
- `isActive`
- `sortOrder`

## 7.7 Mobile App Models

The Flutter app mirrors backend entities with client-side models including:

- `Product`
- `Order`
- `OrderItem`
- `FlashOffer`
- `CartLine`
- `CustomerProfile`

These models are used for API decoding, UI rendering, and temporary local persistence.

## 8. State Management

## 8.1 Flutter Mobile State Management

The Flutter app uses `provider` with `ChangeNotifier` as its primary global state mechanism.

Core global providers:

- `LocaleController`
  Controls selected locale and language toggle behavior.

- `AuthController`
  Handles session restoration, login, guest mode, staff mode, logout, and local session persistence.

- `ApiClient`
  Shared transport client with optional token injection.

- `ShopRepository`
  Shared repository for shopping-related API access.

- `CartController`
  Manages cart lines, quantity updates, subtotal calculation, and local persistence.

Additional state characteristics:

- Many screens use local widget state via `StatefulWidget` and `setState`.
- Remote data is often loaded on-demand using `FutureBuilder`.
- There is no Bloc, Riverpod, Redux, or GetX usage in the main Flutter app.
- Navigation is mostly imperative through `Navigator`.

## 8.2 Persistence Strategy

### Flutter

Stored in `SharedPreferences`:

- locale
- staff token
- staff user
- guest shopping flag
- guest name
- guest phone
- guest district
- guest address detail
- customer profile
- cart lines
- last order number

### Admin Dashboard

Stored in `localStorage`:

- `admin_token`
- `admin_user`

## 8.3 Backend State

The backend is stateless at the application-server level:

- sessions are represented through JWTs
- persistent domain state is stored in MongoDB
- business transitions are committed through database writes

## 9. External Services

## 9.1 MongoDB

Role:
- Primary persistence layer for all business entities.

Technology:
- MongoDB with Mongoose.

Local development:
- Provisioned through `docker-compose.yml`.

## 9.2 Cloudinary

Role:
- Product/admin media upload and hosted image storage.

Configuration:
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`

Behavior:
- If Cloudinary is not configured, image upload support is effectively disabled.

## 9.3 Firebase Admin / FCM

Role:
- Server-side push notification sending.

Configuration:
- `GOOGLE_APPLICATION_CREDENTIALS`

Behavior:
- Backend can send push notifications to registered user FCM tokens.
- Mobile client registration hook exists, but full Flutter Firebase client integration is not present in this repository.

## 9.4 WhatsApp Deep Linking

Role:
- Customer support or communication shortcut from the mobile app.

Technology:
- `url_launcher`

## 9.5 Localization Tooling

Role:
- English and Arabic UI support.

Technology:
- Flutter localization generation
- ARB-based localization files

## 10. Environment Setup

## 10.1 Prerequisites

- Flutter SDK compatible with Dart `^3.11.4`
- Node.js `>=18`
- npm
- Docker Desktop or another Docker runtime for MongoDB

## 10.2 Local Backend Setup

1. Start MongoDB:

```bash
docker compose up -d
```

2. Enter backend directory and install dependencies:

```bash
cd backend
npm install
```

3. Create a `.env` file based on `.env.example`.

4. Start the API:

```bash
npm run dev
```

5. Verify health:

```bash
http://localhost:4000/health
```

### Backend Environment Variables

Primary variables from `.env.example`:

- `PORT`
- `CORS_ORIGIN`
- `NODE_ENV`
- `MONGODB_URI`
- `JWT_SECRET`
- `JWT_EXPIRES_IN`
- `ADMIN_JWT_EXPIRES_IN`
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`
- `GOOGLE_APPLICATION_CREDENTIALS`
- `OTP_EXPIRY_MINUTES`
- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`

### Optional Seed Commands

```bash
npm run seed:admin
npm run seed:demo
npm run seed:catalog
npm run seed:districts
```

## 10.3 Local Admin Dashboard Setup

1. Enter dashboard directory:

```bash
cd admin-dashboard
```

2. Install dependencies:

```bash
npm install
```

3. Start the dev server:

```bash
npm run dev
```

Default behavior:

- Vite runs on port `5173`
- `/api` calls are proxied to `http://localhost:4000`

Optional environment:

- `VITE_API_URL`
  When provided, Axios uses it as the backend base URL instead of relying on relative proxy behavior.

## 10.4 Local Flutter Mobile Setup

1. Enter mobile directory:

```bash
cd mobile
flutter pub get
```

2. Run the app:

```bash
flutter run
```

### API Base Resolution

If `API_BASE` is not supplied via `--dart-define`, the app uses environment-aware defaults:

- Flutter Web: `http://localhost:4000`
- Android emulator: `http://10.0.2.2:4000`
- Other native targets: `http://127.0.0.1:4000`

Override example:

```bash
flutter run --dart-define=API_BASE=http://192.168.1.10:4000
```

### Demo Mode

The Flutter app supports a demo mode toggle:

```bash
flutter run --dart-define=DEMO_MODE=true
```

This can expose demo login/customer shortcuts and local mock product behavior.

## 10.5 Important Repository Clarification

The primary Flutter application is under `mobile/`. The root-level Flutter app appears to be a template scaffold and should not be confused with the production mobile implementation.

## 11. Deployment Notes

## 11.1 Backend Deployment Considerations

- Requires Node.js runtime and MongoDB connectivity.
- Requires secure production values for JWT and database configuration.
- Requires Cloudinary credentials if image upload is needed.
- Requires Firebase service account credentials if push notifications are needed.
- The server binds to `0.0.0.0`, which supports LAN/device testing and conventional hosting.

## 11.2 Admin Dashboard Deployment Considerations

- Built using:

```bash
npm run build
```

- Output is generated in `admin-dashboard/dist/`.
- Can be served from any static host or reverse-proxied setup.
- Must be configured to reach the backend API through `VITE_API_URL` or hosting/proxy rules.

## 11.3 Flutter App Deployment Considerations

- Standard Flutter build targets are available for Android, web, desktop, and potentially iOS.
- Production builds should inject the correct backend URL using `--dart-define=API_BASE=...`.
- Additional production setup would be needed if Firebase client push support is later completed.

## 11.4 Current Deployment Gaps

The repository does not currently show a complete deployment automation story. The following items were not found in the main project:

- CI/CD workflows
- production Dockerfiles
- infrastructure-as-code manifests
- hosting platform configuration such as Vercel, Netlify, Firebase Hosting, or Codemagic

This suggests deployment is either manual, handled outside this repository, or not yet formalized.

## 12. Technology Stack Summary

### Mobile App

- Flutter
- Dart
- Provider
- HTTP package
- SharedPreferences
- Flutter localization
- Google Fonts
- url_launcher

### Admin Dashboard

- React
- TypeScript
- Vite
- React Router
- Axios

### Backend

- Node.js
- Express
- Mongoose
- JWT
- bcryptjs
- express-validator
- multer
- Cloudinary
- Firebase Admin

### Database

- MongoDB

## 13. Observations and Important Notes

### 13.1 Dual Flutter Structure

The most important repository-level architectural caveat is that there are two Flutter structures in the workspace:

- a root Flutter scaffold
- the real mobile application under `mobile/`

Any future developer or AI agent should treat `mobile/` as the functional product app unless there is evidence of a migration plan.

### 13.2 Customer Auth Strategy

The backend supports authenticated customer APIs, but the current Flutter customer experience is designed primarily around guest shopping plus locally saved customer profile data. This is an intentional implementation detail worth preserving in future documentation and design discussions.

### 13.3 Payment Scope

No live payment provider integration is present. The platform currently operates as an order-capture and fulfillment workflow rather than a full online payment commerce platform.

### 13.4 Testing Maturity

Automated testing appears minimal across the workspace. This is a documentation-relevant risk area for future maintenance, especially around orders, promotions, admin workflows, and integration behavior.

### 13.5 Documentation Reliability

This document was generated from code inspection and runtime configuration files present in the repository. If hidden infrastructure, private credentials, or external deployment pipelines exist outside the repository, they are not represented here.
# POULTRY_APP - Complete Technical Documentation

## 1. Project Overview

### What the Application Does
POULTRY_APP is a multi-surface poultry commerce platform with:
- A Flutter shopper application (`mobile/`) for browsing products, cart, and checkout.
- A Flutter in-app staff/admin console (`mobile/` admin features) for operational management.
- A Node.js/Express backend (`backend/`) exposing public, customer, and admin APIs.
- A React + Vite admin dashboard (`admin-dashboard/`) for browser-based operations.

### Core Purpose and Business Logic
The platform enables poultry ordering with low-friction entry (guest shopping and customer login support), while providing role-based management tools for operations staff. Core business domains:
- Product catalog management (including multilingual fields).
- Order placement and lifecycle tracking.
- Promotions and flash offers.
- Customer and staff administration.
- Delivery location support via districts.

Primary commercial flow:
1. User browses active products.
2. Adds products to cart.
3. Places order (guest or authenticated customer path).
4. Backend validates stock/pricing/promotions, persists order, updates inventory.
5. Admin/staff monitor and update order status.

---

## 2. System Architecture

### High-Level Architecture
- **Client Layer**
  - Flutter mobile app (`mobile/`) for shopper + in-app admin experience.
  - React web dashboard (`admin-dashboard/`) for admin operations.
- **API Layer**
  - Express application (`backend/src/app.js`) handling routing, auth, validation, and role-based access.
- **Data Layer**
  - MongoDB (Mongoose models in `backend/src/models`).
- **Integrations Layer**
  - Cloudinary for media upload.
  - Firebase Admin (FCM) for push notifications.
  - JWT for authentication and role claims.

### Component Interaction
- Flutter app and React dashboard call REST APIs under `/api/...`.
- Express app routes requests to domain logic in route handlers/services.
- Mongoose models persist business entities in MongoDB.
- Admin routes are protected by JWT authentication and admin role middleware.
- Order/status events can trigger FCM notifications.
- Product media uploads use backend upload route + Cloudinary.

### Security and Access Boundaries
- Public endpoints for catalog and guest flows.
- Customer-only endpoints protected with `authenticate + requireCustomer`.
- Admin endpoints protected globally under `/api/admin` with `authenticate + requireAdmin`.
- JWT contains user identity and role claims used by middleware authorization.

---

## 3. Folder Structure Explanation

### Repository-Level Structure
- `mobile/`: Main Flutter application (shopper + in-app admin modules).
- `backend/`: Node.js + Express API server with MongoDB models and services.
- `admin-dashboard/`: React + Vite TypeScript web admin panel.
- `docker-compose.yml`: Local infrastructure helper (MongoDB service).
- Root Flutter scaffold files also exist (`lib/`, `android/`, `ios/`, etc.), but active business implementation is primarily under `mobile/`.

### `mobile/` (Flutter)
- `lib/core/`: Shared foundation (theme, constants, API config, locale helpers).
- `lib/data/`: Data layer (HTTP API client and model mapping).
- `lib/features/`: Feature modules (`auth`, `shop`, `cart`, `orders`, `profile`, `admin`, etc.).
- `lib/l10n/`: Localization ARB files and generated localization code.
- `assets/images/`: Brand and UI assets.
- `pubspec.yaml`: Flutter dependencies, assets, and package config.

### `backend/` (API)
- `src/app.js`: Express app setup, middleware chain, route mounts.
- `src/server.js`: Server bootstrap and external service initialization.
- `src/routes/`: Public/customer/admin route handlers.
- `src/routes/admin/`: Admin-only endpoints by business area.
- `src/models/`: Mongoose schemas and indexes.
- `src/services/`: Domain services (order placement, notifications, promotions).
- `src/middleware/`: Auth and error middleware.
- `src/config/`: Database, Cloudinary, Firebase config.
- `src/utils/`: JWT and helper utilities.
- `.env.example`: Required environment variables.

### `admin-dashboard/` (React)
- `src/main.tsx`: Frontend bootstrap.
- `src/App.tsx`: Route tree + auth-guarded admin layout.
- `src/context/`: Global auth/session context.
- `src/layout/`: Dashboard shell and navigation.
- `src/pages/`: Operational screens (orders, products, users, promotions, analytics, etc.).
- `src/api/client.ts`: Axios instance + interceptors.
- `vite.config.ts`: Dev server + proxy configuration.

---

## 4. Features Breakdown

### Shopper Features (Flutter)
- **Entry and Session Start**
  - Start shopping without full account flow.
  - Login via phone/password when needed.
- **Catalog Browsing**
  - Product listing with search support and category/filter behavior.
  - Product detail pages with pricing and stock information.
- **Cart Management**
  - Add/update/remove cart lines.
  - Local cart persistence between app sessions.
- **Checkout**
  - Guest checkout path and customer checkout path supported by backend APIs.
  - Delivery address, district, notes, and promo code support.
- **Order Awareness**
  - Order confirmation and local order references.
- **Profile**
  - Contact/profile data handling in app flow.
- **Localization**
  - English/Arabic support with runtime language switching.
- **External Contact**
  - WhatsApp deep link integration.

### In-App Admin Features (Flutter Admin Module)
- **Orders Management**
  - View and update order statuses.
- **Users and Customers**
  - Administrative CRUD workflows.
- **Products and Stock**
  - Product CRUD, pricing, active/inactive states, stock adjustments.
- **District Management**
  - Manage active delivery districts.
- **Flash Offers**
  - Create/edit/toggle/delete flash offers and control availability windows.

### Web Admin Dashboard Features (React)
- **Admin Authentication**
  - Phone/password login to admin namespace.
- **Dashboard Overview**
  - Summary metrics and operational snapshots.
- **Users/Products/Orders/Customers**
  - Dedicated pages for CRUD and operational updates.
- **Promotions**
  - Promo lifecycle management.
- **Analytics**
  - Admin-facing analytics summary.
- **Image Upload**
  - Product image upload via backend upload endpoint.

### System Perspective (Cross-Cutting)
- Role-based authorization and route protection.
- Transactional order placement logic with stock validation and updates.
- Promotion validation and discount application.
- Multilingual product fields supported end-to-end.

---

## 5. User Flow

### Shopper Flow
1. Launch app -> session gate determines route (login, shopper shell, or admin shell).
2. User enters shopping mode or logs in.
3. Browse/search products and open product details.
4. Add items to cart and proceed to checkout.
5. Enter delivery/contact details (guest/customer path).
6. Submit order to backend.
7. Receive order confirmation/reference and continue browsing or exit.

### Customer Authenticated Flow
1. Login with phone/password through `/api/auth/login`.
2. Customer role is recognized.
3. App uses customer-capable APIs for personal endpoints (where applicable).

### Staff/Admin Flow (Mobile or Web)
1. Admin logs in (`/api/admin/auth/login` for web dashboard; `/api/auth/login` role-aware path used by mobile).
2. JWT stored client-side.
3. Access protected admin modules.
4. Manage products/customers/orders/promotions/offers/districts.
5. Update order status and operational data.

### Operational Order Lifecycle
1. Order created in `pending`.
2. Admin updates status and delivery assignment through admin order endpoints.
3. Optional push notifications sent for status changes.

---

## 6. API / Backend Integration

### Public Endpoints
- `GET /health`
- `POST /api/auth/login`
- `GET /api/products`
- `GET /api/products/:id`
- `GET /api/flash-offers`
- `GET /api/districts`
- `POST /api/orders/guest`

### Customer-Protected Endpoints
- `GET /api/me`
- `PATCH /api/me`
- `POST /api/me/fcm-token`
- `DELETE /api/me/fcm-token`
- `POST /api/orders`
- `GET /api/orders`
- `GET /api/orders/:id`

### Admin Authentication Endpoint
- `POST /api/admin/auth/login`

### Admin-Protected Endpoints (`/api/admin/*`)
- Users: `GET/POST/PATCH/DELETE /api/admin/users...`
- Products: `GET/POST/PATCH/DELETE /api/admin/products...`
- Orders: `GET /api/admin/orders`, `GET /api/admin/orders/:id`, `PATCH /status`, `PATCH /delivery`
- Customers: `GET/POST/PATCH/DELETE /api/admin/customers...`, `GET /api/admin/customers/:id`
- Promotions: `GET/POST/PATCH/DELETE /api/admin/promotions...`
- Analytics: `GET /api/admin/analytics/summary`
- Upload: `POST /api/admin/upload`
- Flash offers: `GET/POST/PATCH/DELETE /api/admin/flash-offers...`, `PATCH /toggle`
- Districts: `GET/POST/PATCH/DELETE /api/admin/districts...`

### Data Flow (Frontend -> Backend)
- Flutter and React clients send HTTP requests to `/api/...`.
- Backend middleware authenticates/authorizes when required.
- Route handlers validate payloads and execute domain logic.
- Services (notably order placement) orchestrate pricing, stock, and persistence.
- Response payloads are mapped into frontend models/controllers.

---

## 7. Data Models

### User (`backend/src/models/User.js`)
Represents both customers and staff/admin accounts.
- Identity/contact: `phone`, `email`, `name`.
- Security: `passwordHash`.
- Authorization: `role` (`customer`, `admin`, `app_admin`, `ops_admin`, etc.).
- Profile/location: district/address fields.
- Notifications: `fcmTokens[]`.

### Product (`backend/src/models/Product.js`)
Catalog item with multilingual and commerce fields.
- Naming/content: `name`, `nameEn`, `nameAr`, `description`, `descriptionEn`, `descriptionAr`.
- Commerce: `price`, `salePrice`, `stock`, `maxOrderQty`, `category`, `isActive`.
- Media/identity: `images[]`, `slug`.

### Order (`backend/src/models/Order.js`)
Order header + item snapshots.
- Ownership: `customerId` (nullable for guest orders), `guestName`, `guestPhone`.
- Items: `items[]` with product reference and price/name snapshots.
- Financials: `subtotal`, `discountAmount`, `deliveryFee`, `total`.
- Logistics: `deliveryAddress`, `assignedDelivery`.
- Lifecycle: `status`, `orderNumber`, timestamps.

### Promotion (`backend/src/models/Promotion.js`)
Promo code discount policy.
- `code`, `discountType`, `discountValue`, `minOrderAmount`, `maxDiscount`.
- `expiresAt`, `isActive`, `usageLimit`, `usageCount`.

### FlashOffer (`backend/src/models/FlashOffer.js`)
Time-bound special offer.
- `title`, `imageUrl`, `productIds[]`.
- `originalPrice`, `discountedPrice`.
- `startsAt`, `endsAt`, `isEnabled`.
- Inventory controls: `totalAvailable`, `totalUsed`, `maxQtyPerOrder`.

### District (`backend/src/models/District.js`)
Delivery service area metadata.
- `name`, `isActive`, `sortOrder`.

---

## 8. State Management

### Flutter App State (`provider` + `ChangeNotifier`)
- `AuthController`: session, user role, JWT handling, shopping/admin routing decisions.
- `LocaleController`: language selection and persistence.
- `CartController`: cart lines, totals, persistence and restoration.
- `ApiClient`: request abstraction including auth headers.
- `ShopRepository`: domain-specific API methods and model mapping.

State persistence uses `shared_preferences` (session/cart/locale related keys).

### React Dashboard State
- Global session state via `AuthContext` (token, user, ready, login/logout).
- Page-level local state with `useState`/`useEffect`.
- Axios interceptors handle auth header injection and unauthorized recovery.

---

## 9. External Services

### Cloudinary
- Used for media upload via admin upload endpoint.
- Configured in backend startup/config modules.

### Firebase Cloud Messaging (via Firebase Admin)
- Backend sends push notifications (e.g., order-related updates) using stored user tokens.

### MongoDB
- Primary persistent datastore via Mongoose.
- Local dev commonly provided through `docker-compose.yml`.

### JWT
- Token issuance and validation for customer and admin/staff sessions.

### WhatsApp
- Flutter app supports direct WhatsApp contact through URL launching.

---

## 10. Environment Setup

### Prerequisites
- Flutter SDK (compatible with `mobile/pubspec.yaml`).
- Node.js + npm.
- MongoDB (local or hosted).
- Optional Cloudinary and Firebase credentials for full feature set.

### Backend Setup (`backend/`)
1. Install dependencies: `npm install`
2. Create env file from `.env.example`.
3. Ensure MongoDB is running (optionally via `docker compose up -d` at repo root).
4. Run dev server: `npm run dev`
5. Optional seed scripts:
   - `npm run seed:admin`
   - `npm run seed:demo`
   - `npm run seed:catalog`
   - `npm run seed:districts`

### Flutter Mobile Setup (`mobile/`)
1. Install dependencies: `flutter pub get`
2. Run app: `flutter run` (or `flutter run -d chrome`)
3. Optional API override:
   - `flutter run -d chrome --dart-define=API_BASE=http://<host>:4000`

### Admin Dashboard Setup (`admin-dashboard/`)
1. Install dependencies: `npm install`
2. Configure env from `.env.example`:
   - `VITE_API_URL` (leave empty in local dev to use Vite proxy)
3. Start dev server: `npm run dev` (default port `5173`)
4. Build: `npm run build`
5. Preview production build: `npm run preview`

---

## 11. Deployment Notes

### Backend Deployment
- Deploy Node/Express service with required environment variables.
- Provide reachable MongoDB instance.
- Configure CORS (`CORS_ORIGIN`) for deployed frontend origins.
- Configure secrets for JWT, Cloudinary, and Firebase credential path/content.

### Admin Dashboard Deployment
- Build static assets with `npm run build`.
- Host static output on CDN/web server.
- Set `VITE_API_URL` to backend base URL in production, unless same-origin reverse proxy is used.

### Flutter Deployment
- Mobile targets: standard Flutter platform builds (`apk`/`aab`/iOS release).
- Web target (if used): configure API base URL and CORS compatibility with backend.

### Infrastructure and Ops Notes
- `docker-compose.yml` provides local MongoDB convenience; production should use managed or hardened database setup.
- No repository-level CI workflow definition was identified; add pipeline automation for lint/test/build/deploy consistency.

---

## Appendix: Key Technical Characteristics

- Multi-client architecture sharing one backend API.
- Role-driven authorization for customer vs admin capabilities.
- Transaction-oriented order placement with inventory protections.
- Multilingual product/content support (EN/AR) across app layers.
- Hybrid operational tooling: in-app admin + web dashboard.

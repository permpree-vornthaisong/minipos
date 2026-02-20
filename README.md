# Mini POS — Project Architecture

## Overview

Flutter Android application สำหรับระบบ POS ขนาดเล็ก ใช้สถาปัตยกรรม **BLoC Pattern** จัดการ State และ **SharedPreferences** เก็บข้อมูล Offline

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | UI Framework |
| flutter_bloc | State Management (BLoC Pattern) |
| equatable | State/Event Comparison |
| shared_preferences | Local Storage (JSON String) |
| uuid | Generate Product ID |

---

## Project Structure

```
lib/
├── models/                    # Data Models
│   ├── product.dart           # Product (id, name, price)
│   └── sale_item.dart         # SaleItem (productId, name, price, qty)
│
├── services/                  # Data Layer
│   └── storage_service.dart   # SharedPreferences CRUD operations
│
├── blocs/                     # Business Logic Layer
│   ├── product/
│   │   ├── product_event.dart # LoadProducts, AddProduct, UpdateProduct
│   │   ├── product_state.dart # Initial, Loading, Loaded, Error
│   │   └── product_bloc.dart  # Product business logic
│   ├── cart/
│   │   ├── cart_event.dart    # LoadCart, AddToCart, IncreaseQty, DecreaseQty, RemoveFromCart, Checkout
│   │   ├── cart_state.dart    # Initial, Loading, Loaded, CheckingOut, CheckoutSuccess, Error
│   │   └── cart_bloc.dart     # Cart & checkout business logic
│   └── report/
│       ├── report_event.dart  # LoadReport
│       ├── report_state.dart  # Initial, Loading, Loaded, Empty, Error
│       └── report_bloc.dart   # Sale report business logic
│
├── pages/                     # Presentation Layer
│   ├── product_page.dart      # Page 1 — Product Grid + Add/Edit Dialog
│   ├── checkout_page.dart     # Page 2 — Cart + Checkout
│   └── report_page.dart       # Page 3 — Last Sale Summary
│
└── main.dart                  # App Entry + MultiBlocProvider + Navigation
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│                Presentation Layer                │
│  ┌──────────────┐ ┌────────────┐ ┌────────────┐ │
│  │ ProductPage   │ │CheckoutPage│ │ ReportPage │ │
│  │ (GridView)    │ │ (ListView) │ │ (ListView) │ │
│  └──────┬───────┘ └─────┬──────┘ └─────┬──────┘ │
│         │               │              │         │
│    BlocBuilder     BlocConsumer    BlocBuilder    │
│         │               │              │         │
├─────────┼───────────────┼──────────────┼─────────┤
│         ▼               ▼              ▼         │
│              Business Logic Layer                │
│  ┌──────────────┐ ┌────────────┐ ┌────────────┐ │
│  │ ProductBloc   │ │  CartBloc  │ │ ReportBloc │ │
│  │ - Load        │ │ - AddToCart│ │ - Load     │ │
│  │ - Add         │ │ - Qty ±   │ │            │ │
│  │ - Update      │ │ - Remove  │ │            │ │
│  │               │ │ - Checkout│ │            │ │
│  └──────┬───────┘ └─────┬──────┘ └─────┬──────┘ │
│         │               │              │         │
├─────────┼───────────────┼──────────────┼─────────┤
│         ▼               ▼              ▼         │
│                   Data Layer                     │
│            ┌─────────────────────┐               │
│            │   StorageService    │               │
│            │ - saveProducts()    │               │
│            │ - loadProducts()    │               │
│            │ - saveCart()        │               │
│            │ - loadCart()        │               │
│            │ - clearCart()       │               │
│            │ - saveSaleReport()  │               │
│            │ - loadSaleReport()  │               │
│            └─────────┬───────────┘               │
│                      ▼                           │
│            ┌─────────────────────┐               │
│            │ SharedPreferences   │               │
│            │ (JSON String)       │               │
│            └─────────────────────┘               │
└─────────────────────────────────────────────────┘
```

---

## Data Flow

### 1. เพิ่มสินค้า (Add Product)

```
User กด FAB (+)
  → Dialog (name, price + validation)
  → ProductBloc.add(AddProduct)
  → สร้าง Product ใหม่ (uuid)
  → StorageService.saveProducts()
  → SharedPreferences (JSON String)
  → emit ProductLoaded
  → GridView อัพเดท
```

### 2. เพิ่มสินค้าเข้าตะกร้า (Add to Cart)

```
User แตะสินค้าใน GridView
  → CartBloc.add(AddToCart)
  → เช็คซ้ำ:
    → มีแล้ว → qty +1
    → ยังไม่มี → เพิ่มใหม่ qty = 1
  → StorageService.saveCart()
  → emit CartLoaded
  → Badge อัพเดท + SnackBar
```

### 3. Checkout

```
User กดปุ่ม "ชำระเงิน"
  → CartBloc.add(Checkout)
  → ป้องกันกดซ้ำ (if CartCheckingOut → return)
  → emit CartCheckingOut (UI แสดง loading)
  → Future.delayed(2 seconds)
  → StorageService.saveSaleReport()
  → StorageService.clearCart()
  → emit CartCheckoutSuccess
  → SnackBar "สำเร็จ" + โหลดตะกร้าใหม่ (ว่าง)
```

### 4. ดูรายงาน (Sale Report)

```
User กดแท็บ "รายงาน"
  → ReportBloc.add(LoadReport)
  → StorageService.loadSaleReport()
  → มีข้อมูล → emit ReportLoaded
  → ไม่มี → emit ReportEmpty
```

---

## BLoC State Diagram

### ProductBloc

```
ProductInitial
  → [LoadProducts] → ProductLoading → ProductLoaded / ProductError
  → [AddProduct]   → ProductLoaded / ProductError
  → [UpdateProduct] → ProductLoaded / ProductError
```

### CartBloc

```
CartInitial
  → [LoadCart]       → CartLoading → CartLoaded / CartError
  → [AddToCart]      → CartLoaded / CartError
  → [IncreaseQty]   → CartLoaded / CartError
  → [DecreaseQty]   → CartLoaded / CartError
  → [RemoveFromCart] → CartLoaded / CartError
  → [Checkout]       → CartCheckingOut → CartCheckoutSuccess / CartError
```

### ReportBloc

```
ReportInitial
  → [LoadReport] → ReportLoading → ReportLoaded / ReportEmpty / ReportError
```

---

## Data Models

### Product

```dart
class Product extends Equatable {
  final String id;       // UUID v4
  final String name;     // Required, ห้ามว่าง
  final double price;    // >= 0

  toJson() → Map        // สำหรับ save ลง SharedPreferences
  fromJson() → Product  // สำหรับ load กลับมา
}
```

### SaleItem

```dart
class SaleItem extends Equatable {
  final String productId;
  final String name;
  final double price;
  final int qty;

  copyWith(qty) → SaleItem  // อัพเดท qty โดยไม่สร้างใหม่ทั้งหมด
  toJson() → Map
  fromJson() → SaleItem
}
```

---

## Storage Strategy

ใช้ **SharedPreferences** เก็บข้อมูลเป็น **JSON String**

| Key | Data | Description |
|---|---|---|
| `products` | `List<Product>` → JSON String | รายการสินค้าทั้งหมด |
| `cart` | `List<SaleItem>` → JSON String | สินค้าในตะกร้า |
| `sale_report` | `List<SaleItem>` → JSON String | รายการขายล่าสุด (เขียนทับทุกครั้ง) |

---

## Key Design Decisions

| Decision | Reason |
|---|---|
| BLoC Pattern | โจทย์กำหนด + แยก business logic ออกจาก UI ชัดเจน |
| Equatable | ให้ BLoC เปรียบเทียบ state ได้ถูกต้อง ลด unnecessary rebuild |
| StorageService แยกออกมา | Single Responsibility — BLoC ไม่ต้องรู้จัก SharedPreferences ตรงๆ |
| JSON String ใน SharedPreferences | SharedPreferences เก็บ List/Object ตรงๆ ไม่ได้ |
| UUID v4 สำหรับ Product ID | ไม่ต้องพึ่ง backend auto increment |
| copyWith ใน SaleItem | Immutable state — สร้างใหม่แทนการแก้ไขตรงๆ |
| Prevent double checkout ทั้ง UI + Bloc | ป้องกัน 2 ชั้น — UI ซ่อนปุ่ม + Bloc บล็อก event |
| Sale report เขียนทับ | โจทย์ต้องการแค่ "last completed transaction" |

---

## Pages Summary

| Page | Widget | BLoC | Features |
|---|---|---|---|
| สินค้า | ProductPage | ProductBloc + CartBloc | GridView, Add/Edit Dialog, Cart Badge |
| ตะกร้า | CheckoutPage | CartBloc | Qty ±, Remove, Subtotal, Checkout 2s |
| รายงาน | ReportPage | ReportBloc | Last sale summary |

---

## Navigation

```
MainScreen (StatefulWidget)
├── BottomNavigationBar (3 แท็บ)
├── ProductPage   → แตะ icon ตะกร้าที่ AppBar → ไปหน้า Checkout
├── CheckoutPage
└── ReportPage    → โหลดข้อมูลใหม่ทุกครั้งที่เปิด
```

---

## How to Run

```bash
# ติดตั้ง dependencies
fvm flutter pub get

# รันบน Android Emulator
fvm flutter run -d emulator-5554

# Build APK
fvm flutter build apk
```
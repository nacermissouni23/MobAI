# MobAI: Minimal MVP Requirements (2-Day Hackathon Edition)

## 1. Project Goal
Build a mobile Warehouse Management System (WMS) enhanced with an AI agent. The goal is to manage the end-to-end flow of a specific warehouse (Depot B7) while optimizing operations using AI.

## 2. The Core Operational Flow (Must-Have)
The application must handle this exact lifecycle for products:

1.  **Receipt:** Employee scans/counts incoming stock from a "Command Order".
2.  **Transfer (Storage):** **[AI DRIVEN]** Employee moves products to a specific storage slot assigned by the AI.
3.  **Preparation:** **[AI DRIVEN]** System generates a "Preparation Order" based on AI forecasts.
4.  **Picking:** **[AI DRIVEN]** Employee picks items from storage to racks following an AI-optimized route.
5.  **Delivery:** Employee validates the final shipment.

## 3. User Roles (Simplified)
* **ADMIN:** Can view all logs and override *any* AI/Supervisor decision. (Skip complex user creation; seed users in DB).
* **SUPERVISOR:** Monitors operations. Can override AI suggestions (e.g., change a storage location or picking route) with a required text justification.
* **EMPLOYEE:** "Blind" execution. They only see validated tasks (e.g., "Go to Slot A1, pick 5 items"). They cannot see overrides or AI logic.

## 4. Minimal Functional Requirements (FRs)

### A. Security & Setup
* [cite_start]**Auth:** Simple login for the 3 roles[cite: 50, 51, 52].
* [cite_start]**Warehouse:** Hardcode the provided "Depot B7" layout (Floors 1-4 for storage, Ground Floor for picking) [cite: 134-136]. *Do not build a generic warehouse creator.*

### B. Inventory & SKU
* [cite_start]**Stock Tracking:** Real-time tracking of SKU quantity per location[cite: 73].
* [cite_start]**Constraints:** Prevent negative stock[cite: 74].

### C. Orders & Operations
* [cite_start]**Execute the 4 Operations:** Receipt, Transfer, Picking, Delivery[cite: 90].
* **Overrides:** Allow Supervisor/Admin to change a target location/quantity. [cite_start]Log this action[cite: 58, 59].

### D. UI/Mobile (MVP Scope)
* **Focus:** A clean mobile interface for the Employee to execute tasks step-by-step.
* **Offline Mode (Simplified):** If time is tight, skip full bidirectional sync. [cite_start]Implement simple local caching so the app doesn't crash if the server blips[cite: 92].

---

## 5. AI Requirements (Full Scope - High Priority)
*As requested, these requirements are preserved from the original document.*

The AI Agent must be a multi-service integration responsible for three key tasks:

### [cite_start]Service 1: Forecasting (Preparation Orders) [cite: 310, 311]
* **Input:** Historical stock and delivery data.
* **Output:** Generate "Preparation Orders" one day in advance.
* **Goal:** Predict which products and quantities are needed for upcoming deliveries.

### [cite_start]Service 2: Storage Optimization [cite: 312, 313]
* **Trigger:** Happens after "Receipt" when moving items to storage.
* **Output:** Output the exact Floor and Slot assignment (e.g., "Floor 2, Slot C7").
* **Optimization Factors:**
    * **Weight:** Heavy products closer to ground/expedition.
    * **Frequency:** High-turnover items closer to access points.
    * **Availability:** Must dynamically assign based on currently free space (area).

### [cite_start]Service 3: Picking Optimization [cite: 314, 315]
* **Trigger:** When generating "Picking Orders" for delivery.
* **Output:** An optimized route/sequence of locations to visit.
* **Goal:**
    * Minimize total walking distance/travel time.
    * Avoid congestion (overlap between multiple paths).

---

## [cite_start]6. Deliverables [cite: 317-322]
1.  **Mobile App:** APK file (Android).
2.  **Source Code:** GitHub repository.
3.  **AI Compare:** A brief comparison between your AI algorithm and a "naive" baseline (e.g., your AI vs. random placement).
4.  **Short Doc (Max 4 pages):** Explaining your optimization logic and decision flow.
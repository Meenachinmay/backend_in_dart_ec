# Notification Flow & Architecture

## Overview

The notification system bridges our **PostgreSQL Inventory/Subscription data** with **Firebase Firestore** to deliver real-time alerts to the Flutter app.

## The Flow

1.  **The "Trigger" (Cron Job / Scheduler)**
    *   Currently, we expose an endpoint: `POST /api/v1/subscriptions/trigger-check`.
    *   In a production environment, this endpoint is **not** meant to be called manually by users.
    *   Instead, a **Scheduler** (like `cron` on the server, or a Cloud Scheduler job) calls this endpoint periodically (e.g., **once every day at 00:00 UTC**).

2.  **The Backend Processing (Dart Service)**
    *   When triggered, the `SubscriptionService` executes:
        1.  **Query PostgreSQL**: It runs a SQL query to find all subscriptions where `inventory.expiry_in` matches the user's `subscription.alert_threshold`.
            *   *Example:* User A wants to know when "Milk" has 1 day left. The DB query finds this match.
        2.  **Process Results**: It generates a list of pending notifications.
        3.  **Write to Firestore**: For each match, it uses the **Firebase Admin SDK** to create a new document in the `notifications` collection in your Firestore database.

3.  **Real-time Delivery (Firestore & Flutter)**
    *   **Firestore**: The `notifications` collection now contains a new document:
        ```json
        {
          "user_email": "user@example.com",
          "message": "Item Milk is expiring in 1 day!",
          "status": "unread",
          "created_at": "2025-11-29T..."
        }
        ```
    *   **Flutter App**: The app has a `StreamBuilder` listening to `Firestore.collection('notifications').where('user_email', isEqualTo: currentUser.email)`.
    *   **Immediate Update**: Because Firestore is real-time, the moment the backend writes the document, the Flutter app receives the data **instantly** (sub-second latency).
    *   **Local Notification**: The Flutter app sees the new document and triggers a **Local Push Notification** on the user's device.

## Why this approach?

*   **Efficiency**: The backend does the heavy lifting of querying thousands of inventory items in SQL (which is fast).
*   **Real-time**: Firestore acts as the real-time message broker. We don't need to implement complex WebSockets or polling in the app.
*   **Offline Support**: If the user's phone is off, the notification waits in Firestore. When they open the app, they see the alert.

## Future Improvement: Cloud Functions

*   Instead of the Flutter app listening constantly, you can deploy a **Firebase Cloud Function** that listens to the `onCreate` event of the `notifications` collection.
*   This Cloud Function can then send a **FCM (Firebase Cloud Messaging)** push notification to the specific device token.
*   This saves battery on the client side and allows notifications even when the app is killed.

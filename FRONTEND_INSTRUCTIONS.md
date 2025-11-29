# Frontend Implementation Guide: Real-Time Local Notifications

This guide outlines the steps for the Frontend Agent (Flutter) to implement local push notifications triggered by real-time updates from the Backend via Firestore.

## 1. Architecture Overview

*   **Backend**: Runs a daily job that identifies expiring items matching user preferences. It writes a new document to the `notifications` collection in Firestore.
*   **Frontend**: Listens to this Firestore collection in real-time. When a new document appears, it triggers a **Local Notification** on the device.

## 2. Prerequisites (Dependencies)

Add the following packages to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: latest
  cloud_firestore: latest
  flutter_local_notifications: latest
  firebase_auth: latest # If using Firebase Auth
```

## 3. Firestore Schema

The backend writes to the `notifications` collection. The documents follow this structure:

| Field | Type | Description |
| :--- | :--- | :--- |
| `user_email` | String | The email of the user who should receive the alert. |
| `item_name` | String | The name of the inventory item (e.g., "Milk"). |
| `message` | String | The display message (e.g., "Item Milk is expiring in 1 day!"). |
| `created_at` | String (ISO8601) | Timestamp of creation. |
| `status` | String | Initial value is "unread". |

## 4. Implementation Steps

### Step A: Initialize Local Notifications

Create a service class `LocalNotificationService` to manage the plugin.

1.  **Initialize**:
    *   Android: `AndroidInitializationSettings('@mipmap/ic_launcher')`
    *   iOS: `DarwinInitializationSettings()` (Request permissions on start).
2.  **Show Notification Method**:
    *   Create a function `showNotification(String title, String body)` that uses `flutter_local_notifications` to display the alert.

### Step B: Listen to Firestore (The Core Logic)

In your main `Dashboard` or a top-level `Bloc/Provider` that is active when the app is open:

1.  **Stream Setup**:
    Create a stream subscription that queries the `notifications` collection.
    *   **Filter**: `where('user_email', isEqualTo: currentUser.email)`
    *   **Filter**: `where('status', isEqualTo: 'unread')` (to avoid re-alerting old ones).

    ```dart
    FirebaseFirestore.instance
        .collection('notifications')
        .where('user_email', isEqualTo: userEmail)
        .where('created_at', isGreaterThan: lastCheckTimestamp) // Optimization: Only new ones
        .snapshots()
        .listen((snapshot) {
            for (var change in snapshot.docChanges) {
                if (change.type == DocumentChangeType.added) {
                    final data = change.doc.data();
                    // TRIGGER LOCAL NOTIFICATION HERE
                    LocalNotificationService.show(
                        title: "Inventory Alert",
                        body: data?['message'] ?? "Item expiring soon!"
                    );
                }
            }
        });
    ```

### Step C: Handling App Lifecycle (Background)

*   **Foreground**: The `Stream` above works perfectly.
*   **Background/Terminated**:
    *   Since we are using **Local Notifications** triggered by data sync, this primarily works when the app is **running** (foreground).
    *   *Note for Agent*: Explain to the user that true "Background" delivery usually requires FCM (Cloud Messaging). However, for this "Local Sync" demo, Firestore's offline persistence *might* trigger the listener immediately upon app opening if a document was added while the app was closed.

## 5. Testing the Flow

1.  **Login** to the Flutter app with a test email (e.g., `demo@example.com`).
2.  **Subscribe** to an item (e.g., "Milk") with a threshold (e.g., 1 Day).
3.  **Trigger Backend**: Ask the backend developer to run the `trigger-check` endpoint.
4.  **Verify**:
    *   A new document appears in Firestore.
    *   The Flutter app receives the event.
    *   A system notification banner appears on the phone screen.

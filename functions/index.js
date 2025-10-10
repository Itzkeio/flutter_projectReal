// functions/index.js
const { setGlobalOptions } = require("firebase-functions/v2");
// ⭐️ CHANGE to onDocumentUpdated
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

setGlobalOptions({ region: "asia-southeast2" });
initializeApp();

// ⭐️ CHANGE trigger to onDocumentUpdated and path to "users/{userId}"
exports.sendProfileUpdatePush = onDocumentUpdated(
  "users/{userId}",
  async (event) => {
    // Get the new data from the document after the update.
    const newData = event.data?.after.data();
    // Get the data from before the update.
    const oldData = event.data?.before.data();

    if (!newData || !newData.fcmToken) {
      console.log("No FCM token for user, cannot send notification.");
      return;
    }

    // Optional: Prevent notification if only the timestamp changed
    if (newData.displayName === oldData.displayName && newData.role === oldData.role) {
      console.log("No profile data changed, skipping notification.");
      return;
    }
    
    const displayName = newData.displayName || "User";
    const title = "Profile Updated!";
    const body = `Hi ${displayName}, your profile was saved successfully.`;

    const message = {
      token: newData.fcmToken,
      notification: { title, body },
      data: {
        type: "profile_saved",
        uid: event.params.userId,
      },
      android: {
        priority: "high",
        notification: { channelId: "save_channel" },
      },
      apns: { payload: { aps: { sound: "default" } } },
    };

    try {
      await getMessaging().send(message);
      console.log("Successfully sent profile update notification.");
    } catch (err) {
      console.error("FCM send error:", err);
    }
  }
);
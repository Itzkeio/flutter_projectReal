// functions/index.js
const { setGlobalOptions } = require("firebase-functions/v2");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

setGlobalOptions({ region: "asia-southeast2" }); // change if you want
initializeApp();

exports.sendProfileSavedPush = onDocumentCreated(
  "profileSaveEvents/{docId}",
  async (event) => {
    const data = event.data?.data();
    if (!data || !data.token) return;

    const title = "Profile Updated";
    const body = (data.displayName && data.displayName.trim())
      ? `Hi ${data.displayName}, your profile was saved successfully.`
      : "Your profile was saved successfully.";

    const message = {
      token: data.token,
      notification: { title, body },
      data: {
        type: "profile_saved",
        uid: data.uid ?? "",
      },
      android: {
        priority: "high",
        notification: { channelId: "default_channel_id" },
      },
      apns: { payload: { aps: { sound: "default" } } },
    };

    try {
      await getMessaging().send(message);
    } catch (err) {
      console.error("FCM send error:", err);
    }
  }
);

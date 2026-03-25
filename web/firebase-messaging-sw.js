importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

// FIXED: Updated to match project paykari-bazar-a19e7 as per blueprint and firebase_options.dart
firebase.initializeApp({
  apiKey: "AIzaSyApWFRK_CbOvvCgdrlQnWmrxo6Hc_hfoq4",
  authDomain: "paykari-bazar-a19e7.firebaseapp.com",
  projectId: "paykari-bazar-a19e7",
  storageBucket: "paykari-bazar-a19e7.firebasestorage.app",
  messagingSenderId: "1081673908768",
  appId: "1:1081673908768:web:a9f00e4ae6d3ca3e547245"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/favicon.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

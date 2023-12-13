// Import and configure the Firebase SDK
importScripts('https://www.gstatic.com/firebasejs/10.6.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.6.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: "AIzaSyC8DWmwROAeyPru_SYh3xwDJG2BX_eNcD4",
  authDomain: "student-event-calendar-dce10.firebaseapp.com",
  projectId: "student-event-calendar-dce10",
  storageBucket: "student-event-calendar-dce10.appspot.com",
  messagingSenderId: "777878936021",
  appId: "1:777878936021:web:972eba2175a9e6eedf855c",
  measurementId: "G-6ZJTE7VPBD"
});

const messaging = firebase.messaging();

// Optional:
// Add the public key generated from the console here.
// messaging.usePublicVapidKey("your-public-key");

messaging.setBackgroundMessageHandler(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = 'Background Message Title';
  const notificationOptions = {
    body: 'Background Message body.',
    icon: '/firebase-logo.png'
  };

  return self.registration.showNotification(notificationTitle,
    notificationOptions);
});

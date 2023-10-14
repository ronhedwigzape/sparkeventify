require('dotenv').config();

// Initialize Firebase
if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
        navigator.serviceWorker.register('/firebase-messaging-sw.js')
        .then(function(registration) {
            console.log('ServiceWorker registration successful with scope: ', registration.scope);
        })
        .catch(function(err) {
            console.log('ServiceWorker registration failed: ', err);
        });
    });
}

firebase.initializeApp({
    apiKey: process.env.WEB_API_KEY,
    authDomain: process.env.WEB_AUTH_DOMAIN,
    projectId: process.env.WEB_PROJECT_ID,
    storageBucket: process.env.WEB_STORAGE_BUCKET,
    messagingSenderId: process.env.WEB_MESSAGING_SENDER_ID,
    appId: process.env.WEB_APP_ID,
    measurementId: process.env.WEB_MEASUREMENT_ID
});

const messaging = firebase.messaging();

navigator.serviceWorker.register('/firebase-messaging-sw.js')
.then((registration) => {
    messaging.useServiceWorker(registration);
});

    require('dotenv').config();
   
    importScripts('https://www.gstatic.com/firebasejs/8.2.6/firebase-app.js');
    importScripts('https://www.gstatic.com/firebasejs/8.2.6/firebase-messaging.js');
    

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
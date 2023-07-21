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
        apiKey: "AIzaSyC8DWmwROAeyPru_SYh3xwDJG2BX_eNcD4",
        authDomain: "student-event-calendar-dce10.firebaseapp.com",
        projectId: "student-event-calendar-dce10",
        storageBucket: "student-event-calendar-dce10.appspot.com",
        messagingSenderId: "777878936021",
        appId: "1:777878936021:web:972eba2175a9e6eedf855c",
        measurementId: "G-6ZJTE7VPBD"
    });

   const messaging = firebase.messaging();

   navigator.serviceWorker.register('/firebase-messaging-sw.js')
   .then((registration) => {
       messaging.useServiceWorker(registration);
   });

importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBCSTtX14hFWvaOqMegZxk0PH0o28UcNeQ",
  authDomain: "studify-70054.firebaseapp.com",
  projectId: "studify-70054",
  storageBucket: "studify-70054.firebasestorage.app",
  messagingSenderId: "941139273666",
  appId: "1:941139273666:web:48dca86407072d3923985b",
  measurementId: "G-TXTT6GYJSC"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle,
    notificationOptions);
});

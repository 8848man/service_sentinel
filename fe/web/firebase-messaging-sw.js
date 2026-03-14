importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyCto_QRRBqSo3y-dwbJ94Hcmh95Y7fcybE",
    authDomain: "lattui-auth.firebaseapp.com",
    projectId: "lattui-auth",
    messagingSenderId: "864284905352",
    appId: "1:864284905352:web:cad44a83f7f7f2de4db43d",
});

const messaging = firebase.messaging();

// 백그라운드 메시지 처리
messaging.onBackgroundMessage(function (payload) {
    console.log("Received background message ", payload);

    const notificationTitle = payload.notification?.title ?? "Notification";
    const notificationOptions = {
        body: payload.notification?.body,
        icon: payload.notification?.image,
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
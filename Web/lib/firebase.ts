import { initializeApp, getApps } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

// HARDCODED CONFIG - Bypass env var issues
const firebaseConfig = {
  apiKey: "AIzaSyCQtka54zQGN2CnnCf-Jw2W3-Cp82-6fjo",
  authDomain: "kos-terpadu.firebaseapp.com",
  projectId: "kos-terpadu",
  storageBucket: "kos-terpadu.firebasestorage.app",
  messagingSenderId: "19828893591",
  appId: "1:19828893591:android:8e2d7a40c284445b9f46d2",
};

console.log("🔥 Firebase Config:", firebaseConfig);

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

export const db = getFirestore(app);
export const storage = getStorage(app);
export default app;
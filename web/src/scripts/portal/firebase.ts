// The one Firebase project both halves of The Exchange talk to. The web API key
// is public by design: what may be read and written is decided by
// firestore.rules and storage.rules, not by who holds this string.
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

const app = initializeApp({
  apiKey: 'AIzaSyDsC3_mQFDUXj6pmKMw1_xf4_XigC82smE',
  authDomain: 'thesimsmodmanager.firebaseapp.com',
  projectId: 'thesimsmodmanager',
  storageBucket: 'thesimsmodmanager.firebasestorage.app',
  appId: '1:923896190617:web:1255ab175af4a72d7a8a08',
});

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

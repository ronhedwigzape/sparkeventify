const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.processSignUp = functions.firestore
  .document('users/{userId}')
  .onCreate((snap, context) => {
    const newUser = snap.data();

    if (newUser.userType === 'Admin') {
      return admin.auth().setCustomUserClaims(context.params.userId, {admin: true});
    } else {
      return null;
    }
  });

exports.deleteUser = functions.https.onCall(async (data, context) => {
  if (context.auth.token.admin !== true) {
    return { error: 'Only admins can delete users' };
  }

  try {
    await admin.auth().deleteUser(data.uid);
    return { result: `User ${data.uid} has been deleted` };
  } catch (error) {
    return { error: error.message };
  }
});

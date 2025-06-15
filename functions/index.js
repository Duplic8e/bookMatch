const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();

exports.notifyOnNewBook = onDocumentCreated("books/{bookId}", async (event) => {
  const newBook = event.data.data();

  const payload = {
    notification: {
      title: "📚 New Book Added!",
      body: `${newBook.title || "A new book"} is now available.`,
    },
    topic: "new-books",
  };

  try {
    const response = await getMessaging().send(payload);
    console.log("Successfully sent message:", response);
  } catch (error) {
    console.error("Error sending message:", error);
  }
});

exports.notifyOnPostComment = onDocumentCreated(
    "posts/{postId}/comments/{commentId}",
    async (event) => {
      const {postId} = event.params;
      const firestore = getFirestore();

      try {
        const postSnap = await firestore
            .collection("posts")
            .doc(postId)
            .get();
        if (!postSnap.exists) return;

        const post = postSnap.data();
        const authorId = post.authorId;

        // ✅ Fetch user preferences
        const userSnap = await firestore
            .collection("users")
            .doc(authorId)
            .get();
        if (!userSnap.exists ||
        userSnap.data().notifyMentions === false) return;

        const payload = {
          notification: {
            title: "💬 New Comment on Your Post",
            body: "Someone commented on your post.",
          },
          token: userSnap.data().fcmToken,
        };

        await getMessaging().send(payload);
      } catch (error) {
        console.error("Error sending community notification:", error);
      }
    });

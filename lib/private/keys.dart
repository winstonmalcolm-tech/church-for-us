import 'package:google_generative_ai/google_generative_ai.dart';

const zegoCloudAppID = 347553958;
const zegoCloudAppSignIn = "322dd1f3a150e6cb8ca49e32584a5d32f2210e37c465400cacd13bfd3d2baa9b";
const aiAPIKEY = "AIzaSyAw5qUB5GnU3hHXfxiLdavOe4xJdqcsHTk";

final modelConfig = GenerativeModel(
  model: 'gemini-1.5-flash', 
  apiKey: aiAPIKEY,
  systemInstruction: Content.text("You are named Deacon. You only respond to questions regarding the Holy Bible, Christian hymns, and Christianity. Respond in 2 paragraphs or less. Be concise")
);
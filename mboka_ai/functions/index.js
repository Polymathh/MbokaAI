/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


// functions/index.js (or equivalent TypeScript)
const functions = require("firebase-functions");
const {GoogleGenAI} = require("@google/genai");

// NOTE: Ensure your GEMINI_API_KEY is set in your Firebase environment variables.
// firebase functions:config:set gemini.key="YOUR_API_KEY"
const ai = new GoogleGenAI({apiKey: functions.config().gemini.key});

// --- Template Prompts ---
const TEMPLATES = {
  "Elegant Studio": {
    prompt: (desc) => `Generate a professional, high-end studio product advertisement poster. Use a clean, minimalist white or gray background, subtle lighting, and elegant, modern Poppins-style typography. The product is: ${desc}. Include a short, punchy marketing caption on the image. Output only the image.`,
  },
  "Warm Bakery": {
    prompt: (desc) => `Design a cozy, rustic, and warm bakery advertisement poster. Use soft, golden lighting, wood textures, and a handwritten-style font. The product is: ${desc}. Include a caption like 'Freshly Baked' or 'Taste the Warmth'. Output only the image.`,
  },
  "Vibrant Market": {
    prompt: (desc) => `Create an energetic and colorful open-air market poster. Use bright, contrasting colors (like Sky Blue/Yellow) and a bold, African-inspired geometric pattern border. The product is: ${desc}. The image should convey freshness and local hustle. Output only the image.`,
  },
};

exports.generatePoster = functions.https.onCall(async (data, context) => {
  // 1. Authentication and Input Validation
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated to call this function.");
  }
  const {base64Image, description, templateName} = data;

  if (!base64Image || !description || !templateName || !TEMPLATES[templateName]) {
    throw new functions.https.HttpsError("invalid-argument", "Missing or invalid input parameters (image, description, or template).");
  }

  const template = TEMPLATES[templateName];

  // 2. Prepare the Image Part for the Gemini API
  const imagePart = {
    inlineData: {
      data: base64Image,
      mimeType: "image/jpeg", // Assuming JPEG input from client
    },
  };

  const model = "gemini-2.5-flash-image-preview";
  const finalPrompt = template.prompt(description);

  try {
    // 3. Call the Gemini Model
    const result = await ai.models.generateContent({
      model: model,
      contents: [
        imagePart, // The base product image
        {text: finalPrompt}, // The text prompt for styling
      ],
      config: {
        // IMPORTANT: Set output type to image/jpeg
        responseMimeType: "image/jpeg",
      },
    });

    // 4. Extract and Return the Generated Base64 Image
    const responseImagePart = result.candidates[0].content.parts.find((p) => p.inlineData);
    if (!responseImagePart) {
      throw new functions.https.HttpsError("internal", "AI did not return a valid image.");
    }

    return {
      status: "success",
      base64Poster: responseImagePart.inlineData.data, // The generated poster image
    };
  } catch (error) {
    // Log the error for internal diagnostics
    console.error("Gemini API Error:", error);

    // Error handling for rate limits or internal API issues
    throw new functions.https.HttpsError("unavailable", "AI Service Unavailable or Rate Limited. Please try again later.");
  }
});

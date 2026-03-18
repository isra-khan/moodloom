import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceMoodResult {
  final int moodLevel; // 1-5
  final String label;
  final double confidence; // 0.0 - 1.0

  FaceMoodResult({
    required this.moodLevel,
    required this.label,
    required this.confidence,
  });
}

class FaceMoodService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true, // Needed for smile/eye probability
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  /// Analyze a captured image and return mood based on facial expression.
  /// Returns null if no face detected.
  Future<FaceMoodResult?> detectMoodFromImage(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) return null;

    // Use the largest/first face
    final face = faces.first;
    final smilingProb = face.smilingProbability;
    final leftEyeOpen = face.leftEyeOpenProbability;
    final rightEyeOpen = face.rightEyeOpenProbability;

    if (smilingProb == null) return null;

    final eyeOpen = (leftEyeOpen != null && rightEyeOpen != null)
        ? (leftEyeOpen + rightEyeOpen) / 2
        : 1.0; // default to open if not detected

    return _mapToMood(smilingProb, eyeOpen);
  }

  FaceMoodResult _mapToMood(double smileProb, double eyeOpenProb) {
    // Big smile → Great
    if (smileProb > 0.7) {
      return FaceMoodResult(
        moodLevel: 5,
        label: 'You look really happy! 😄',
        confidence: smileProb,
      );
    }

    // Light smile → Good
    if (smileProb > 0.4) {
      return FaceMoodResult(
        moodLevel: 4,
        label: 'You seem to be in a good mood 😊',
        confidence: smileProb,
      );
    }

    // Neutral face → Okay
    if (smileProb > 0.2) {
      return FaceMoodResult(
        moodLevel: 3,
        label: 'You look pretty neutral 😐',
        confidence: smileProb,
      );
    }

    // No smile, eyes less open → Bad or Terrible
    if (smileProb <= 0.2 && eyeOpenProb < 0.4) {
      return FaceMoodResult(
        moodLevel: 1,
        label: 'You look like you\'re having a tough time 😢',
        confidence: 1.0 - smileProb,
      );
    }

    // No smile but eyes open → Bad
    return FaceMoodResult(
      moodLevel: 2,
      label: 'You seem a bit down 😔',
      confidence: 1.0 - smileProb,
    );
  }

  void dispose() {
    _faceDetector.close();
  }
}

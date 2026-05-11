import 'package:flutter/material.dart';
import 'package:study_hub/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO (Firebase): uncomment these two lines when Firebase is connected:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StudyHubApp());
}

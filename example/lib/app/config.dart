import 'package:camera_deep_ar/camera_deep_ar.dart';

DeepArConfig config = DeepArConfig(
  androidKey:
      "3b58c448bd650192e7c53d965cfe5dc1c341d2568b663a3962b7517c4ac6eeed0ba1fb2afe491a4b",
  ioskey:
      "53618212114fc16bbd7499c0c04c2ca11a4eed188dc20ed62a7f7eec02b41cb34d638e72945a6bf6",
  displayMode: DisplayMode.camera,
  cameraDirection: CameraDirection.front,
  cameraMode: CameraMode.mask,
  recordingMode: RecordingMode.photo,
  // displayMode: DisplayMode.camera,
);

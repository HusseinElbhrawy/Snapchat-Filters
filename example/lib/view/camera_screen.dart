// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:camera_deep_ar/camera_deep_ar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '/app/config.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final deepArController = CameraDeepArController(config);
  String _platformVersion = 'Unknown';
  bool isRecording = false;
  CameraMode cameraMode = config.cameraMode;
  DisplayMode displayMode = config.displayMode;
  int currentEffect = 0;

  List get effectList {
    switch (cameraMode) {
      case CameraMode.mask:
        return masks;

      case CameraMode.effect:
        return effects;

      case CameraMode.filter:
        return filters;

      default:
        return masks;
    }
  }

  List masks = [
    "none",
    "assets/images/aviators",
    "assets/images/bigmouth",
    "assets/images/lion",
    "assets/images/dalmatian",
    "assets/images/bcgseg",
    "assets/images/look2",
    "assets/images/fatify",
    "assets/images/flowers",
    "assets/images/grumpycat",
    "assets/images/koala",
    "assets/images/mudmask",
    "assets/images/obama",
    "assets/images/pug",
    "assets/images/slash",
    "assets/images/sleepingmask",
    "assets/images/smallface",
    "assets/images/teddycigar",
    "assets/images/tripleface",
    "assets/images/twistedface",
  ];
  List effects = [
    "none",
    "assets/images/fire",
    "assets/images/heart",
    "assets/images/blizzard",
    "assets/images/rain",
  ];
  List filters = [
    "none",
    "assets/images/drawingmanga",
    "assets/images/sepia",
    "assets/images/bleachbypass",
    "assets/images/realvhs",
    "assets/images/filmcolorperfection"
  ];

  void _init() async {
    await CameraDeepArController.checkPermissions();
    deepArController.setEventHandler(DeepArEventHandler(onCameraReady: (v) {
      _platformVersion = "onCameraReady $v";
      setState(() {});
    }, onSnapPhotoCompleted: (v) {
      _platformVersion = "onSnapPhotoCompleted $v";
      setState(() {});
    }, onVideoRecordingComplete: (v) {
      _platformVersion = "onVideoRecordingComplete $v";
      setState(() {});
    }, onSwitchEffect: (v) {
      _platformVersion = "onSwitchEffect $v";
      setState(() {});
    }));
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    deepArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DeepArPreview(deepArController),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Response >>> : $_platformVersion\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () async {
                      _init();

                      if (isRecording) return;
                      await deepArController.snapPhoto();
                    },
                    child: Icon(Icons.camera_enhance_outlined),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(15),
                    ),
                  ),

                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        effectList.length,
                        (index) {
                          bool active = currentEffect == index;
                          String imgPath = effectList[index];
                          return GestureDetector(
                            onTap: () async {
                              if (!deepArController.value.isInitialized) return;
                              currentEffect = index;
                              deepArController.switchEffect(
                                  cameraMode, imgPath);
                              setState(() {});
                            },
                            child: AnimatedContainer(
                              margin: EdgeInsets.all(6),
                              width: active ? 70 : 55,
                              height: active ? 70 : 55,
                              alignment: Alignment.center,
                              child: Text(
                                "$index",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: active ? FontWeight.bold : null,
                                  fontSize: active ? 16 : 14,
                                  color: active ? Colors.white : Colors.black,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: active ? Colors.orange : Colors.white,
                                border: Border.all(
                                  color: active ? Colors.orange : Colors.white,
                                  width: active ? 2 : 0,
                                ),
                                shape: BoxShape.circle,
                              ),
                              duration: Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  //! Camera Mode

                  Row(
                    children: List.generate(
                      CameraMode.values.length,
                      (p) {
                        CameraMode mode = CameraMode.values[p];
                        bool active = cameraMode == mode;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextButton(
                              onPressed: () async {
                                cameraMode = mode;
                                setState(() {});
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: active
                                    ? Colors.orange
                                    : Colors.white.withOpacity(0.6),
                              ),
                              child: AnimatedDefaultTextStyle(
                                child: Text(
                                  describeEnum(mode).toUpperCase(),
                                  textAlign: TextAlign.center,
                                ),
                                style: TextStyle(
                                  fontWeight: active ? FontWeight.bold : null,
                                  fontSize: active ? 16 : 14,
                                  color: Colors.white.withOpacity(
                                    active ? 1 : 0.6,
                                  ),
                                ),
                                duration: Duration(milliseconds: 300),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  static Future<File> _loadFile(String path, String name) async {
    final ByteData data = await rootBundle.load(path);
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/$name');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return tempFile;
  }
}

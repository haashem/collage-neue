import 'dart:async';
import 'dart:ui' as ui;

import 'package:collage_neue/collage_neue_model.dart';
import 'package:collage_neue/photo_gallery_page.dart';
import 'package:collage_neue/utilties/show_alert_dialog.dart';
import 'package:flutter/material.dart';

class CreateCollegePhotoPage extends StatefulWidget {
  const CreateCollegePhotoPage({super.key});

  @override
  State<CreateCollegePhotoPage> createState() => _CreateCollegePhotoPageState();
}

class _CreateCollegePhotoPageState extends State<CreateCollegePhotoPage> {
  final model = CollageNeueModel();

  bool saveIsEnabled = true;
  bool clearIsEnabled = true;
  bool addIsEnabled = true;
  String title = 'Collage Neue';

  void updateUI(int photosCount) {
    setState(() {
      saveIsEnabled = photosCount > 0 && photosCount % 2 == 0;
      clearIsEnabled = photosCount > 0;
      addIsEnabled = photosCount < 6;
      title = photosCount > 0 ? '$photosCount photos' : 'Collage Neue';
    });
  }

  @override
  void initState() {
    super.initState();
    model.bindMainView();
    model.photosCount.addListener(() {
      updateUI(model.photosCount.value);
    });

     listenToPhotoSaveResult(context, model);
  }

  StreamSubscription<String>? savedPhotoIdSubscription;
  void listenToPhotoSaveResult(BuildContext context, CollageNeueModel model) {
    savedPhotoIdSubscription = model.savedPhotoId.listen((id) {
      if (!context.mounted) {
        return;
      }
      showAlertDialog(context,
          title: 'Success', message: 'Photo saved with ID: $id');
    }, onError: (error) {
      if (!context.mounted) {
        return;
      }
      showAlertDialog(context, title: 'Error', message: error.toString());
    });
  }

  @override
  void dispose() {
    model.dispose();
    savedPhotoIdSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                model.add();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PhotoGalleryPage(
                      model: model,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            const canvasHeight = 200.0;
            model.canvasSize = Size(constraints.maxWidth, canvasHeight);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValueListenableBuilder<ui.Image?>(
                  valueListenable: model.previewImage,
                  builder: (context, image, _) {
                    return Container(
                      height: canvasHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: image != null
                          ? () {
                              return RawImage(
                                image: image,
                                fit: BoxFit.cover,
                              );
                            }()
                          : const Center(
                              child: Text('No Image'),
                            ),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: clearIsEnabled ? model.clear : null,
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: saveIsEnabled ? model.save : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        ));
  }
}

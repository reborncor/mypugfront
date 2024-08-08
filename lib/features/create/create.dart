import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypug/components/assetthumbnail/assetthumbnail.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../components/editpug/editpug.dart';

class CreatePug extends StatefulWidget {
  final routeName = '/create';

  const CreatePug({Key? key}) : super(key: key);

  @override
  CreatePugState createState() => CreatePugState();
}

class CreatePugState extends State<CreatePug> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ImagePicker _picker = ImagePicker();
  File? imageFile;
  Future<File?>? selectedImage;
  StreamController imageStreamController = StreamController();
  List<AssetEntity> assets = [];
  late ThemeModel notifier;
  late SuperTooltip tooltip;
  var varImagesGallery;
  late String isNotFirstUse;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tooltip = SuperTooltip(
        popupDirection: TooltipDirection.up,
        showCloseButton: ShowCloseButton.inside,
        borderRadius: 30,
        minWidth: 200,
        maxWidth: 320,
        maxHeight: 100,
        minHeight: 100,
        shadowColor: APPCOLOR,
        content: Material(
            color: Colors.transparent,
            child: Center(
                child: Text(
              "Choisissez une image nette",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: notifier.isDark ? Colors.black : Colors.black),
              softWrap: true,
            ))),
      );

      getUserFirstUse().then((value) async => {
            if (value.isNotEmpty && value.length < 5)
              {
                tooltip.show(context),
              }
          });
    });
    super.initState();
    getGalleryImages();
  }

  requestAccess() async {
    PermissionStatus status;
    status = await Permission.storage.status;
    if (status.isDenied) {}
  }

  getGalleryImages() async {
    await _fetchAssets();
    varImagesGallery = imagesGallery();
  }

  _fetchAssets() async {
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;

    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0,
      end: 50,
    );

    await recentAssets[0].file.then((value) => {imageFile = value});

    setState(() => {
          assets = recentAssets,
          imageFile,
          imageStreamController.add(imageFile),
        });
  }

  _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      imageFile = File(image!.path);
    });
  }

  _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      imageFile = File(image!.path);
    });
  }

  callBack(Future<File?> file) async {
    imageFile = await file;
    file.then((value) => {
          setState(
            () {
              selectedImage = file;
              imageFile;
              imageStreamController.add(imageFile);
            },
          )
        });
  }

  bool fitImage = true;
  double? pugWidth;
  bool constrained = true;
  basicRender() {
    return Stack(children: [
      InteractiveViewer(
          constrained: constrained,
          maxScale: 5,
          minScale: 0.01,
          boundaryMargin: const EdgeInsets.only(
            bottom: 50,
            left: 62,
            right: 62,
          ),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.46,
            child: Image.file(
              imageFile!,
              fit: fitImage ? BoxFit.fitWidth : BoxFit.fitHeight,
            ),
          )),
    ]);
  }

  Future<String> createFolderInAppDocDir() async {
    //Get this App Document Directory
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    // print(_appDocDir);
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/images_tmp');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  Widget imageView() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: StreamBuilder<dynamic>(
        stream: imageStreamController.stream,
        builder: (_, snapshot) {
          if (imageFile == null) {
            return Container();
          } else {
            return basicRender();
          }
        },
      ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tmp_image.png');
  }

  Future<File?> writeData() async {
    final file = await _localFile;
    if (!file.existsSync()) {
      final newFile = await _localFile;
      return newFile.writeAsString("test", mode: FileMode.write);
    }
    ;
    return null;
  }

  Widget imageButtonOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ElevatedButton(
              style: BaseButtonRoundedColor(60, 40, Colors.indigo[300]),
              onPressed: () {
                _imgFromGallery();
              },
              child: const Text('Galerie'),
            ),
            ElevatedButton(
              style: BaseButtonRoundedColor(60, 40, Colors.indigo[300]),
              onPressed: () {
                _imgFromCamera();
              },
              child: const Text('Photo'),
            ),
          ],
        ),
        ElevatedButton(
            style: BaseButtonRoundedColor(60, 40, Colors.indigo[300]),
            onPressed: () async {
              var decodedImage =
                  await decodeImageFromList(imageFile!.readAsBytesSync());
              navigateTo(
                  context,
                  EditPug.withFile(
                    file: imageFile,
                    decodedImage: decodedImage,
                  ));
            },
            child: const Text('Valider'))
      ],
    );
  }

  Widget imagesGallery() {
    return Expanded(
        child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: assets.length,
      itemBuilder: (_, index) {
        return AssetThumbnail(
          asset: assets[index],
          callback: callBack,
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.notifier = notifier;
        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text("Créer"),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.black,
            ),
            body: Container(
              decoration: const BoxDecoration(),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Stack(children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [imageView()]),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.46,
                    left: 10,
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                          color: APP_COMMENT_COLOR,
                          borderRadius: BorderRadius.circular(20)),
                      child: RotationTransition(
                        turns: const AlwaysStoppedAnimation(45 / 360),
                        child: IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.unfold_more),
                          onPressed: () {
                            fitImage = !fitImage;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: 45 * MediaQuery.of(context).size.height / 100,
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          imageButtonOption(),
                          varImagesGallery ??
                              const SizedBox(
                                width: 0,
                              ),
                        ],
                      ),
                      decoration: BoxCircular(notifier),
                    ),
                  ),
                ]),
              ),
            ));
      },
    );
  }
}

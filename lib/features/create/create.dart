

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypug/components/assetthumbnail/assetthumbnail.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/editpug/editpug.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';

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
  late bool isCrop = true;
  late Widget varImagesGallery;
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
            child: Center(child:  Text(
              "Choisissez une image nette",
              textAlign: TextAlign.center,
              style: TextStyle(color: notifier.isDark ? Colors.black : Colors.black),
              softWrap: true,
            ))),
      );
      tooltip.show(context);

    });
    super.initState();
    getGalleryImages();

  }
  getGalleryImages() async {
    await _fetchAssets();
    varImagesGallery = imagesGallery();
  }

  _fetchAssets() async {
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 50, // end at a very big index (to get all the assets)
    );


    // Update the state and notify UI
    await recentAssets[0].file.then((value) => {imageFile = value});

    setState(() => {
      assets = recentAssets,
      imageFile,
      imageStreamController.add(imageFile),
    });
  }


  _imgFromCamera() async {
    XFile? image = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      imageFile = File(image!.path);
    });
  }

  _imgFromGallery() async {
    XFile? image = await  _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );


    setState(() {
      imageFile = File(image!.path);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }


callBack(Future<File?> file) async {
    imageFile = await file;
    file.then((value) => {
    setState(() {
    selectedImage = file;
    imageFile;
    imageStreamController.add(imageFile);
    },
   )
    });

}

  Widget imageView(){
    return  Container(
      color: Colors.black,


      alignment: Alignment.center,
      child: StreamBuilder<dynamic>(
      stream: imageStreamController.stream,
        builder: (_, snapshot) {
          if (imageFile == null) {
            return Container();
          } else{
            return SizedBox(width: 500, height: 500, child: AspectRatio(aspectRatio: 4/5, child: Image.file(imageFile!,fit: isCrop ? BoxFit.fitWidth : BoxFit.contain),),);
          }
        },
      ),


    );
  }

  Widget imageButtonOption(){
    return   Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      // ElevatedButton(
      //   onPressed: () {
      //     _showPicker(context);
      //   },
      //   child: Text('Open Gallery'),
      // ),
        Row(children: [ ElevatedButton(
          style: BaseButtonRoundedColor(60,40,Colors.indigo[300]),
          onPressed: () {
            _imgFromGallery();
          },
          child: Text('Galerie'),
        ),
          ElevatedButton(
            style: BaseButtonRoundedColor(60,40,Colors.indigo[300]),
            onPressed: () {
              _imgFromCamera();
            },
            child: Text('Photo'),
          ),
        IconButton(onPressed: (){
          isCrop = !isCrop;
          setState(() {

        });}, icon: const Icon(Icons.crop))],),
      ElevatedButton(
          style: BaseButtonRoundedColor(60,40,Colors.indigo[300]),
          onPressed: () {
        navigateTo(context, EditPug.withFile(file: imageFile));

      }, child: const Text('Valider'))
    ],);
  }

  Widget imagesGallery(){
    return Expanded(child:
    GridView.builder(

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        // A grid view with 3 items per row
        crossAxisCount: 3,
      ),
      itemCount: assets.length,
      itemBuilder: (_, index) {
        return AssetThumbnail(asset: assets[index],callback: callBack,);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, ThemeModel notifier, child) {
      this.notifier = notifier;
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Créer"),
          automaticallyImplyLeading: false,

          backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
        ),
        body: Container(
          decoration: BoxDecoration(),
          child: Padding(padding:  const EdgeInsets.all(3),
            child: Container(child:  Column(
              children: <Widget>[
                imageView(),
                // Text('There are ${assets.length} assets'),
                imageButtonOption(),
                varImagesGallery,



              ],
            ), decoration: BoxCircular(notifier),) ,),
        )
      );
    },);
  }
}

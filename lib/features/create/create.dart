

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypug/components/assetthumbnail/assetthumbnail.dart';
import 'package:mypug/components/editpug/editpug.dart';
import 'package:mypug/components/pug/pug.dart';
import 'package:mypug/util/util.dart';
import 'package:photo_manager/photo_manager.dart';

class Create extends StatefulWidget {

  final routeName = '/create';

  const Create({Key? key}) : super(key: key);

  @override
  CreateState createState() => CreateState();
}

class CreateState extends State<Create> {

  final ImagePicker _picker = ImagePicker();
  File? imageFile;
  Future<File?>? selectedImage;
  StreamController imageStreamController = StreamController();
  List<AssetEntity> assets = [];
  @override
  void initState() {

    super.initState();
    _fetchAssets();
  }

  _fetchAssets() async {
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 500, // end at a very big index (to get all the assets)
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
            return Image.file(imageFile!,height: 400,);
          }
        },
      ),
    );
  }

  Widget imageButtonOption(){
    return   Row(children: [
      // ElevatedButton(
      //   onPressed: () {
      //     _showPicker(context);
      //   },
      //   child: Text('Open Gallery'),
      // ),
      ElevatedButton(
        onPressed: () {
          _imgFromGallery();
        },
        child: Text('Galery'),
      ),
      ElevatedButton(
        onPressed: () {
          _imgFromCamera();
        },
        child: Text('Photo'),
      ),
      ElevatedButton(onPressed: () {
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
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
        imageView(),
          // Text('There are ${assets.length} assets'),
        imageButtonOption(),
          imagesGallery(),


        ],
      ),
    );
  }
}

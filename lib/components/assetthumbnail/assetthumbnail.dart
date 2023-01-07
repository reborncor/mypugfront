import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/util/util.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({
    Key? key,
    required this.asset,
    required this.callback,
  }) : super(key: key);

  final AssetEntity asset;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;

        if (bytes == null)
          return CircularProgressIndicator(
            color: APPCOLOR,
          );

        return InkWell(
          onTap: () {
            if (asset.type == AssetType.image) {
              callback(asset.file);
            } else {
              showSnackBar(context, 'Veuillez choisir une photo');
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
              if (asset.type == AssetType.video)
                Center(
                  child: Container(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

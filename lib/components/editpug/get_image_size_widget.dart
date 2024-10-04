import 'dart:io';

import 'package:flutter/material.dart';

class GetImageSize extends StatefulWidget {
  final Function(double height, double width) onDataSize;
  final File croppedFile;
  final double dottedBoxHeight;

  const GetImageSize(
      {super.key,
      required this.onDataSize,
      required this.croppedFile,
      required this.dottedBoxHeight});

  @override
  _GetImageSizeState createState() => _GetImageSizeState();
}

class _GetImageSizeState extends State<GetImageSize> {
  final _imgKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 620)).then((value) {
      RenderBox box = _imgKey.currentContext!.findRenderObject() as RenderBox;
      widget.onDataSize(box.size.height, box.size.width);
      Navigator.of(context).pop();
    });
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: widget.dottedBoxHeight,
                child: Image(
                  key: _imgKey,
                  image: FileImage(widget.croppedFile),
                ),
              ),
            ]),
      ),
    );
  }
}

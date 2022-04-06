
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/features/create/api.dart';
import 'package:mypug/util/util.dart';


class EditPug extends StatefulWidget {

  final routeName = '/editpug';
  final File? file;
  const EditPug({Key? key, this.file}) : super(key: key);

  const EditPug.withFile({Key? key, required this.file}) : super(key: key);

  @override
  EditPugState createState() => EditPugState();
}

class EditPugState extends State<EditPug> {

  late File file;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textTitleController = TextEditingController();

  String imageTitle ="";
  String imageDescription ="";
  double x = 0.0;
  double y = 0.0;
  List<Offset> points = [Offset(50, 50),
    Offset(80, 70),
    Offset(200, 175),
   ];

  bool isExpanded = false;
  bool isVisible = false;
  @override
  void initState() {

    file = widget.file!;
    super.initState();

  }




  Widget textsOnImage(){
    return   Stack(children: points.map((e) => Positioned(child: Text(textEditingController.text, style: TextStyle(fontSize: 15, color: Colors.white),), left: e.dx, top: e.dy, ),).toList()
    );
  }

  Widget imageContent(File image){
    return GestureDetector(
      child: Container(
        child:
        Container(
          height: 300,
          child: Visibility(
            visible: isVisible,
            child: Stack(
              children: [
                CustomPaint(painter: OpenPainter(points: points)),
                textsOnImage()
              ],),) ,
        ),
        height: 300,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.fitWidth,
            )
        ),
      ),onTap: () {},
      onTapDown: (TapDownDetails details){
            x = details.localPosition.dx.toInt().toDouble();
            y = details.localPosition.dy.toInt().toDouble();
            log('$x et $y');

      },
    );

  }

  addNewTextOnImage(double x, double y){
    if(points.length >= 10){
      showSnackBar(context, 'Vous ne pouvez plus ajouter de détail');
    }
    else{
      if(x != 0.0 && y != 0.0){
        points.add(Offset(x,y));
        setState(() {

        });
      }
    }
  }
  Widget imageInformation(String title){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: TextField(
            controller: textTitleController,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
          )),
          ElevatedButton(onPressed: () {
            setState(() {
              isVisible = !isVisible;
            });
          }, child: Text('Show/Hide'))

        ],) ,
    );
  }

  Widget imageDetail(String detail){
    return Column(
      children: [TextField(
      controller: textEditingController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
    ),
      ElevatedButton(onPressed: () {
        log(textEditingController.text);
        addNewTextOnImage(x, y);
      }, child: Text("Valider")),
      ElevatedButton(onPressed: () async {
        var result = await createPug(file);


      }, child: Text("Envoyer"))],

    );

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.white,

        body:  ListView(
          children: [
            imageContent(file),
            imageInformation(imageTitle),
            imageDetail(imageDescription)

          ],
        )

    );
  }
}

class OpenPainter extends CustomPainter {


  final List<Offset> points ;
  OpenPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round //rounded points
      ..strokeWidth = 10;
    //list of points
    var points = this.points;
    //draw points on canvas
    canvas.drawPoints(PointMode.points, points, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
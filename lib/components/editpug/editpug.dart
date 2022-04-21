
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/features/create/api.dart';
import 'package:mypug/models/pugdetailmodel.dart';
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
  TextEditingController textDescriptionController = TextEditingController();

  List<PugDetailModel> details = [];

  String imageTitle ="";
  String imageDescription ="";
  double x = 0.0;
  double y = 0.0;
  List<Offset> points = [
    Offset(50, 50),
    Offset(80, 70),
    Offset(200, 175),
   ];

  bool isExpanded = false;
  bool isVisible = false;
  @override
  void initState() {

    details.clear();
    file = widget.file!;
    super.initState();

  }

  addNewPugDetails(double positionX, double positionY,String text){
    PugDetailModel model = PugDetailModel(positionX: positionX.toInt(), positionY: positionY.toInt(), text: text);
    details.add(model);
    setState(() {

    });
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
          height: 600,
          child: Visibility(
            visible: isVisible,
            child: Stack(
              children: [
                CustomPaint(painter: OpenPainter(points: points)),
                textsOnImage()
              ],),) ,
        ),
        height: 600,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.contain,
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

  addNewTextOnImage(double x, double y,String text){
    if(points.length >= 10){
      showSnackBar(context, 'Vous ne pouvez plus ajouter de détail');
    }
    else{
      if(x != 0.0 && y != 0.0){
        points.add(Offset(x,y));
        addNewPugDetails(x, y, text);
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
            decoration: const InputDecoration(
              hintText: 'titre'
            ),
            controller: textTitleController,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
          )),
          ElevatedButton(
              style: BaseButtonRoundedColor(40, 60, APPCOLOR),
              onPressed: () {
            setState(() {
              isVisible = !isVisible;
            });
          }, child: Text('Afficher/Masquer'))

        ],) ,
    );
  }

  Widget imageDetail(String detail){
    return Column(
      children: [
        TextField(
          controller: textDescriptionController,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines:1,
          maxLines: 4,
          decoration: InputDecoration(hintText: "Description"),
        ),
        TextField(
      controller: textEditingController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: "pug information"),
    ),
      ElevatedButton(
          style: BaseButtonRoundedColor(40, 40, APPCOLOR),

          onPressed: () {
        log(textEditingController.text);
        addNewTextOnImage(x, y,textEditingController.text);
      }, child: Text("Ajouter une information")),
      ElevatedButton(
          style: BaseButtonRoundedColor(40, 40, APPCOLOR),
          onPressed: () async {
        var result = await createPug(file,textTitleController.text,textDescriptionController.text,details);
        showSnackBar(context, result.message);


      }, child: Text("Envoyer"))],

    );

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: APPCOLOR,),

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
      ..color = APPCOLOR
      ..strokeCap = StrokeCap.round //rounded points
      ..strokeWidth = 15;
    //list of points
    var points = this.points;
    //draw points on canvas
    canvas.drawPoints(PointMode.points, points, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
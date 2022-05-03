
import 'dart:async';
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
  StreamController streamController = StreamController();

  List<PugDetailModel> details = [];

  String imageTitle ="";
  String imageDescription ="";
  double x = 0.0;
  double y = 0.0;
  List<Offset> points = [
    Offset(200, 300),
    Offset(250, 300),
    Offset(300, 300),
    Offset(350, 300),
   ];


  bool isExpanded = false;
  bool isVisible = true;
  bool isTextVisible = false;
  @override
  void initState() {

    details.clear();
    file = widget.file!;
    super.initState();

  }

  addNewPugDetails(double positionX, double positionY,String text){
    PugDetailModel model = PugDetailModel(positionX: positionX.toInt(), positionY: positionY.toInt(), text: text);

    points.add(Offset(x,y));
    details.add(model);
    streamController.add("ok");
    log(details.length.toString());
  }


  Widget textsOnImage(){
    return   Stack(children: details.map((e) => Positioned(child: Text(e.text, style: TextStyle(fontSize: 15, color: Colors.white),), left: e.positionX+10, top: e.positionY+30, ),).toList()
    );
  }
  Widget dataDetails(){
    return   Stack(children: details.map((e) => Positioned(child: Image( image : AssetImage('asset/images/r-logo.png',), width: 40, height: 40, color: APPCOLOR,), left: e.positionX.toDouble(), top: e.positionY.toDouble(), ),).toList()
    );

  }
  Widget textPugEditor(){
    log('$x et $y');
    return Visibility( visible : isTextVisible,
        child: Positioned(
          width: 200,
          child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(Icons.check),
                    onPressed: (){
                      addNewPugDetails(x-100, y, textEditingController.text);
                      textEditingController.clear();
                    },)))
          , left: x-100, top: y,));
  }

  Widget imageContent(File image){
    return GestureDetector(
      child: Container(
        child: StreamBuilder(
          stream: streamController.stream,
         builder: (context, snapshot) {
           return Container(
             height: 600,
             child: Stack(
               children: [
                 Visibility(
                   visible: isVisible,
                   child: dataDetails(),),
                 Visibility(
                   visible: isVisible,
                   child: textsOnImage(),),
                 textPugEditor(),

                 Positioned(
                   child: ClipOval(
                     child: Material(
                       color: APPCOLOR, // Button color
                       child: InkWell(
                         splashColor: Colors.red, // Splash color
                         onTap: () {
                           showSnackBar(context, "Cliquer sur l'écran pour choisir la position");
                           isTextVisible = true;
                           setState(() {

                           });
                         },
                         child: SizedBox(width: 50, height: 50, child: Icon(Icons.add)),
                       ),
                     ),
                   ),width: 50, height: 50, left: 350, top: 550,)
               ],
             ),
           );
         },
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
            setState(() {

            });
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

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/features/create/api.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';


class EditPug extends StatefulWidget {

  final routeName = '/editpug';
  final File? file;
  const EditPug({Key? key, this.file}) : super(key: key);

  const EditPug.withFile({Key? key, required this.file}) : super(key: key);

  @override
  EditPugState createState() => EditPugState();
}

class EditPugState extends State<EditPug> {

  late AppBar appBar;
  late File file;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textTitleController = TextEditingController();
  TextEditingController textDescriptionController = TextEditingController();
  StreamController streamController = StreamController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final dragController = DragController();

  List<PugDetailModel> details = [];

  String imageTitle ="";
  String imageDescription ="";
  double x = 200.0;
  double y = 200.0;
  List<Offset> points = [
   ];


  bool isExpanded = false;
  bool isVisible = true;
  bool isTextVisible = false;
  late ThemeModel notifier;
  late SuperTooltip tooltip;
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

        content: const Material(
          color: Colors.transparent,
            child: Center(child:  Text(
              "Indiquer au moins une référécence",
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
              softWrap: true,
            ))),
      );
      tooltip.show(context);

    });

    details.clear();
    file = widget.file!;
    super.initState();

  }

  addNewPugDetails(double positionX, double positionY,String text){
    if(details.length <= 5){
      PugDetailModel model = PugDetailModel(positionX: positionX.toInt(), positionY: positionY.toInt(), text: text);

      points.add(Offset(x,y));
      details.add(model);
      streamController.add("ok");
    }
    else{
      showSnackBar(context, "Vous avez atteint la limite de référence");
    }

    // log(details.length.toString());
  }


  Widget textsOnImage(){
    return   Stack(children: details.map((e) => Positioned(child: Text(e.text, style: TextStyle(fontSize: 15, color: Colors.white),), left: e.positionX+10, top: e.positionY+30, ),).toList()
    );
  }
  Widget dataDetails(){
    return   Stack(children: details.map((e) => Positioned(child: Image( image : AssetImage('asset/images/r-logo.png',), width: 40, height: 40, color: APPCOLOR,), left: e.positionX.toDouble(), top: e.positionY.toDouble(), ),).toList()
    );

  }

  Widget draggrableWidget(){
    return Image.asset("asset/images/r-logo.png", width: 40, height: 40, color: APPCOLOR,);

  }

  Widget textPugEditor(){
    log('$x ET $y');
    return  Positioned(
        left: x,
        top: y- appBar.preferredSize.height -
            MediaQuery.of(context).padding.top,

        child: Draggable(
            onDragStarted: (){
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            feedback:  draggrableWidget(),
            childWhenDragging: const SizedBox(width: 0,height: 0,),
            onDragEnd: (details){
              x = details.offset.dx;
              y = details.offset.dy;
              log("$x et $y");
              setState(() {

              });
            },
        child :Visibility( visible : isTextVisible,
          child: Positioned(
            child: Wrap(
              spacing: 1,
                direction: Axis.vertical,
                children: [
                  Image.asset("asset/images/r-logo.png", width: 40, height: 40, color: APPCOLOR,),
                  Container(
                      width:150,
                      child: TextField(
                          controller: textEditingController,

                          decoration: InputDecoration(

                              enabledBorder: setUnderlineBorder(3.0, 5.0),
                              focusedBorder: setUnderlineBorder(3.0, 5.0),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.check,color: APPCOLOR),
                                onPressed: (){
                                  addNewPugDetails(x, y-appBar.preferredSize.height -
                                      MediaQuery.of(context).padding.top, textEditingController.text);
                                  textEditingController.clear();
                                },))))
                ])
            , left: x, top: y,),)));

  }



  Widget imageContent(File image){

    return Container(
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
                           // showSnackBar(_scaffoldKey.currentContext, "Cliquer sur l'écran pour choisir la position");
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
        mainAxisAlignment: MainAxisAlignment.center,
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
      onChanged: (value){

      },
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: "pug information"),
    ),
      ElevatedButton(
          style: BaseButtonRoundedColor(40, 40, APPCOLOR),

          onPressed: () {
        log(textEditingController.text);
        addNewTextOnImage(x, y,textEditingController.text);
      }, child: Text("Ajouter une référécence")),
      ElevatedButton(
          style: BaseButtonRoundedColor(40, 40, APPCOLOR),
          onPressed: () async {
        var result = await createPug(file,textTitleController.text,textDescriptionController.text,details);

        if(result.code == SUCCESS_CODE){
          showSnackBar(context, result.message);

        }
        else{

        }


      }, child: Text("Envoyer"))],

    );

  }



  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder:(context, ThemeModel notifier, child) {
      this.notifier = notifier;
      return Scaffold(
        key: _scaffoldKey,
          appBar: appBar = AppBar(backgroundColor: APPCOLOR,title: Text("Edition"),),

          body:  ListView(
            children: [
              imageContent(file),
              imageInformation(imageTitle),
              imageDetail(imageDescription)

            ],
          )

      );
    },);
  }
}


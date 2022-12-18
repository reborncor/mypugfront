
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_mention/instagram_mention.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/tab/tab.dart';
import 'package:mypug/features/create/api.dart';
import 'package:mypug/features/profile/profile.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';


class EditPug extends StatefulWidget {

  final routeName = '/editpug';
  final File? file;
  final bool isCrop;
  const EditPug({Key? key, this.file, this.isCrop = false}) : super(key: key);

  const EditPug.withFile({Key? key, required this.file, required this.isCrop}) : super(key: key);

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
  double width = 500;
  double height = 500;
  late int imageHeight = PUGSIZE.toInt();

  List<PugDetailModel> details = [];
  late String pugDetailText = "";
  String imageTitle ="";
  String imageDescription ="";
  double x = 250.0;
  double y = 500.0;

  double pugBasicPositionX = 200.0;
  double pugBasicPositionY = 350.0;
  List<Offset> points = [
   ];


  bool isExpanded = false;
  bool isVisible = true;
  bool isTextVisible = false;
  bool showEditor = true;
  late ThemeModel notifier;
  late SuperTooltip tooltip;
  @override
  void initState() {

    WidgetsBinding.instance!.addPostFrameCallback((_) {

      width = getPhoneWidth(context);
      height = getPhoneHeight(context);

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

      getUserFirstUse().then((value) => {
        if(value.isNotEmpty){
          tooltip.show(context)
        }
      });

    });



    details.clear();
    file = widget.file!;
    Image image = Image.file(file);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          imageHeight = (myImage.height > PUGSIZE) ? PUGSIZE.toInt() : myImage.height ;
        },
      ),
    );



    setState(() {

    });
    super.initState();


  }

  addNewPugDetails(double positionX, double positionY,String text){
    if(details.length <= 5){
      PugDetailModel model = PugDetailModel(positionX: positionX.toInt(), positionY: positionY.toInt(), text: text);
      details.add(model);
      // streamController.add("ok");
    }
    else{
      showSnackBar(context, "Vous avez atteint la limite de référence");
    }
    //
    setState(() {

    });

  }


  Widget dataTagDetails(){

    return Stack(children: details.map((e) =>
        Positioned(
          left: e.positionX.toDouble(),
          top: e.positionY.toDouble(),

          child: Draggable(

              onDragEnd: (detailsDrag){
                e.positionX = detailsDrag.offset.dx.toInt();
                e.positionY = detailsDrag.offset.dy.toInt() - appBar.preferredSize.height.toInt() -
                    MediaQuery.of(context).padding.top.toInt();
                setState(() {

                });
              },

              childWhenDragging: const SizedBox(width: 0,height: 0,),

              child:
              GestureDetector(
                  onTap: (){
                    details.remove(e);
                    setState(() {

                    });
                  },
                  child: Badge(badgeContent: Text('X'), child:  Center(child : InstagramMention(text: e.text,color: APP_COMMENT_COLOR)),) , ),
              feedback: draggablePugDetailItem(e.text)),
        )
        ).toList());


  }

  Widget draggablePugDetailItem(String text){
    return InstagramMention(text: text,color: APP_COMMENT_COLOR);

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
              setState(() {

              });
            },
        child :Visibility( visible : isTextVisible,
            child: Wrap(
              spacing: 1,
                direction: Axis.vertical,
                children: [
                  // Image.asset("asset/images/r-logo.png", width: 40, height: 40, color: APPCOLOR,),



                  Container(
                      width:120,
                      height: 150,
                      child: Visibility(
                        visible: showEditor,
                        child: TextField(
                          textInputAction: TextInputAction.newline,
                          maxLength: 25,
                          controller: textEditingController,
                          cursorColor: APPCOLOR,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "...",
                            hintStyle: TextStyle(fontSize: 30),
                            filled: true,
                              fillColor: APP_COLOR_SEARCH,

                              enabledBorder: setOutlineBorder(2.0, 5.0),
                              focusedBorder: setOutlineBorder(2.0, 5.0),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.check,color: APPCOLOR),
                                onPressed: (){
                                  //TODO:test
                                  if(textEditingController.text.isNotEmpty){
                                    addNewPugDetails(pugBasicPositionX, pugBasicPositionY-appBar.preferredSize.height -
                                        MediaQuery.of(context).padding.top, textEditingController.text);
                                    textEditingController.clear();
                                  }
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  // showEditor = false;
                                },))),))
                ])
            ,)));

  }



  Widget imageContent(File image){

    return Container(
        child: StreamBuilder(
          stream: streamController.stream,
         builder: (context, snapshot) {
           return Container(
             height: PUGSIZE,
             child: Stack(

               children: [

                 textPugEditor(),
                 Visibility(
                   visible: isVisible,
                   child: dataTagDetails(),),


                 Positioned(
                   child: ClipOval(
                     child: Material(
                       color: APPCOLOR, // Button color
                       child: InkWell(
                         splashColor: Colors.red, // Splash color
                         onTap: () {
                           isTextVisible = true;
                           showEditor = true;
                           x = 280.00;
                           y = 550.00;
                           setState(() {

                           });
                         },
                         child: SizedBox(width: 50, height: 50, child: Icon(Icons.add)),
                       ),
                     ),
                   ),width: 50, height: 50, left: getPhoneWidth(context) - 75, top: 550,)
               ],
             ),
           );
         },
       ),
        height: PUGSIZE,
        decoration: BoxDecoration(
            image: DecorationImage(

              image: FileImage(image),
              fit: widget.isCrop ? BoxFit.fitWidth : BoxFit.contain,

            )
        ),
      );

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
        SizedBox(width: 0,height: 20,),
        Container(
          width: 600,
          child: TextField(
            style: TextStyle(color: notifier.isDark ? Colors.white : Colors.black),
          controller: textDescriptionController,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines:1,
          maxLines: 4,
          decoration: InputDecoration(hintText: "Description",
            hintStyle: TextStyle(color: notifier.isDark ? Colors.white : Colors.black),
            focusedBorder: setOutlineBorder(3.0,3.0),
            enabledBorder: setOutlineBorder(3.0,3.0),
          ),
        ) ,),
        SizedBox(width: 0,height: 20,),

        ElevatedButton(
            style: BaseButtonRoundedColor(40, 40, APPCOLOR),
            onPressed: () async {
              if(details.length >= 1){
                var result = await createPug(file,textTitleController.text,textDescriptionController.text,details, widget.isCrop,imageHeight);

                log(result.code.toString() +" "+result.message);
                if(result.code == SUCCESS_CODE){
                  showSnackBar(context, result.message);
                  navigateWithNamePop(context, const TabView.withIndex(initialIndex: 3).routeName);

                }
                else{
                  showSnackBar(context, "Erreur lors de la création du pug");
                }
              }
              else{
                showSnackBar(context, "Veuillez ajouter au moins une référence");

              }



            }, child: Text("Envoyer"))],

    );

  }



  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder:(context, ThemeModel notifier, child) {
      this.notifier = notifier;
      return Scaffold(
        backgroundColor: this.notifier.isDark ? Colors.black :  Color.fromRGBO(245, 245, 245, 0.95) ,
        key: _scaffoldKey,
          appBar: appBar = AppBar(
            backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
            title: Text("Edition"),),

          body:  content()

      );
    },);
  }
  Widget content(){
    return ListView(
      children: [
        imageContent(file),

        imageInformation(imageTitle),
        imageDetail(imageDescription),


      ],
    );
  }
}


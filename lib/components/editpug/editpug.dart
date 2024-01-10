import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:instagram_mention/instagram_mention.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/editpug/editpugsecond.dart';
import 'package:mypug/components/tab/tab.dart';
import 'package:mypug/features/create/api.dart';
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

  const EditPug.withFile({Key? key, required this.file, required this.isCrop})
      : super(key: key);

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
  double screenWidth = 500;
  double height = 500;
  late int imageHeight = PUGSIZE.toInt();
  ScrollController scrollController = ScrollController();

  List<PugDetailModel> details = [];
  late String pugDetailText = "";
  double x = 200.0;
  double y = 500.0;

  double pugBasicPositionX = 200.0;
  double pugBasicPositionY = 350.0;
  List<Offset> points = [];

  bool isExpanded = false;
  bool isVisible = true;
  bool isTextVisible = false;
  bool showEditor = true;
  late ThemeModel notifier;
  late SuperTooltip tooltip;
  final ValueNotifier _isLoadingNotifier = ValueNotifier(false);

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      screenWidth = getPhoneWidth(context) > MAX_SCREEN_WIDTH
          ? MAX_SCREEN_WIDTH
          : getPhoneWidth(context);
      height = getPhoneHeight(context);
      x = MediaQuery.of(context).padding.top.toInt() / 2;

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
            child: Center(
                child: Text(
              "Indiquer au moins une référécence",
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
              softWrap: true,
            ))),
      );

      getUserFirstUse().then((value) => {
            if (value.isNotEmpty && value.length < 5)
              {
                tooltip.show(context),
                saveUserFirstUse().then((value) => null),
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
          imageHeight =
              (myImage.height > PUGSIZE) ? PUGSIZE.toInt() : myImage.height;
        },
      ),
    );

    setState(() {});
    super.initState();
  }

  addNewPugDetails(double positionX, double positionY, String text) {
    if (details.length <= 5) {
      PugDetailModel model = PugDetailModel(
          positionX: positionX, positionY: positionY, text: text);
      details.add(model);
    } else {
      showSnackBar(context, "Vous avez atteint la limite de référence");
    }

    setState(() {});
  }

  Widget dataTagDetails() {
    return Stack(
        children: details
            .map((e) => Positioned(
                  left: e.positionX.toDouble() * screenWidth,
                  top: e.positionY.toDouble(),
                  child: Draggable(
                      data: badges.Badge(
                        badgeContent: Text('X'),
                        child: Center(
                            child: InstagramMention(
                                text: e.text, color: APP_COMMENT_COLOR)),
                      ),
                      onDragStarted: () {},
                      onDragUpdate: (data) {},
                      onDragEnd: (detailsDrag) {
                        log('final x :${detailsDrag.offset.dx} y :${detailsDrag.offset.dy.toInt()}');
                        e.positionX = detailsDrag.offset.dx / screenWidth;
                        e.positionY = detailsDrag.offset.dy -
                            appBar.preferredSize.height -
                            MediaQuery.of(context).padding.top +
                            scrollController.offset.toDouble();
                        setState(() {});
                      },
                      childWhenDragging: const SizedBox(
                        width: 0,
                        height: 0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          details.remove(e);
                          setState(() {});
                        },
                        child: badges.Badge(
                          badgeContent: Text('X'),
                          child: Center(
                              child: InstagramMention(
                                  text: e.text, color: APP_COMMENT_COLOR)),
                        ),
                      ),
                      feedback: draggablePugDetailItem(e.text)),
                ))
            .toList());
  }

  Widget draggablePugDetailItem(String text) {
    return InstagramMention(text: text, color: APP_COMMENT_COLOR);
  }

  Widget draggrableWidget() {
    return Image.asset(
      "asset/images/r-logo.png",
      width: 40,
      height: 40,
      color: APPCOLOR,
    );
  }

  Widget textPugEditor() {
    return Positioned(
        left: x,
        top: y ,
        child: Draggable(
            onDragStarted: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            feedback: draggrableWidget(),
            childWhenDragging: const SizedBox(
              width: 0,
              height: 0,
            ),
            onDragEnd: (details) {
              x = details.offset.dx;
              y = details.offset.dy -
                  appBar.preferredSize.height -
                  MediaQuery.of(context).padding.top +
                  scrollController.offset.toDouble();
              setState(() {});
            },
            child: textEditorWidget()));
  }

  Widget textEditorWidget() {
    return Visibility(
      visible: isVisible,
      child: Wrap(spacing: 1, direction: Axis.vertical, children: [
        Container(
            width: 140,
            height: 150,
            child: Visibility(
              visible: showEditor,
              child: TextField(
                  textInputAction: TextInputAction.newline,
                  maxLength: 25,
                  maxLines: null,
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
                        icon: Icon(Icons.check, color: APPCOLOR),
                        onPressed: () {
                          if (textEditingController.text.isNotEmpty) {
                            addNewPugDetails(
                                0.5,
                                pugBasicPositionY -
                                    appBar.preferredSize.height -
                                    MediaQuery.of(context).padding.top,
                                textEditingController.text);
                            textEditingController.clear();
                          }
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                      ))),
            ))
      ]),
    );
  }

  Widget imageContent(File image) {
    return Container(
      child: Container(
        height: PUGSIZE,
        child: Stack(
          children: [
            textPugEditor(),
            Visibility(
              visible: isVisible,
              child: dataTagDetails(),
            ),
            Positioned(
              child: ClipOval(
                child: Material(
                  color: APPCOLOR,
                  child: InkWell(
                    splashColor: Colors.red,
                    onTap: () {
                      isTextVisible = true;
                      showEditor = true;
                      x = 280.00;
                      y = 550.00;
                      setState(() {});
                    },
                    child:
                        SizedBox(width: 50, height: 50, child: Icon(Icons.add)),
                  ),
                ),
              ),
              width: 50,
              height: 50,
              left: getPhoneWidth(context) - 75,
              top: 550,
            )
          ],
        ),
      ),
      height: PUGSIZE,
      width: 100,
      decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: FileImage(image),
            fit: widget.isCrop ? BoxFit.cover : BoxFit.contain,
          )),
    );
  }

  Widget imageConfiguration() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              style: BaseButtonRoundedColor(40, 40, APPCOLOR),
              onPressed: () {
                setState(() {
                  isVisible = !isVisible;
                  log("Scroll controller : ${scrollController.offset.toString()}");
                });
              },
              child: Text('Afficher/Masquer'))
        ],
      ),
    );
  }

  Widget imageDetail() {
    return Column(
      children: [
        const SizedBox(
          width: 0,
          height: 30,
        ),
        Column(
          children: [
            Visibility(
                visible: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: APPCOLOR,
                    ),
                  ),
                )),
            ElevatedButton(
                style: BaseButtonRoundedColor(40, 40, APPCOLOR),
                // onPressed: !(_isLoading) ? functionCreate : null,
                onPressed: () {
                  navigateTo(
                      context,
                      EditPugSecond(
                        file: widget.file,
                        isCrop: widget.isCrop,
                        imageHeight: imageHeight,
                        details: details,
                      ));
                },
                child: Text("Etape suivante")),
          ],
        )
      ],
    );
  }

  void functionCreate() async {
    _isLoadingNotifier.value = true;

    if (details.length >= 1) {
      var result = await createPug(file, textTitleController.text,
          textDescriptionController.text, details, widget.isCrop, imageHeight);

      log(result.code.toString() + " " + result.message);
      if (result.code == SUCCESS_CODE) {
        showSnackBar(context, result.message);
        navigateWithNamePop(
            context, const TabView.withIndex(initialIndex: 3).routeName);
      } else {
        showSnackBar(context, "Erreur lors de la création du pug");
      }
    } else {
      showSnackBar(context, "Veuillez ajouter au moins une référence");
    }
    _isLoadingNotifier.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.notifier = notifier;
        return Scaffold(
            backgroundColor: this.notifier.isDark
                ? Colors.black
                : Color.fromRGBO(245, 245, 245, 0.95),
            key: _scaffoldKey,
            appBar: appBar = AppBar(
              backgroundColor: notifier.isDark ? Colors.black : APPCOLOR,
              title: Text("Edition"),
            ),
            body: content());
      },
    );
  }

  Widget content() {
    return ListView(
      controller: scrollController,
      children: [
        imageContent(file),
        imageConfiguration(),
        imageDetail(),
      ],
    );
  }
}

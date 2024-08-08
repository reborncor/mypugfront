import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:instagram_mention/instagram_mention.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/tab/tab.dart';
import 'package:mypug/features/create/api.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';

class EditPugSecond extends StatefulWidget {
  final routeName = '/editpugsecond';
  final File? file;
  final bool isCrop;
  final int imageHeight;
  final List<PugDetailModel>? details;

  const EditPugSecond(
      {Key? key,
      this.file,
      this.isCrop = false,
      this.imageHeight = 0,
      this.details})
      : super(key: key);

  const EditPugSecond.withData({
    Key? key,
    this.file,
    required this.isCrop,
    required this.imageHeight,
    required this.details,
  }) : super(key: key);

  @override
  EditPugSecondState createState() => EditPugSecondState();
}

class EditPugSecondState extends State<EditPugSecond> {
  late AppBar appBar;
  late File file;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textTitleController = TextEditingController();
  TextEditingController textDescriptionController = TextEditingController();
  StreamController streamController = StreamController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final dragController = DragController();
  double screenWidth = 500;
  late int imageHeight = PUGSIZE.toInt();

  List<PugDetailModel>? details = [];
  late String pugDetailText = "";
  String imageTitle = "";
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
    details == null ? null : details!.clear();
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
    details = widget.details;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = getPhoneWidth(context) > MAX_SCREEN_WIDTH
          ? MAX_SCREEN_WIDTH
          : getPhoneWidth(context);
      showSnackBar(context, "éléments enregistré !");
    });

    Future.delayed(const Duration(milliseconds: 0)).then((value) {
      setState(() {});
    });
    super.initState();
  }

  addNewPugDetails(double positionX, double positionY, String text) {
    if (details != null) {
      if (details!.length <= 5) {
        PugDetailModel model = PugDetailModel(
            positionX: positionX, positionY: positionY, text: text);
        details!.add(model);
      } else {
        showSnackBar(context, "Vous avez atteint la limite de référence");
      }
    }

    setState(() {});
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
        top: y -
            appBar.preferredSize.height -
            MediaQuery.of(context).padding.top,
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
              y = details.offset.dy;
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
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: "...",
                      hintStyle: const TextStyle(fontSize: 30),
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
    double imgHeight = (PUGSIZE) * 0.5;
    return SizedBox(
      height: imgHeight,
      child: AspectRatio(
        aspectRatio: screenWidth / (PUGSIZE + 25),
        child: Image(
          image: FileImage(image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget imageInformation(String title) {
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
              },
              child: const Text('Afficher/Masquer'))
        ],
      ),
    );
  }

  Widget imageDetail() {
    return Column(
      children: [
        const SizedBox(
          width: 0,
          height: 20,
        ),
        SizedBox(
          width: 600,
          child: TextField(
            style:
                TextStyle(color: notifier.isDark ? Colors.white : Colors.black),
            controller: textDescriptionController,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Description",
              hintStyle: TextStyle(
                  color: notifier.isDark ? Colors.white : Colors.black),
              focusedBorder: setOutlineBorder(3.0, 3.0),
              enabledBorder: setOutlineBorder(3.0, 3.0),
            ),
          ),
        ),
        const SizedBox(
          width: 0,
          height: 20,
        ),
        ValueListenableBuilder(
          valueListenable: _isLoadingNotifier,
          builder: (context, _isLoading, _) {
            return Column(
              children: [
                Visibility(
                    visible: (_isLoading as bool),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
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
                    onPressed: !(_isLoading) ? functionCreate : null,
                    child: const Text("Publier")),
              ],
            );
          },
        )
      ],
    );
  }

  void functionCreate() async {
    _isLoadingNotifier.value = true;

    if (widget.details!.isNotEmpty) {
      var result = await createPug(
          file,
          textTitleController.text,
          textDescriptionController.text,
          widget.details!,
          widget.isCrop,
          widget.imageHeight);

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
                : const Color.fromRGBO(245, 245, 245, 0.95),
            key: _scaffoldKey,
            appBar: appBar = AppBar(
              backgroundColor: Colors.black,
              title: const Text("Détail"),
            ),
            body: content());
      },
    );
  }

  Widget content() {
    return SingleChildScrollView(
      child: Column(
        children: [
          imageContent(file),
          imageDetail(),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/components/editpug/editpugsecond.dart';
import 'package:mypug/components/editpug/get_image_size_widget.dart';
import 'package:mypug/components/functions/validate_url.dart';
import 'package:mypug/components/pug/loading.dart';
import 'package:mypug/components/tab/tab.dart';
import 'package:mypug/features/create/api.dart';
import 'package:mypug/models/pugdetailmodel.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';

class EditPug extends StatefulWidget {
  final routeName = '/editpug';
  final File? file;
  final decodedImage;

  const EditPug({Key? key, this.file, this.decodedImage}) : super(key: key);

  const EditPug.withFile(
      {Key? key, required this.file, required this.decodedImage})
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final dragController = DragController();
  double screenWidth = 500;
  double height = 500;
  late int imageHeight = PUGSIZE.toInt();
  double? imageWidgetHeight, imageWidgetWidth;
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
  late var myImage;
  bool isCrop = false;
  final _imgKey = GlobalKey();
  final _dottedBoxKey = GlobalKey();
  final _refKey = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];
  num imageHeightt = 0;
  double dottedBoxHorizontalPosition = 0;
  double dottedBoxWidthInpx = 0;
  double currentRefWidth = 0;
  bool refAvailable = false;
  late Uint8List xb;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    decodedImage = widget.decodedImage;
    Image image = Image.file(file);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          myImage = image.image;
          imageHeight =
              (myImage.height > PUGSIZE) ? PUGSIZE.toInt() : myImage.height;
          imageHeightt = myImage.height;
        },
      ),
    );
    Future.delayed(const Duration(milliseconds: 0)).then((value) {
      imageWidgetHeight = imgHeight();
      imageWidgetWidth = imageWidth();
      setState(() {});
    });

    dottedBoxListener.addListener(() {
      if (dottedBoxChanged != null) {
        dottedBoxChanged!(dottedBoxListener.value);
      }
    });

    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    dottedBoxListener.removeListener(() {
      if (dottedBoxChanged != null) {
        dottedBoxChanged!(dottedBoxListener.value);
      }
    });
    super.dispose();
  }

  Future<void> getImageSize() async {
    decodedImage = await decodeImageFromList(file.readAsBytesSync());
  }

  addNewPugDetails(double positionX, double positionY, String text) {
    refAvailable = true;
    if (details.length < 5) {
      PugDetailModel model = PugDetailModel(
          positionX: positionX, positionY: positionY, text: text);
      details.add(model);
    } else {
      showSnackBar(context, "Vous avez atteint la limite de référence");
      return;
    }
    _cropDottedBoxArea();
    valueListener[details.length - 1].addListener(() {
      if (valueChanged[details.length - 1] != null) {
        valueChanged[details.length - 1]!(
            valueListener[details.length - 1].value);
      }
    });

    setState(() {});
  }

  double remap(double value, double fromLow, double fromHigh, double toLow,
      double toHigh) {
    final rangeFrom = fromHigh - fromLow;
    final rangeTo = toHigh - toLow;
    final scaled = (value - fromLow) / rangeFrom;
    return toLow + (scaled * rangeTo);
  }

  removeRef(i) {
    details.remove(details[i]);
    details.isEmpty ? refAvailable = false : null;
    setState(() {});
  }

  List<ValueChanged<List<double>>?> valueChanged = [
    null,
    null,
    null,
    null,
    null
  ];
  List<ValueNotifier<List<double>>> valueListener = [
    ValueNotifier([.49, .49]),
    ValueNotifier([.49, .49]),
    ValueNotifier([.49, .49]),
    ValueNotifier([.49, .49]),
    ValueNotifier([.49, .49])
  ];

  final ValueChanged<List<double>>? dottedBoxChanged = null;
  ValueNotifier<List<double>> dottedBoxListener = ValueNotifier([.49]);

  Widget dataTagDetails() {
    return Stack(children: [
      for (int i = 0; i < details.length; i++)
        Builder(
          builder: (context) {
            double _verticalPos, _horizontalPos;
            final handle = GestureDetector(
              onPanUpdate: (posDetails) {
                _verticalPos = (valueListener[i].value[1] +
                        posDetails.delta.dy / context.size!.height)
                    .clamp(.0, 0.99);
                _horizontalPos = (valueListener[i].value[0] +
                        posDetails.delta.dx / context.size!.width)
                    .clamp(.0, 1.0);
                valueListener[i].value = [_horizontalPos, _verticalPos];
              },
              child: RefWidget(
                key: _refKey[i],
                details: details,
                i: i,
                onTap: () => removeRef(i),
              ),
            );

            return AnimatedBuilder(
              animation: valueListener[i],
              builder: (context, child) {
                details[i].positionX = valueListener[i].value[0];
                details[i].positionY = valueListener[i].value[1];
                return Stack(children: [
                  Align(
                    alignment: Alignment(
                        (remap(valueListener[i].value[0], 0, 1, -1, 1)),
                        remap(valueListener[i].value[1], 0, 1, -1, 1)),
                    child: child,
                  ),
                ]);
              },
              child: handle,
            );
          },
        ),
    ]);
  }

  void forceRefBeingInsideImage(
      DraggableDetails detailsDrag, PugDetailModel e) {
    if (detailsDrag.offset.dx < 0 || detailsDrag.offset.dx > screenWidth - 40) {
      e.positionX = (detailsDrag.offset.dx / screenWidth)
          .clamp(0, (screenWidth - currentRefWidth - 4) / screenWidth);
    } else {
      e.positionX = detailsDrag.offset.dx / screenWidth;
    }
    if ((detailsDrag.offset.dy <
        appBar.preferredSize.height +
            MediaQuery.of(context).padding.top -
            10)) {
      e.positionY = 0;
    } else if (detailsDrag.offset.dy > maxImgHeight) {
      e.positionY = maxImgHeight - 40;
    } else {
      e.positionY = detailsDrag.offset.dy -
          appBar.preferredSize.height -
          MediaQuery.of(context).padding.top +
          scrollController.offset.toDouble();
    }
    setState(() {});
  }

  void putRefAfterLeftDottedBoxSide(PugDetailModel e) {
    e.positionX = (horizontalMargin() + 10) / screenWidth;
  }

  void putRefBeforeRightDottedBoxSide(PugDetailModel e) {
    e.positionX =
        (horizontalMargin() + dottedBoxWidth() - currentRefWidth - 10) /
            screenWidth;
  }

  void putRefUnderTopDottedBoxSide(PugDetailModel e) {
    e.positionY = (verticalMargin() + 10);
  }

  void putRefAboveBottomDottedBoxSide(PugDetailModel e) {
    e.positionY = (verticalMargin() +
        (imageWidgetHeight ?? 0) -
        MediaQuery.of(context).padding.top);
  }

  bool isRefOutSideImage(DraggableDetails detailsDrag) {
    return refOutSideImageHorizontally(detailsDrag) ||
        refOutSideImageVertically(detailsDrag);
  }

  bool refOutSideImageFromLeft(DraggableDetails detailsDrag) {
    return (detailsDrag.offset.dx < horizontalMargin() - 10);
  }

  bool refOutSideImageFromRight(DraggableDetails detailsDrag) {
    return (detailsDrag.offset.dx > horizontalMargin() + dottedBoxWidth() - 40);
  }

  bool refOutSideImageFromTop(DraggableDetails detailsDrag) {
    return (detailsDrag.offset.dy <
        verticalMargin() +
            appBar.preferredSize.height +
            MediaQuery.of(context).padding.top -
            10);
  }

  bool refOutSideImageFromBottom(DraggableDetails detailsDrag) {
    return (detailsDrag.offset.dy >
        55 + verticalMargin() + (imageWidgetHeight ?? 0));
  }

  bool refOutSideImageHorizontally(DraggableDetails detailsDrag) {
    return detailsDrag.offset.dx < horizontalMargin() - 10 ||
        detailsDrag.offset.dx > horizontalMargin() + dottedBoxWidth() - 40;
  }

  bool refOutSideImageVertically(DraggableDetails detailsDrag) {
    return detailsDrag.offset.dy.toInt() < 85 + verticalMargin() ||
        detailsDrag.offset.dy.toInt() >
            55 + verticalMargin() + (imageWidgetHeight ?? 0);
  }

  double imageWidth() {
    RenderBox box = _imgKey.currentContext!.findRenderObject() as RenderBox;
    debugPrint("imageWidth:  ${box.size.width}");
    return box.size.width;
  }

  double? imgHeight() {
    if (_imgKey.currentContext == null) {
      return null;
    }
    // double? xres;
    // try {
    RenderBox box = _imgKey.currentContext!.findRenderObject() as RenderBox;
    // xres = ;
    // } catch (e) {
    //   // return null;
    //   debugPrint("999999999999:  ${e.toString()}");
    // }
    return box.size.height;
  }

  double refWidth(int index) {
    if (_refKey[index].currentContext == null) {
      return 0;
    }
    RenderBox box =
        _refKey[index].currentContext!.findRenderObject() as RenderBox;
    return box.size.width;
  }

  double verticalMargin() => ((PUGSIZE - (imageWidgetHeight ?? 15) - 15)) / 2;

  double horizontalMargin() => (screenWidth - dottedBoxWidth()) / 2;

  double dottedBoxWidth() {
    return screenWidth <= (imageWidgetWidth ?? 10)
        ? (imageWidgetHeight ?? 15 - 15) * (screenWidth / (PUGSIZE + 15))
        : (imageWidgetWidth ?? 10) - 10;
  }

  double dottedBoxWidthRatio() => (dottedBoxWidth() / screenWidth) * 100;

  double dottedBoxHeightRatio() => (dottedBoxHeight() / PUGSIZE) * 100;

  double horizontalMarginRatio() =>
      (horizontalMargin() / (imageWidgetWidth ?? 10)) * 100;
  double drawedDottedBoxHeight() {
    RenderBox box =
        _dottedBoxKey.currentContext!.findRenderObject() as RenderBox;
    return box.size.height;
  }

  double drawedDottedBoxWidth() {
    RenderBox box =
        _dottedBoxKey.currentContext!.findRenderObject() as RenderBox;
    return box.size.width;
  }

  double dottedBoxHeight() => screenWidth <= (imageWidgetWidth ?? 500)
      ? (imageWidgetHeight ?? 10 - 10)
      : drawedDottedBoxHeight();

  double dottedBoxHeightInPx() => screenWidth <= (imageWidgetWidth ?? 10)
      ? (imageWidgetHeight ?? 10 - 10)
      : drawedDottedBoxHeight();

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
        top: y,
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
            onDragUpdate: (details) {},
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
        SizedBox(
            width: 200,
            height: 150,
            child: Visibility(
              visible: showEditor,
              child: TextField(
                  textInputAction: TextInputAction.newline,
                  // maxLength: 25,
                  maxLines: null,
                  controller: textEditingController,
                  cursorColor: APPCOLOR,
                  // textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: "https://example.com",
                      hintStyle: const TextStyle(fontSize: 13),
                      filled: true,
                      fillColor: APP_COLOR_SEARCH,
                      enabledBorder: setOutlineBorder(2.0, 5.0),
                      focusedBorder: setOutlineBorder(2.0, 5.0),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check, color: APPCOLOR),
                        onPressed: () {
                          if (!isValidUrl(textEditingController.text)) {
                            showSnackBar(context, "URL invalide");
                            return;
                          }
                          if (textEditingController.text.isNotEmpty) {
                            addNewPugDetails(
                                0.5,
                                pugBasicPositionY -
                                    appBar.preferredSize.height -
                                    MediaQuery.of(context).padding.top,
                                textEditingController.text);
                            textEditingController.clear();
                            // dottedBoxListener.dispose();
                            dottedBoxListener.removeListener(() {
                              if (dottedBoxChanged != null) {
                                dottedBoxChanged!(dottedBoxListener.value);
                              }
                            });
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
    imageWidgetHeight = imgHeight();
    // imageWidgetWidth = imageWidth();
    debugPrint("::::::::::::::::$imageWidgetHeight");
    return Stack(children: [
      SizedBox(
        height: refAvailable ? maxImgHeight : PUGSIZE,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: PUGSIZE,
            maxWidth: screenWidth,
          ),
          child: refAvailable
              ? Image(
                  key: _imgKey,
                  image: FileImage(image),
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Image(
                    key: _imgKey,
                    image: FileImage(image),
                    fit: BoxFit.contain,
                  ),
                ),
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
      SizedBox(
        height: refAvailable ? maxImgHeight : PUGSIZE,
        child: Stack(
          children: [
            Visibility(
              visible: !refAvailable,
              child: Builder(builder: (context) {
                double _horizontalPos;
                final handle = GestureDetector(
                  onPanUpdate: (posDetails) {
                    _horizontalPos = (dottedBoxListener.value[0] +
                            posDetails.delta.dx / context.size!.width)
                        .clamp(.0, 1.0);
                    dottedBoxListener.value = [_horizontalPos];
                  },
                  child: DottedBorder(
                    color: Colors.black,
                    strokeWidth: 4,
                    dashPattern: const [8, 4],
                    child: SizedBox(
                      key: _dottedBoxKey,
                      height: screenWidth <= (imageWidgetWidth ?? 10)
                          ? (imageWidgetHeight ?? 10) - 10
                          : null,
                      width: screenWidth > (imageWidgetWidth ?? 10)
                          ? (imageWidgetWidth ?? 50) - 10
                          : null,
                      child: AspectRatio(
                        aspectRatio: screenWidth / (PUGSIZE + 25),
                      ),
                    ),
                  ),
                );
                return AnimatedBuilder(
                  animation: dottedBoxListener,
                  builder: (context, child) {
                    dottedBoxHorizontalPosition =
                        dottedBoxListener.value[0] > 0.5
                            ? dottedBoxListener.value[0] + 0.02
                            : dottedBoxListener.value[0];
                    debugPrint(
                        "677777777777777777777:  $dottedBoxHorizontalPosition");
                    // details[i].positionY = valueListener[i].value[1];
                    return Stack(children: [
                      Align(
                        alignment: Alignment(
                            (remap(dottedBoxListener.value[0], 0, 1, -1, 1)),
                            0),
                        child: child,
                      ),
                    ]);
                  },
                  child: handle,
                );
              }),
            ),
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
                    child: const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
              ),
              width: 50,
              height: 50,
              left: getPhoneWidth(context) - 75,
              top: 550,
            ),
          ],
        ),
      ),
    ]);
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
                  // log("Scroll controller : ${scrollController.offset.toString()}");
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
          height: 15,
        ),
        Column(
          children: [
            refAvailable
                ? const SizedBox()
                : Container(
                    height: 40,
                    width: 265,
                    decoration: BoxDecoration(
                        color: APPCOLOR,
                        borderRadius: BorderRadius.circular(18)),
                    child: const Center(
                        child: Text(
                      "Only image in dotted box will be shown",
                      textAlign: TextAlign.center,
                    )),
                  ),
            ElevatedButton(
                style: BaseButtonRoundedColor(40, 40, APPCOLOR),
                onPressed: () {
                  navigateTo(
                      context,
                      EditPugSecond(
                        file: file,
                        isCrop: isCrop,
                        imageHeight: imageHeight,
                        details: details,
                      ));
                },
                child: const Text("Etape suivante")),
          ],
        )
      ],
    );
  }

  void functionCreate() async {
    _isLoadingNotifier.value = true;

    if (details.isNotEmpty) {
      var result = await createPug(file, textTitleController.text,
          textDescriptionController.text, details, isCrop, imageHeight);

      // log(result.code.toString() + " " + result.message);
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

  checkImageSize(double height, double width) {
    if ((width < dottedBoxWidth() - 5)) {
      showSnackBar(context, 'La taille de ton pug ne convient pas');
      return;
    }
    isCrop = true;
    file = croppedFile!;
    imageHeight = (myImage.height > PUGSIZE) ? PUGSIZE.toInt() : myImage.height;
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      imageWidgetHeight = imgHeight();
      imageWidgetWidth = imageWidth();
      setState(() {});
    });

    setState(() {});
  }

  File? croppedFile;
  var decodedImage;
  Future _cropImage() async {
    croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GetImageSize(
          croppedFile: croppedFile!,
          onDataSize: checkImageSize,
          dottedBoxHeight: dottedBoxHeight(),
        ),
      ));
    }
  }

  _cropDottedBoxArea() async {
    final LoadingOverlay _loadingOverlay = LoadingOverlay();
    late File filee;
    _loadingOverlay.show(context);
    try {
      final image = img.decodeImage(File(file.path).readAsBytesSync())!;
      debugPrint("imgHeight:  ${image.height}");
      debugPrint("imgWidth:  ${image.width}");
      debugPrint("imgHeightttt:  $imageWidgetHeight");
      double dot = dottedBoxWidth();
      double width = imageWidth();
      double dottedBoxWidthRatioo = dottedBoxWidthRatio();
      double dottedBoxHeightRatioo = dottedBoxHeightRatio();
      int dottedBoxWidthInPx = screenWidth <= (imageWidgetWidth ?? 500)
          ? (dottedBoxWidthRatioo.toInt() * image.width ~/ 100)
          : image.width;
      int dottedBoxHeightInPx = screenWidth <= (imageWidgetWidth ?? 500)
          ? image.height
          : (dottedBoxHeightRatioo.toInt() * image.height ~/ 100);
      int horizontalMarginInPx =
          (horizontalMarginRatio().toInt() * image.width ~/ 100);
      int startingCropingHorizontalPoint =
          screenWidth <= (imageWidgetWidth ?? 500)
              ? (horizontalMarginInPx *
                  2 *
                  (dottedBoxHorizontalPosition * 1000).toInt() ~/
                  1000)
              : 0;
      int startingCropingVerticalPoint =
          screenWidth <= (imageWidgetWidth ?? 500)
              ? 0
              : (image.height - dottedBoxHeightInPx) ~/ 2;

      debugPrint("ddddddddddddddddd$dot  $width $horizontalMarginInPx");
      final croppedImage = img.copyCrop(
          image,
          startingCropingHorizontalPoint,
          startingCropingVerticalPoint,
          dottedBoxWidthInPx,
          dottedBoxHeightInPx);

      // Save the thumbnail as a PNG.
      // file = await File(file.path).writeAsBytes(img.encodePng(thumbnail));
      xb = Uint8List.fromList(img.encodePng(croppedImage));
      await requestStoragePermission();
      Directory tempDir = await getTemporaryDirectory();
      filee = await File(
              '${tempDir.path}/img${DateTime.now().toIso8601String()}.png')
          .create();
      filee.writeAsBytesSync(xb);
      file = filee;
      _loadingOverlay.hide();
      setState(() {});
    } catch (e) {
      debugPrint("Cropping Failed: ${e.toString()}");
    }
    // showDialog(
    //     context: context,
    //     builder: (context) => Center(
    //           child: Container(height: 300, child: Image.file(filee)),
    //         ));
    setState(() {});
  }

  Future<void> requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      debugPrint('Storage permission granted');
      // Proceed with saving the image file
    } else if (status.isDenied) {
      debugPrint('Storage permission denied');
      // Handle the case where permission is denied
    } else if (status.isPermanentlyDenied) {
      debugPrint('Storage permission permanently denied');
      // Handle the case where permission is permanently denied (open app settings)
      await openAppSettings();
    } else {
      debugPrint('Storage permission request status: $status');
    }
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
                title: const Text("Edition"),
                actions: [
                  IconButton(
                      onPressed: () {
                        _cropImage();
                      },
                      icon: const Icon(Icons.crop)),
                  const SizedBox(
                    width: 10,
                  )
                ]),
            body: content());
      },
    );
  }

  Widget content() {
    return ListView(
      controller: scrollController,
      children: [
        imageContent(file),
        imageDetail(),
      ],
    );
  }
}

class RefWidget extends StatelessWidget {
  const RefWidget({
    super.key,
    required this.details,
    required this.i,
    required this.onTap,
  });

  final List<PugDetailModel> details;
  final int i;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              "asset/images/blur.png",
              width: 28,
              height: 28,
            ),
            // InstagramMention(text: details[i].text, color: APP_COMMENT_COLOR),
            Positioned(
                right: -10,
                top: -5,
                child: Container(
                  height: 20,
                  width: 20,
                  child: const Text(
                    'X',
                    textAlign: TextAlign.center,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20)),
                ))
          ],
        ));
  }
}

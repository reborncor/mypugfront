import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/service/themenotifier.dart';

setOutlineBorder(borderSide, borderRadius) {
  return OutlineInputBorder(
    borderSide: BorderSide(
        width: borderSide, color: Colors.indigo[300] ?? Colors.indigo),
    borderRadius: BorderRadius.circular(borderRadius),
  );
}

setUnderlineBorder(borderSide, borderRadius) {
  return UnderlineInputBorder(
    borderSide: BorderSide(
        width: borderSide, color: Colors.indigo[300] ?? Colors.indigo),
    borderRadius: BorderRadius.circular(borderRadius),
  );
}

BaseButtonRoundedColor(double width, double height, color) {
  return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(width, height)),
      backgroundColor: MaterialStateProperty.all(color),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: color))));
}

BaseButtonSize(double width, double height, color) {
  return ButtonStyle(
    minimumSize: MaterialStateProperty.all(Size(width, height)),
    backgroundColor: MaterialStateProperty.all(color),
  );
}

final APPCOLOR = Colors.indigo.shade300;
final APP_COMMENT_COLOR = Colors.black45.withOpacity(0.5);
final APP_COLOR_SEARCH = APP_COMMENT_COLOR;
const PUGSIZE = 600.0;
const MAX_SCREEN_WIDTH = 600.0;
late double maxImgHeight = 600.0;

BoxGradient() {
  return BoxDecoration(
    gradient: LinearGradient(
        colors: [APPCOLOR, Colors.blueAccent.shade700, Colors.indigo]),
  );
}

const APPCOLOR1 = Color(0xffa89efe);
const APPCOLOR2 = Color(0xff7c9afc);
const APPCOLOR3 = Color(0xff60cbf9);
const APPCOLOR4 = Color(0xffbfa4db);
const APPCOLOR5 = Color(0xffaa8be6);
const APPCOLOR6 = Color(0xffA020F0);

BoxCircular(ThemeModel notifier) {
  return BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            APPCOLOR5,
            APPCOLOR5,
            APPCOLOR4,
            APPCOLOR3,
            APPCOLOR3,
            APPCOLOR5,
            APPCOLOR5,
            APPCOLOR4
          ]),
      color:
          notifier.isDark ? Colors.black : Color.fromRGBO(245, 245, 245, 0.95),
      borderRadius: BorderRadius.circular(10));
}

errorImage() {
  return const Center(child: Icon(Icons.error));
}

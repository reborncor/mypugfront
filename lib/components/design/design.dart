import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/service/themenotifier.dart';

setOutlineBorder(borderSide, borderRadius)  {

  return OutlineInputBorder(
    borderSide: BorderSide(width: borderSide, color: Colors.indigo[300]?? Colors.indigo),
    borderRadius: BorderRadius.circular(borderRadius),
  );

}


setUnderlineBorder(borderSide, borderRadius)  {

  return UnderlineInputBorder(
    borderSide: BorderSide(width: borderSide, color: Colors.indigo[300]?? Colors.indigo),
    borderRadius: BorderRadius.circular(borderRadius),
  );

}
BaseButtonRoundedColor(double width, double height,color){
  return  ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(width,height)),

      backgroundColor: MaterialStateProperty.all(color),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: color)
          )
      ));
}

BaseButtonSize(double width, double height,color){
  return  ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(width,height)),

      backgroundColor: MaterialStateProperty.all(color),
     );
}

final APPCOLOR = Colors.indigo.shade300;
final APP_COMMENT_COLOR = Colors.black45.withOpacity(0.5);
final APP_COLOR_SEARCH = APP_COMMENT_COLOR;
final PUGSIZE = 600.0;

BoxGradient(){
  return BoxDecoration(
    gradient: LinearGradient(
        colors: [APPCOLOR, Colors.blueAccent.shade700, Colors.indigo]), );
}

// BoxCircular(ThemeModel notifier){
//   return BoxDecoration(color: notifier.isDark ? Colors.black : Color.fromRGBO(245, 245, 245, 0.95),
//       borderRadius: BorderRadius.circular(10));
// }

BoxCircular(ThemeModel notifier){
  return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [APPCOLOR,APPCOLOR, Colors.pinkAccent.shade100,APPCOLOR]),
      color: notifier.isDark ? Colors.black : Color.fromRGBO(245, 245, 245, 0.95),
      borderRadius: BorderRadius.circular(10));
}
loaderImage(){
 return Center(
      child: CircularProgressIndicator(),
    );
}

errorImage(){
  return const Center(child: Icon(Icons.error));

}


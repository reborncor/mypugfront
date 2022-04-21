import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

setOutlineBorder(borderSide, borderRadius)  {

  return OutlineInputBorder(
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

final APPCOLOR = Colors.indigo.shade300;
final PUGSIZE = 600;
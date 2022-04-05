
import 'package:flutter/material.dart';
navigateTo(context,view){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => view),
  );
}
navigateWithName(context, String name){
  Navigator.pushNamed(context, name);
}
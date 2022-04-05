
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Actuality extends StatefulWidget {

  final routeName = '/actuality';

  const Actuality({Key? key}) : super(key: key);

  @override
  ActualityState createState() => ActualityState();
}

class ActualityState extends State<Actuality> {


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.white,

        body:  const Center(child: Text('Actualité'))

    );
  }
}

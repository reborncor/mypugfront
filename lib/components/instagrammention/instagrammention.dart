import 'package:flutter/cupertino.dart';
import 'package:instagram_mention/instagram_mention.dart';

class CustomInstagramMention extends InstagramMention {
  CustomInstagramMention(this.child, {required String text})
      : super(text: text);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }
}

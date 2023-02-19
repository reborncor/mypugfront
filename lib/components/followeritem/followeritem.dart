import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/models/usersearchmodel.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../features/profile/profile.dart';
import 'api.dart';

class FollowerItem extends StatefulWidget {
  final routeName = '/pugitem';
  final UserSearchModel user;

  const FollowerItem({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  FollowerItemState createState() => FollowerItemState();
}

class FollowerItemState extends State<FollowerItem> {
  String text = "Se désabonner";
  bool follow = true;
  late ThemeModel notfier;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        notfier = notifier;
        return InkWell(
          onTap: () => navigateTo(
              context, Profile.fromUsername(username: widget.user.username)),
          child: ListTile(
              leading: widget.user.username.isEmpty
                  ? ClipRRect(
                  child: Image.network(
                    widget.user.username,
                    fit: BoxFit.contain,
                    width: 40, height: 40,
                  ),
                  borderRadius: BorderRadius.circular(100))
                  : const Image(
                      image: AssetImage("asset/images/user.png"),
                      width: 40,
                      height: 40,
                    ),
              title: Text(
                widget.user.username,
                style: TextStyle(
                    color: this.notfier.isDark ? Colors.white : Colors.black),
              ),
              trailing: OutlinedButton(
                child: Text(text, style: const TextStyle(color: Colors.white)),
                onPressed: () async {
                  final result =
                      await unFollowOrFollowUser(widget.user.username, follow);
                  if (result.code == SUCCESS_CODE) {
                    follow = !follow;
                    text = follow ? "Se désabonner" : "S'abonner";
                    setState(() {});
                  }
                },
              )),
        );
      },
    );
  }
}

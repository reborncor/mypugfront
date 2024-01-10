import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/features/profile/api.dart';
import 'package:mypug/features/userblocked/userblocked.dart';
import 'package:mypug/service/themenotifier.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../response/userresponse.dart';
import 'api.dart';

class Setting extends StatefulWidget {
  final routeName = 'setting';

  const Setting({Key? key}) : super(key: key);

  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {
  late ThemeModel notifier;

  // late Map data;

  @override
  void initState() {
    super.initState();
  }

  disconnectUser() async {
    await deleteData();
    socketService.disconnect();
    Navigator.pushReplacementNamed(context, '/signin');
  }

  Widget itemData(String data) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: APPCOLOR, width: 2)),
        child: Text(
          data,
          textAlign: TextAlign.center,
          style:
              TextStyle(color: notifier.isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  _launchURL() async {
    Uri _url = Uri.parse('https://bloden.com/cgu.php');
    if (await launchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw "Impossible d' ouvrir le lien $_url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel themeNotifier, child) {
        this.notifier = themeNotifier;
        print(themeNotifier.isDark);
        return Scaffold(
            appBar: AppBar(
              backgroundColor: themeNotifier.isDark ? Colors.black : APPCOLOR,
              actions: [
                IconButton(
                    icon: Icon(themeNotifier.isDark
                        ? Icons.nightlight_round
                        : Icons.wb_sunny),
                    onPressed: () {
                      // themeNotifier.isDark
                      //     ? themeNotifier.isDark = false
                      //     : themeNotifier.isDark = true;
                    })
              ],
            ),
            body: Container(
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Container(
                    child: Center(
                        child: FutureBuilder(
                      future: getUserInfo(),
                      builder: (context, AsyncSnapshot<UserResponse> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              renderProfilePicture(
                                  snapshot.data!.profilePicture,
                                  snapshot.data!.profilePicture.isNotEmpty,
                                  100),
                              itemData(snapshot.data!.username),
                              itemData(snapshot.data!.phoneNumber),
                              itemData(snapshot.data!.email),
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: ElevatedButton(
                                    style: BaseButtonRoundedColor(
                                        60, 40, APPCOLOR2),
                                    onPressed: () => navigateWithName(
                                        context, UsersBlockedView().routeName),
                                    child: Text("Utilisateurs bloqués")),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: _launchURL,
                                  child: Text(
                                    "conditions d'utilisation",
                                    style: TextStyle(
                                      fontSize: 16,
                                      // color: APPCOLOR,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                        style: BaseButtonRoundedColor(
                                            60, 40, APPCOLOR),
                                        onPressed: () => disconnectUser(),
                                        child: Text("Déconnexion"))),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: ElevatedButton(
                                    style: BaseButtonRoundedColor(
                                        60, 40, Colors.redAccent),
                                    onPressed: () => showDeleteDialog(
                                          snapshot.data!.profilePicture,
                                        ),
                                    child: Text("Supprimer son compte")),
                              )
                            ],
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          return  Center(
                            child: Text(sentence_no_data),
                          );
                        } else {
                          return Center(
                              child: CircularProgressIndicator(
                            color: APPCOLOR,
                          ));
                        }
                      },
                    )),
                    decoration: BoxCircular(themeNotifier)),
              ),
            ));
      },
    );
  }

  void showDeleteDialog(profilePicture) {
    showDialog(
        context: context,
        builder: (context) => Center(
                child: AlertDialog(
              title: Text("Suppression de compte"),
              content: Text(
                  "Vous êtes sur le point de supprimer votre compte êtes vous sur ?"),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: [
                ElevatedButton(
                  style: BaseButtonRoundedColor(60, 40, APPCOLOR),
                  onPressed: () async {
                    final result = await deleteAccount(profilePicture);
                    if (result.code == SUCCESS_CODE) {
                      showSnackBar(context, result.message);
                      Navigator.pop(context);
                      disconnectUser();
                    } else {
                      showSnackBar(context, result.message);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Confirmer"),
                ),
                ElevatedButton(
                    style: BaseButtonRoundedColor(60, 40, APPCOLOR),
                    onPressed: () => Navigator.pop(context),
                    child: Text(sentence_cancel))
              ],
            )));
  }
}

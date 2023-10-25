import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypug/features/actualityall/actualityall.dart';
import 'package:mypug/response/signinresponse.dart';
import 'package:mypug/service/api/signalpug.dart';
import 'package:mypug/service/api/signaluser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/design/design.dart';
import '../service/api/blockuser.dart';
import '../service/socketservice.dart';

int SUCCESS_CODE = 0;
int ERROR_CODE = 1;
int BLOCKED_CODE = 3;
int notificationNumber = 0;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

dynamic navigateTo(context, view) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => view),
  );
}

navigateToReplacement(context, view) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => view),
  );
}

navigateWithName(context, String name) {
  Navigator.pushNamed(context, name, arguments: RouteSettings(name: name));
}

navigateWithNamePop(context, String name) {
  Navigator.popAndPushNamed(context, name,
      arguments: RouteSettings(name: name));
}

navigatePopUntilName(context, String name) {
  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  Navigator.pushNamed(context, name);
}

showSnackBar(context, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        duration: const Duration(milliseconds: 1500), content: Text(message)),
  );
}

showToast(context, message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
}

Future<void> saveUserData(SignInResponse data) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  sharedPreferences.setString("token", data.token);
  sharedPreferences.setString("profilePicture", data.profilePicture);
  sharedPreferences.setString("username", data.username);
  sharedPreferences.setString("email", data.email);
  sharedPreferences.setString("phoneNumber", data.phoneNumber);
}

Future<void> saveUserProfilePicture(String profilePicture) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  sharedPreferences.setString("profilePicture", profilePicture);
}

Future<void> saveUserFirstUse() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("firstUse", "firstUse");
}

Future<String> getUserFirstUse() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Object? firstUse = sharedPreferences.get("firstUse");
  return firstUse.toString();
}

deleteData() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove("token");
  sharedPreferences.remove("username");
}

Future<String> getCurrentUserToken() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Object? token = sharedPreferences.get("token");
  return token.toString();
}

Future<dynamic> getUserData() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Object? username = sharedPreferences.get("username");
  Object? phoneNumber = sharedPreferences.get("phoneNumber");
  Object? email = sharedPreferences.get("email");
  Object? profilePicture = sharedPreferences.get("profilePicture");
  Object? id = sharedPreferences.get("id");

  return {
    "username": username.toString(),
    "phoneNumber": phoneNumber.toString(),
    "email": email.toString(),
    "profilePicture": profilePicture.toString(),
    "id": id.toString(),
  };
}

Future<String> getCurrentUsername() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Object? username = sharedPreferences.get("username");
  return username.toString();
}

getPhoneWidth(context) {
  return MediaQuery.of(context).size.width;
}

getPhoneHeight(context) {
  return MediaQuery.of(context).size.height;
}

SocketService socketService = SocketService();

void showMyDialogBlock(String username, context, VoidCallback refreshCb) {
  showDialog(
      context: context,
      builder: (context) => Center(
              child: AlertDialog(
            title: const Text("Bloquage utilisateur"),
            content: Text('Vous vous appretez à bloquer $username'),
            actions: [
              ElevatedButton(
                style: BaseButtonRoundedColor(60, 40, APPCOLOR),
                onPressed: () async {
                  final result = await blockUser(username);
                  if (result.code == SUCCESS_CODE) {
                    showSnackBar(context, result.message);
                    refreshCb();
                    navigatePopUntilName(
                        context, const ActualityAll().routeName);
                  }
                },
                child: const Text("Confirmer"),
              ),
              ElevatedButton(
                  style: BaseButtonRoundedColor(60, 40, APPCOLOR),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Annuler"))
            ],
          )));
}

showBottomSheetSignal(
    context, String username, String pugId, VoidCallback? refreshCb) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SizedBox(
          height: (pugId == "")
              ? MediaQuery.of(context).size.height * 0.20
              : MediaQuery.of(context).size.height * 0.30,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                  onTap: () =>
                      showBottomSheetSignalReason(context, username, pugId),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: const Text(
                      "Signaler l'utilisateur",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )),
              (pugId == "")
                  ? const SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : InkWell(
                      onTap: () =>
                          showBottomSheetSignalReason(context, username, pugId),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        child: const Text(
                          "Signaler la publication",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      )),
              InkWell(
                  onTap: () =>
                      showMyDialogBlock(username, context, refreshCb ?? () {}),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: const Text(
                      "Bloquer l'utilisateur",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )),
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: const Text(
                      "Fermer",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )),
            ],
          ));
    },
  );
}

showBottomSheetSignalReason(context, String username, String pugId) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.40,
          child: ListView(
            children: <Widget>[
              const SizedBox(
                height: 20,
                width: 0,
              ),
              ...getSignalReasons().map((reason) => InkWell(
                  onTap: () async {
                    var result;
                    if (pugId == "") {
                      result = await signalUser(username, reason['en']);
                    } else {
                      result = await signalPug(username, reason['en'], pugId);
                    }
                    if (result.code == SUCCESS_CODE) {
                      _showToastSignal(context);
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: Text(
                      reason['fr'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ))),
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: const Text(
                      "Fermer",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )),
            ],
          ));
    },
  );
}

List<dynamic> getSignalReasons() {
  var reasons = List<dynamic>.empty(growable: true);
  reasons.add({"en": "PORN_CONTENT", "fr": "contenu pornographique"});
  reasons.add({"en": "HARASS_CONTENT", "fr": "contenu relatif au harcelement"});
  reasons.add({"en": "ABUSED_CONTENT", "fr": "contenu abusif"});
  reasons.add({"en": "WEAPON_CONTENT", "fr": "armes"});
  reasons.add({"en": "FAKE_ACCOUNT", "fr": "faux compte"});
  return reasons;
}

_showToastSignal(context) {
  FToast fToast;
  fToast = FToast();
  // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
  fToast.init(context);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: APPCOLOR,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text("Signalement effectué"),
        SizedBox(
          width: 12.0,
        ),
        Icon(Icons.check),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.CENTER,
    toastDuration: Duration(seconds: 2),
  );

  // Custom Toast Position
  fToast.showToast(
      child: toast,
      toastDuration: Duration(seconds: 2),
      positionedToastBuilder: (context, child) {
        return Positioned(
          child: child,
          top: 16.0,
          left: 16.0,
        );
      });
}

renderProfilePicture(String path, bool exist, double size) {
  return exist
      ? ClipRRect(
          child: ExtendedImage.network(
            path,
            width: size,
            height: size,
            fit: BoxFit.cover,
            cache: true,
            cacheMaxAge: const Duration(days: 7),



          ),
          borderRadius: BorderRadius.circular(100))
      : Image(
          image: AssetImage(
            'asset/images/user.png',
          ),
          width: size,
          height: size,
        );
}

loaderCircle() {
  return Center(
    child: CircularProgressIndicator(),
  );
}

renderNoDataText() {
  return Center(
    child: Text("Aucune donnée"),
  );
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/features/competition/api.dart';
import 'package:mypug/features/search/api.dart';
import 'package:mypug/models/CompetitionModel.dart';
import 'package:mypug/response/competitionresponse.dart';
import 'package:mypug/response/userfindresponse.dart';
import 'package:provider/provider.dart';

import '../../models/pugmodel.dart';
import '../../response/userpugresponse.dart';
import '../../service/themenotifier.dart';
import '../profile/api.dart';

class CompetitionPayment extends StatefulWidget {
  final routeName = '/competitionPayment';
  final double amount;
  final CompetitionModel? competitionModel;

  const CompetitionPayment({Key? key, this.amount = 0, this.competitionModel}) : super(key: key);

  const CompetitionPayment.WithAmount({Key? key, required this.amount, this.competitionModel})
      : super(key: key);

  @override
  CompetitionPaymentState createState() => CompetitionPaymentState();
}

class CompetitionPaymentState extends State<CompetitionPayment> {
  late ThemeModel notifier;
  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late UserFindResponse _response;
  List<PugModel> selectedPugs = [];
  late final Future<UserPugResponse> pugResponse = getAllPugsFromUser();
  late final Future<CompetitionReponse> competitionResponse = findCompetiton();
  int step = 0;

  @override
  void initState() {
    super.initState();
  }

  fetchData() async {
    if (searchController.text.isNotEmpty) {
      _response = await findAllUsers(searchController.text);
      streamController.add(_response.users);
    }
  }

  Widget searchBar() {
    return TextField(
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        fetchData();
      },
      style: TextStyle(color: notifier.isDark ? Colors.white : Colors.black),
      cursorColor: APPCOLOR,
      controller: searchController,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          hintText: "Effectuer une recherche",
          hintStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: APP_COLOR_SEARCH,
          enabledBorder: setUnderlineBorder(2.0, 0.0),
          focusedBorder: setUnderlineBorder(2.0, 0.0),
          suffixIcon: IconButton(
            onPressed: () {
              fetchData();
            },
            icon: Icon(
              Icons.search,
              color: APPCOLOR,
            ),
          )),
    );
  }

  Widget PayForCompetition() {
    return Visibility(
        visible: step == 0,
        child: ListView(
          children: [
            const Text("Votre selection est prête"),
            const Text("Terminer l'incription et envoyer sur la liste"),
            OutlinedButton(
                onPressed: () {
                  makePayment(widget.amount);
                },
                child: Text("Payer ${widget.amount}€")),
          ],
        ));
  }

  Widget SelectionDone() {
    return Visibility(
        visible: step == 1,
        child: ListView(
          children: [
            const Text(
                "Ta selection est inscrite sur la liste !" "Bonne chance!"),
            const Text("Info:"
                "Si tu ne figures pas parmis les 4 pugs selectionnés vendredi, tu n'auras malheurement pas été selectionné."),
          ],
        ));
  }

  Future<void> makePayment(double amount) async {
    final result = await buyPlaceCompetition((amount * 100).toInt());
    String? stringAmount = result.toString();

    await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: result.payload["paymentIntent"],
          applePay: const PaymentSheetApplePay(merchantCountryCode: "FR",),
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: "FR",  ),

        ));
    setState(() {});
    displayPaymentStripe(result.payload["paymentIntent"]);
  }

  Future<void> displayPaymentStripe(clientSecret) async {
    try {
      // editControl
      // await Stripe.instance.createPaymentMethod(PaymentMethodParams.card());
      await Stripe.instance.presentPaymentSheet();
      setState(() {});
      await Stripe.instance
          .retrievePaymentIntent(clientSecret)
          .then((value) =>
      {
        if (value.status == PaymentIntentsStatus.Succeeded)
          {step = 1,
            setState(() {})
          }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.notifier = notifier;
        return Scaffold(
          body: Container(
              child: Stack(
                children: [
                  PayForCompetition(),
                  SelectionDone(),
                ],
              ),
              decoration: BoxCircular(notifier),
        ));
      },
    );
  }
}

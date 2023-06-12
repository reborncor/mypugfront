import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypug/components/design/design.dart';
import 'package:mypug/features/competition/api.dart';
import 'package:mypug/features/search/api.dart';
import 'package:mypug/response/competitionresponse.dart';
import 'package:mypug/response/userfindresponse.dart';
import 'package:mypug/util/util.dart';
import 'package:provider/provider.dart';

import '../../models/pugmodel.dart';
import '../../response/userpugresponse.dart';
import '../../service/themenotifier.dart';
import '../profile/api.dart';

class Competition extends StatefulWidget {
  final routeName = '/competition';

  const Competition({Key? key}) : super(key: key);

  @override
  CompetitionState createState() => CompetitionState();
}

class CompetitionState extends State<Competition> {
  late ThemeModel notifier;
  TextEditingController searchController = TextEditingController();
  StreamController streamController = StreamController();
  late UserFindResponse _response;
  int step = 0;
  List<PugModel> list = [];
  List<PugModel> selectedPugs = [];
  late final Future<UserPugResponse> pugResponse = getAllPugsFromUser();
  late final Future<CompetitionReponse> competitionResponse = findCompetiton();

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

  Widget FirstExplication() {
    return Visibility(
        visible: step == 0,
        child: ListView(
          children: [
            const Text("Inscription Ouvertes"),
            Image.asset(
              "asset/images/competition-arrow.png",
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
            OutlinedButton(
                onPressed: () {
                  setState(() {
                    step = 1;
                  });
                },
                child: Text("Je participe!")),
            const Text("Tu souhaites:\n"
                " Mettre ta marque en avant ?\n"
                " Gagner en popularité?\n"
                " Obtenir des récompenses?\n"
                " Alors n'attend plus et participe au concours du meilleur pug!"),
          ],
        ));
  }

  Widget SecondExplanation() {
    return Visibility(
        visible: step == 1,
        child: ListView(
          children: [
            const Text("Lire Attentivement"),
            const Text(
                "Les inscriptions sont ouvertes chaque lundi 12H jusqu’au vendredi 12H."
                "Pour participer c’est simple, choisis ton meilleur pug."
                "Un tirage au sort sera effectué chaque vendredi et 4 pugs (2 filles/2 garçons) seront sélectionnés à 20H."
                " L’intégralité des utilisateurs de l’application recevront unenotification des profils sélectionnés."
                " Les utilisateurs devront alors voter entre les 4 candidats dans un délai de 24H ."
                "Chaque utilisateur votera un pug de chaque team et ne pourra pas retirer ses votes une fois voté, team bleu (Garçon), team Violette (Fille)."
                "Celui et celle détenant le plus de voix à la fin du décompteGAGNE !"
                "Info : Si un cadeau est à gagner, il s’affichera sur la paged’inscription le lundi"),
            IconButton(
                onPressed: () {
                  setState(() {
                    step = 2;
                  });
                },
                icon: const Icon(
                  Icons.arrow_right_alt,
                  size: 40,
                  color: Colors.white,
                ))
          ],
        ));
  }

  Widget renderCompetition() {
    return Visibility(
        visible: step == 2,
        child: ListView(
          children: [
            const Text("Choisissez votre pug"),
            FutureBuilder(
              future: pugResponse,
              builder: (context, AsyncSnapshot<UserPugResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: APPCOLOR,
                  ));
                }
                if (snapshot.data!.code != SUCCESS_CODE) {
                  return const Center(child: Text("Aucune donnée disponible"));
                }
                list = snapshot.data!.pugs;
                return Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          bool exist = false;
                          for (var element in selectedPugs) {
                            if (element.id == list[index].id) {
                              exist = true;
                            }
                          }
                          if (exist) {
                            selectedPugs.remove(list[index]);
                          } else {
                            if (selectedPugs.length >= 3) return;
                            selectedPugs.add(list[index]);
                          }
                          setState(() {});
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: selectedPugs.contains(list[index])
                                        ? Colors.green
                                        : Colors.transparent)),
                            child: Stack(fit: StackFit.passthrough, children: [
                              ExtendedImage.network(
                                list[index].imageURL,
                                width: 150,
                                fit: BoxFit.cover,
                                cache: true,
                                retries: 3,
                                timeRetry: const Duration(milliseconds: 100),
                              ),
                              const Positioned(
                                right: 0,
                                bottom: 0,
                                child: Align(
                                    alignment: FractionalOffset.bottomRight,
                                    child: Icon(Icons.check)),
                              )
                            ])),
                      );
                    },
                  ),
                );
              },
            ),
            Text("1 pug envoyé 0.60€",
                style: TextStyle(
                    color: selectedPugs.length == 1
                        ? Colors.green
                        : Colors.white)),
            Text("2 pug envoyé 0.80€",
                style: TextStyle(
                    color: selectedPugs.length == 2
                        ? Colors.green
                        : Colors.white)),
            Text("3 pug envoyé : 1€",
                style: TextStyle(
                    color: selectedPugs.length == 3
                        ? Colors.green
                        : Colors.white)),
            Visibility(
                visible: selectedPugs.isNotEmpty,
                child: Column(
                  // physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Text("Etes vous sûr de votre selection ?"),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: selectedPugs.length,
                        itemBuilder: (context, index) {
                          return Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green)),
                              child:
                                  Stack(fit: StackFit.passthrough, children: [
                                ExtendedImage.network(
                                  selectedPugs[index].imageURL,
                                  width: 150,
                                  fit: BoxFit.cover,
                                  cache: true,
                                  retries: 3,
                                  timeRetry: const Duration(milliseconds: 100),
                                ),
                                const Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Align(
                                      alignment: FractionalOffset.bottomRight,
                                      child: Icon(Icons.check)),
                                )
                              ]));
                        },
                      ),
                    ),
                    ElevatedButton(onPressed: () {}, child: Text("Oui"))
                  ],
                )),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.arrow_right_alt,
                  size: 40,
                  color: Colors.white,
                ))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel notifier, child) {
        this.notifier = notifier;
        return Scaffold(
            body: Container(
          child: FutureBuilder(
            future: competitionResponse,
            builder: (BuildContext context,
                AsyncSnapshot<CompetitionReponse> snapshot) {
              return Stack(
                children: [
                  FirstExplication(),
                  SecondExplanation(),
                  renderCompetition()
                ],
              );
            },
          ),
          decoration: BoxCircular(notifier),
        ));
      },
    );
  }
}

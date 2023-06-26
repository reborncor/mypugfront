import 'dart:core';

import 'package:mypug/models/ParticipantModel.dart';
import 'package:mypug/models/SelectedParticipantModel.dart';

class CompetitionModel {
  late String id;
  late int startDate;
  late int endDate;
  late int endVotingDate;
  late List<ParticipantModel> participants;
  late List<SelectedParticipant> selectedParticipants;
  late String winnerMan;

  late String pugWinnerMan;
  late String winnerWoman;
  late String pugWinnerWoman;

  CompetitionModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.endVotingDate,
    required this.participants,
    required this.selectedParticipants,
    required this.winnerMan,
    required this.pugWinnerMan,
    required this.winnerWoman,
    required this.pugWinnerWoman,
  });

  CompetitionModel.noData();

  CompetitionModel.jsonData({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.endVotingDate,
    required this.participants,
    required this.selectedParticipants,
    required this.winnerMan,
    required this.pugWinnerMan,
    required this.winnerWoman,
    required this.pugWinnerWoman,
  });

  factory CompetitionModel.fromJsonData(Map<String, dynamic> json) {
    return CompetitionModel.jsonData(
      id: json['_id'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      endVotingDate: json['endVotingDate'],
      participants: (json['participants'] as List)
          .map((e) => ParticipantModel.fromJsonData(e))
          .toList(),
      selectedParticipants: (json['selectedParticipants'] as List)
          .map((e) => SelectedParticipant.fromJsonData(e))
          .toList(),
      winnerMan: json['winnerMan'] ?? "",
      winnerWoman: json['winnerWoman'] ?? "",
      pugWinnerWoman: json['pugWinnerWoman'] ?? "",
      pugWinnerMan: json['pugWinnerMan'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'endVotingDate': endVotingDate,
      'participants': participants,
      'selectedParticipants': selectedParticipants,
      'winnerMan': winnerMan,
      'winnerWoman': winnerWoman,
      'pugWinnerWoman': pugWinnerWoman,
      'pugWinnerMan': pugWinnerMan,
    };
  }

  @override
  String toString() {
    return 'CompetitionModel{id: $id, startDate: $startDate, endDate: $endDate, endVotingDate: $endVotingDate, participants: $participants, selectedParticipants: $selectedParticipants, winnerMan: $winnerMan, pugWinnerMan: $pugWinnerMan, winnerWoman: $winnerWoman, pugWinnerWoman: $pugWinnerWoman}';
  }
}

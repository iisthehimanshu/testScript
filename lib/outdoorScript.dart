import 'dart:math';

import 'package:flutter/material.dart';
import 'package:testscript/resultSheetsApi.dart';

import 'API/ladmarkApi.dart';
import 'APIMODELS/landmark.dart';

class outdoorScript extends StatefulWidget {
  String campusID;
  List<String> buildingIDS;
  outdoorScript({required this.campusID, required this.buildingIDS, super.key});

  @override
  State<outdoorScript> createState() => _outdoorScriptState();
}

class _outdoorScriptState extends State<outdoorScript> {
  land? landmarkdata ;
  land? campusData;
  int i = 0;
  List<List<dynamic>> EntriesData = [["Landmark ID"],["Name"],["Type/Sub type"],["X Coordinate"],["Y Coordinate"],["Validation Status"],["Floor Level"],["Distance in feet"]];

  @override
  void initState() {
    // TODO: implement initState
    for (var key in widget.buildingIDS) {
      landmarkApi.fetchLandmarkData(key).then((value){
        if(landmarkdata == null){
          landmarkdata = value;
          i++;
          setState(() {
          });
        }else{
          landmarkdata!.mergeLandmarks(value!.landmarks);
          i++;
          setState(() {
          });
        }
      });
    }
    landmarkApi.fetchLandmarkData(widget.campusID).then((value){
        campusData = value;
        i++;
        setState(() {
        });
    });
    super.initState();
  }
  
  void EntriesChecker()async{
    for (var landmark in landmarkdata!.landmarks!) {
      if (landmark.element!.subType == "main entry") {
        bool entryfound = false;
        for (var value in campusData!.landmarks!) {
          if (value.name == landmark.name && landmark.name != null) {
            EntriesData[0].add(landmark.sId);
            EntriesData[1].add(landmark.name);
            EntriesData[2].add(landmark.element!.subType);
            EntriesData[3].add(landmark.coordinateX);
            EntriesData[4].add(landmark.coordinateY);
            EntriesData[5].add("Entry found");
            EntriesData[6].add(landmark.floor);
            EntriesData[7].add(calculateDistanceInFeet(
                double.parse(landmark.properties!.latitude!),
                double.parse(landmark.properties!.longitude!),
                double.parse(value.properties!.latitude!),
                double.parse(value.properties!.longitude!)));
            entryfound = true;
            break;
          }
        }
        if (entryfound) {
          continue;
        }
        EntriesData[0].add(landmark.sId);
        EntriesData[1].add(landmark.name);
        EntriesData[2].add(landmark.element!.subType);
        EntriesData[3].add(landmark.coordinateX);
        EntriesData[4].add(landmark.coordinateY);
        EntriesData[5].add("No corresponding entry found in campus Data");
        EntriesData[6].add(landmark.floor);
        EntriesData[7].add("");
      }
    }
    List<List<dynamic>> transposedOutput2 = List.generate(
      EntriesData[0].length,
          (i) => List.generate(EntriesData.length, (j) => EntriesData[j][i]),
    );
    resultSheetsApi.addRowsEntriesScript(transposedOutput2);
  }

  double calculateDistanceInFeet(double lat1, double lon1, double lat2, double lon2) {
    const double radiusOfEarthInMiles = 3958.8; // Radius of Earth in miles
    const double feetPerMile = 5280; // Feet per mile

    double toRadians(double degree) => degree * pi / 180.0;

    double dLat = toRadians(lat2 - lat1);
    double dLon = toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(toRadians(lat1)) * cos(toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distanceInMiles = radiusOfEarthInMiles * c;
    double distanceInFeet = distanceInMiles * feetPerMile;

    return distanceInFeet;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: (i !=4)?CircularProgressIndicator():
        ElevatedButton(onPressed: EntriesChecker, child: Text("Run Script")),
      ),
    );
  }
}

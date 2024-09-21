import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testscript/path.dart';
import 'package:testscript/resultSheetsApi.dart';
import 'package:testscript/tools.dart';

import 'API/ladmarkApi.dart';
import 'API/waypointapi.dart';
import 'APIMODELS/Building.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/waypoint.dart';

class buildingselected extends StatefulWidget {
  buildingAll building;
  buildingselected(this.building, {super.key});

  @override
  State<buildingselected> createState() => _buildingselectedState();
}

class _buildingselectedState extends State<buildingselected> {
  List<PathModel>? waypoints ;
  land? landmarkdata ;
  int? totalLandmarkspresent;
  int? correctLandmarks;
  int? pathspossible;
  bool apiCallsComplete = false;
  @override
  void initState() {
    super.initState();
    landmarkApi.fetchLandmarkData(widget.building.sId!).then((value){
      setState(() {
        landmarkdata = value;
      });
      waypointapi.fetchwaypoint(widget.building.sId!).then((value){
        setState(() {
          waypoints = value;
        });
        Future.delayed(Duration(seconds: 2)).then((onValue){
          apiCallsComplete = true;
          //LiftChecker(landmarkdata!);
          //script(landmarkdata!, waypoints!);
        });
      });
    });
  }

  Future<void> downloadCSV(StringBuffer csvData) async {
    try {
      // Get the directory path
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/data.csv';

      // Write the string to a file
      final file = File(path);
      await file.writeAsString(csvData.toString());

      // Share the file
      await FlutterShare.shareFile(
        title: 'CSV File',
        filePath: path,
      );

      print('File saved and shared successfully: $path');
    } catch (e) {
      print('Error saving or sharing file: $e');
    }
  }

  Future<void> LiftChecker(land LandmarkData)async{
    List<List<dynamic>> sheet1 = [["Landmark ID"],["Name"]];
    for (var landmark in LandmarkData.landmarks!) {
        if(landmark.element!.type != "Floor" && landmark.element!.subType != "AR" && (landmark.lifts == null || landmark.lifts!.isEmpty)){
          sheet1[0].add(landmark.sId);
          sheet1[1].add(landmark.name);
        }
    }
    List<List<dynamic>> transposedOutput1 = List.generate(
      sheet1[0].length,
          (i) => List.generate(sheet1.length, (j) => sheet1[j][i]),
    );
    resultSheetsApi.addRowsLiftScript(transposedOutput1);
  }

  Future<void> pathScript ()async{
    for (int i = 0; i < landmarkdata!.landmarks!.length - 1; i++) {
      if ((landmarkdata!.landmarks![i].element!.subType != "Floor")) {
        int x = 0;
        for (int j = i + 1; j < landmarkdata!.landmarks!.length; j++) {
          if (landmarkdata!.landmarks![j].element!.subType != "Floor" && landmarkdata!.landmarks![j].floor == landmarkdata!.landmarks![i].floor) {

            int floor = landmarkdata!.landmarks![i].floor!;
            int sourceX = landmarkdata!.landmarks![i].doorX??landmarkdata!.landmarks![i].coordinateX!;
            int sourceY = landmarkdata!.landmarks![i].doorY??landmarkdata!.landmarks![i].coordinateY!;
            int destinationX = landmarkdata!.landmarks![j].doorX??landmarkdata!.landmarks![j].coordinateX!;
            int destinationY = landmarkdata!.landmarks![j].doorY??landmarkdata!.landmarks![j].coordinateY!;
            int numRows = floorDimenssion[floor]![1]; //floor breadth
            int numCols = floorDimenssion[floor]![0]; //floor length
            int sourceIndex = tools.calculateindex(sourceX, sourceY, numCols);
            int destinationIndex = tools.calculateindex(destinationX, destinationY, numCols);

            try{
              PathModel model = waypoints!.firstWhere((element) => (element.floor == landmarkdata!.landmarks![i].floor && element.buildingID == landmarkdata!.landmarks![i].buildingID));
              Map<String, List<dynamic>> adjList = model.pathNetwork;
              var graph = Graph(adjList);
              Map<String,dynamic> result = await graph.bfs(
                  sourceX,
                  sourceY,
                  destinationX,
                  destinationY,
                  adjList,
                  numRows,
                  numCols,
                  nonWalkable[floor]!);
              List<int>path = result["path"];
              if(path.first != sourceIndex || path.last != destinationIndex){
                print("Path Not found between ${landmarkdata!.landmarks![i].name} and ${landmarkdata!.landmarks![j].name}");
                // print("path $path \n"
                //     "${landmarkdata!.landmarks![i].name} : [$sourceX,$sourceY] \n"
                //     "${landmarkdata!.landmarks![j].name} : [$destinationX,$destinationY] \n"
                //     "cols : $numCols");
                sheet2[0].add("${landmarkdata!.landmarks![i].sId}/${landmarkdata!.landmarks![j].sId}");
                sheet2[1].add("${landmarkdata!.landmarks![i].name??landmarkdata!.landmarks![i].element!.subType}");
                sheet2[2].add("${landmarkdata!.landmarks![j].name??landmarkdata!.landmarks![j].element!.subType}");
                sheet2[3].add("${result["l1"]}");
                sheet2[4].add("${result["l2"]}");
                sheet2[5].add("${result["l3"]}");
                sheet2[7].add("${path.length}");
                sheet2[8].add("Path was not formed completely/correctly");
              }else{
                x++;
              }
            }catch(E){
              print("Error while finding path between $E  ${landmarkdata!.landmarks![i].name} and ${landmarkdata!.landmarks![j].name}");
            }
          }
        }
        if(x==0){
          sheet1[0].add(landmarkdata!.landmarks![i].sId);
          sheet1[1].add(landmarkdata!.landmarks![i].name);
          sheet1[2].add(landmarkdata!.landmarks![i].element!.subType);
          sheet1[3].add(landmarkdata!.landmarks![i].coordinateX);
          sheet1[4].add(landmarkdata!.landmarks![i].coordinateY);
          sheet1[5].add("Position is not right");
          sheet1[6].add(landmarkdata!.landmarks![i].floor);
        }
      }
    }
    List<List<dynamic>> transposedOutput1 = List.generate(
      sheet1[0].length,
          (i) => List.generate(sheet1.length, (j) => sheet1[j][i]),
    );
    resultSheetsApi.addRowsSheet1(transposedOutput1);

    List<List<dynamic>> transposedOutput2 = List.generate(
      sheet2[0].length,
          (i) => List.generate(sheet2.length, (j) => sheet2[j][i]),
    );
    resultSheetsApi.addRowsSheet2(transposedOutput2);
  }

  Map<int, List<int>> nonWalkable = {};
  Map<int, List<int>> floorDimenssion = {};
  List<List<dynamic>> sheet1 = [["Landmark ID"],["Name"],["Type/Sub type"],["X Coordinate"],["Y Coordinate"],["Validation Status"],["Floor Level"]];
  List<List<dynamic>> sheet2 = [['Path ID'],	['Source'], ['Landmark'],	['Destination'], ['Landmark'],	['Source A*'],	['Waypoint'],	['Destination A*'],	['Validation Status'],	['Distance'],	['Description']];
  List<String> toBeRemoved = [];



  Future<void> script() async {




    landmarkdata!.landmarks!.forEach((Element) {
      if (Element.element!.type == "Floor") {
        List<int> allIntegers = [];
        String jointnonwalkable =
        Element.properties!.nonWalkableGrids!.join(',');
        RegExp regExp = RegExp(r'\d+');
        Iterable<Match> matches = regExp.allMatches(jointnonwalkable);
        for (Match match in matches) {
          String matched = match.group(0)!;
          allIntegers.add(int.parse(matched));
        }
        nonWalkable[Element.floor!] = allIntegers;
        floorDimenssion[Element.floor!] = [
          Element.properties!.floorLength!,
          Element.properties!.floorBreadth!
        ];
      }
    });

    int totalLandmarks = 0;
    Map<int,int> totalcorrectLandmarks = {};
    landmarkdata!.landmarks!.forEach((Element){
      totalLandmarks++;
      if((Element.element!.subType != "Floor")){
        if(Element.coordinateX == null || Element.coordinateY == null){
          sheet1[0].add(Element.sId);
          sheet1[1].add(Element.name);
          sheet1[2].add(Element.element!.subType);
          sheet1[3].add(Element.coordinateX);
          sheet1[4].add(Element.coordinateY);
          sheet1[5].add("Coordinates are null");
          sheet1[6].add(Element.floor);
          toBeRemoved.add(Element.sId!);
        }else if((Element.doorX??Element.coordinateX!) > floorDimenssion[Element.floor]![0] || (Element.doorY??Element.coordinateY!) > floorDimenssion[Element.floor]![1]){
          sheet1[0].add(Element.sId);
          sheet1[1].add(Element.name);
          sheet1[2].add(Element.element!.subType);
          sheet1[3].add(Element.coordinateX);
          sheet1[4].add(Element.coordinateY);
          sheet1[5].add("Out of Building");
          sheet1[6].add(Element.floor);
          toBeRemoved.add(Element.sId!);
        }else if(Element.element!.subType == null && (Element.name == null || Element.name!.toLowerCase() == "undefined")){
          sheet1[0].add(Element.sId);
          sheet1[1].add(Element.name);
          sheet1[2].add(Element.element!.subType);
          sheet1[3].add(Element.coordinateX);
          sheet1[4].add(Element.coordinateY);
          sheet1[5].add("Name and Subtype both are null");
          sheet1[6].add(Element.floor);
        }else if(Element.element!.type == "Rooms" && Element.element!.subType == "room door" && (Element.properties!.polyId == null || Element.properties!.polyId == "" || Element.properties!.polyId == Element.sId)){
          sheet1[0].add(Element.sId);
          sheet1[1].add(Element.name);
          sheet1[2].add(Element.element!.subType);
          sheet1[3].add(Element.coordinateX);
          sheet1[4].add(Element.coordinateY);
          sheet1[5].add("Polygon association is not there");
          sheet1[6].add(Element.floor);
        }else{
          totalcorrectLandmarks.putIfAbsent(Element.floor!, (){return 1;});
          totalcorrectLandmarks[Element.floor!] = totalcorrectLandmarks[Element.floor!]! + 1;
        }
      }
    });

    setState(() {
      totalLandmarkspresent = totalLandmarks;
    });

    toBeRemoved.forEach((Element) {
      landmarkdata!.landmarks!.removeWhere((element) => element.sId == Element);
    });

    setState(() {
      correctLandmarks = totalLandmarks - toBeRemoved.length;
    });

    int totalPath = 0;
    totalcorrectLandmarks.forEach((key,value){
      totalPath = totalPath + tools.sumUsingLoop(value);
    });

    setState(() {
      pathspossible = totalPath;
    });

    List<List<dynamic>> transposedOutput1 = List.generate(
      sheet1[0].length,
          (i) => List.generate(sheet1.length, (j) => sheet1[j][i]),
    );
    resultSheetsApi.addRowsSheet1(transposedOutput1);

    List<List<dynamic>> transposedOutput2 = List.generate(
      sheet2[0].length,
          (i) => List.generate(sheet2.length, (j) => sheet2[j][i]),
    );
    resultSheetsApi.addRowsSheet2(transposedOutput2);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(32, 56, 32, 56),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Landmark Data"),
                landmarkdata == null?CircularProgressIndicator():Icon(Icons.check)
              ],
            ),
            SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Waypoint Data"),
                waypoints == null?CircularProgressIndicator():Icon(Icons.check)
              ],
            ),
            SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: (){if(apiCallsComplete){
                  LiftChecker(landmarkdata!);
                }
                    }, child: Text("liftSript")),
                SizedBox(width: 24,),

                ElevatedButton(onPressed: (){if(apiCallsComplete){
                  script();
                }
                }, child: Text("landmark checker")),
                SizedBox(width: 24,),

                ElevatedButton(onPressed: (){if(apiCallsComplete){
                  pathScript();
                }
                }, child: Text("path script")),

              ],
            ),
            SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Landmarks found"),
                totalLandmarkspresent == null?CircularProgressIndicator():Text("$totalLandmarkspresent")
              ],
            ),
            SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Correct Landmarks"),
                correctLandmarks == null?CircularProgressIndicator():Text("$correctLandmarks")
              ],
            ),
            SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Paths possible"),
                pathspossible == null?CircularProgressIndicator():Text("$pathspossible")
              ],
            )
          ],
        ),
      ),
    );
  }
}

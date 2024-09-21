import 'dart:io';

import 'package:flutter/material.dart';
import 'package:testscript/API/buildings.dart';
import 'package:testscript/API/ladmarkApi.dart';
import 'package:testscript/API/waypointapi.dart';
import 'package:testscript/buildingselected.dart';
import 'package:testscript/outdoorScript.dart';
import 'package:testscript/path.dart';
import 'package:testscript/resultSheetsApi.dart';
import 'package:testscript/tools.dart';

import 'API/outdoorapi.dart';
import 'APIMODELS/Building.dart';
import 'APIMODELS/landmark.dart';
import 'APIMODELS/waypoint.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await resultSheetsApi.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Test Script'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<buildingAll>? allbuildings ;
  List<Widget> buildingButtons = [];
  List<PathModel>? waypoints ;
  land? landmarkdata ;

  @override
  void initState() {
    super.initState();
    buildingapi().fetchbuildings().then((value){
      allbuildings = value;
      setState(() {
        if(value != null){
          for(var b in value){
            buildingButtons.add(ElevatedButton(onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          buildingselected(b)));
            }, child: Text("${b.buildingName}")));
          }
        }
      });
    });

    outBuilding.outbuilding(["66b5adabb6d75023d8830957","66b5ae7cb6d75023d884233e","65d8835adb333f89456e687f"]).then((value){
      setState(() {
        buildingButtons.add(ElevatedButton(onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      outdoorScript(campusID: value!.data!.campusId!, buildingIDS: ["66b5adabb6d75023d8830957","66b5ae7cb6d75023d884233e","65d8835adb333f89456e687f"],)));
        }, child: Text("Entries for Ashoka")));
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: buildingButtons,
          ),
        )
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

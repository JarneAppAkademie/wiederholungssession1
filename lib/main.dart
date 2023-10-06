import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:http/http.dart' as http;
import 'package:wiederholungssession1/User.dart';

void main() async {
  await Hive.initFlutter();

  var box = await Hive.openBox("testBox");
  //registriert User in Hive um diese zu nutzen
  Hive.registerAdapter(UserAdapter());
  // erstellt eine box die listen speichern kann. Durch den generierten Adapter(User.g.dart) können wir auch User darin speichern
  await Hive.openBox<List>("userListBox2");

  //box.put("name","Test");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureTest(),
    );
  }
}

class FutureTest extends StatefulWidget {
  const FutureTest({super.key});

  @override
  State<FutureTest> createState() => _FutureTestState();
}

class _FutureTestState extends State<FutureTest> {
  @override
  void initState() {
    super.initState();
  }
  /*
    Macht die httpRequest an die Api und wandelt den json ( Liste aus maps, welche den User repräsentieren)
    in eine Liste aus Userobjekten zurück, die dann returned wird

  */
  Future<List<User>> makeHttpRequestUser() async {
    //erstellt eine Adresse an die unsere Anfrage gehen soll
    Uri adress = Uri.https("jsonplaceholder.typicode.com", "users");
    // macht eine http request an die Adresse und speichert die Antwort(Response)
    http.Response serverResponse = await http.get(adress);
    // Macht aus der Antwort(Textform json) eine Liste aus Maps(json)
    var jsonResponse = jsonDecode(serverResponse.body);
    
    // user List um anstatt einer mapfunktion eine forschleife zu benutzen
    List<User> userList = [];
    
    // unterscheidung zwischen api list antwort oder einzeldes jsonobjekt
    if (jsonResponse.runtimeType == List) {
      /* 
      andere schreibweise der mapfunktion: guckt sich alle maps(json objekte) an und wandelt sie
      mit der user.fromJson funktion in einen user um, der dann in der userListe gespeichert wird

      */
      for (var i in jsonResponse) {
        User user = User.fromJson(i);
        userList.add(user);
      }
      

      // speichert die liste in unsrer Box
      Hive.box<List>("userListBox2").put("userList", userList);

      return userList;

    } else {
      return [User.fromJson(jsonResponse)];
    }
  }

  /*
    Entscheidet je nachdem ob wir schon User in unser box gespeichert haben 
    welches Widget angezeigt werden soll. Also entweder den Future Builder, der eine
    httpRequest nach den Usern macht, wenn noch keine Lokal gespeichert sind

    sonst wird auf die userliste der hive box zugegriffen

  */
  Widget showHiveOrHttp() {
    Box<List> box = Hive.box<List>("userListBox2");
    if (box.isEmpty) {
      print("make http request");
      return FutureBuilder(
          // unsere request an den server auf die wir ja warten müssen
          future: makeHttpRequestUser(),
          builder: (context, snapshot) {
            // snapshot.hasData überprüft ob unsere funktion schon fertig ist
            if (snapshot.hasData) {
              // wenn ja rufe die return daten(mit snapshot.data) ab und überprüfe ob null
              List<User> notNullUserList = snapshot.data ?? [];

              //wieder eine Liste mit widgets für andere schreibweise der maping funktion
              List<Widget> widgetList = [];

              /*
              andere schreibweise der maping funktion die sich jeden user(aus unsrer Liste) anguckt und
              
              ein Widget zur widgetliste hinzufügt, welches infos aus den usern anzeigt(oragene container mit Daten)

              */
              for (User user in notNullUserList) {
                widgetList.add(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 200,
                    height: 80,
                    color: Colors.amber,
                    child: Column(
                      children: [
                        Text(user.name),
                        Text(user.email),
                        //Text(Hive.box("testBox").get("name"))
                      ],
                    ),
                  ),
                ));
              }
              // unser widgetliste wird angezeigt
              return Expanded(
                child: ListView(
                  children: widgetList,
                ),
              );
            } else {
              //wird angezeigt falls noch keine daten verfügbar sind
              return CircularProgressIndicator();
            }
          });
    } else {
       print("get data from hive");
      List<Widget> widgetList = [];
      // wir holen und die daten unsrer hive box
      List<User> notNullUserList =
          box.get("userList")?.map((e) => e as User).toList() ?? [];
      print(notNullUserList);
      // das gleiche mapping wie oben im futurebuilder
      for (User user in notNullUserList) {
        widgetList.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 200,
            height: 80,
            color: Colors.amber,
            child: Column(
              children: [
                Text(user.name),
                Text(user.email),
                //Text(Hive.box("testBox").get("name"))
              ],
            ),
          ),
        ));
      }
      return Expanded(
        child: ListView(children: widgetList),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Futuretest"),
      ),
      body: Column(
        children: [showHiveOrHttp()],
      ),
    );
  }
}

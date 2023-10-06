import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:http/http.dart' as http;
import 'package:wiederholungssession1/User.dart';

void main() async {
  await Hive.initFlutter();

  var box = await Hive.openBox("testBox");
  Hive.registerAdapter(UserAdapter());
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

  Future<List<User>> makeHttpRequestUser() async {
    Uri adress = Uri.https("jsonplaceholder.typicode.com", "users");
    http.Response serverResponse = await http.get(adress);

    var jsonResponse = jsonDecode(serverResponse.body);
    print(jsonResponse.runtimeType == List);
    List<User> userList = [];
    print(jsonResponse);
    if (jsonResponse.runtimeType == List) {
      for (var i in jsonResponse) {
        User user = User.fromJson(i);
        userList.add(user);
      }
      print(userList);
      Hive.box<List>("userListBox2").put("userList", userList);
      return userList;
    } else {
      return [User.fromJson(jsonResponse)];
    }
  }

  Widget showHiveOrHttp() {
    Box<List> box = Hive.box<List>("userListBox2");
    if (box.isEmpty) {
      return FutureBuilder(
          future: makeHttpRequestUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<User> notNullUserList = snapshot.data ?? [];

              List<Widget> widgetList = [];
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
                child: ListView(
                  children: widgetList,
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          });
    } else {
      List<Widget> widgetList = [];
      
      List<User> notNullUserList = box.get("userList")?.map((e) => e as User).toList() ?? [];
      print(notNullUserList);
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

import 'package:hive/hive.dart';

part 'User.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  String name;
  @HiveField(1)
  String email;
  @HiveField(2)
  int id;
  @HiveField(3)
  String city;
  @HiveField(4)
  String city2;


  User({required this.name, required this.email, required this.id, required this.city,required this.city2});





  /*
    Macht aus einer Map(unserem Json Objekt eines Users) ein Userobjekt
  */
  factory User.fromJson(Map<String, dynamic> json) {
    return User(email: json["email"], name: json["name"], id: json["id"], city: json["address"]["city"],city2: json["address"]["city"]);
  }
}

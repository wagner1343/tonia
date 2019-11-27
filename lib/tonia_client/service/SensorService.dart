

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tonia_client/tonia_client/core/sensors.dart';

class SensorService {
  static SensorService _instance;

  static SensorService get instance {
    if(_instance == null)
      _instance = SensorService._();
    return _instance;
  }
  Firestore firestore = Firestore.instance;
  FirebaseUser user;

  SensorService._(){
    FirebaseAuth.instance.onAuthStateChanged.listen((u) => user = u);
  }

  List<SensorAction> searchActions(String query, List<Sensor> sensors){

    List<SensorAction> result = <SensorAction>[];

    try {
      List<String> subActions = query.toLowerCase().split(" ");
      for (String sub in subActions) {
        for (Sensor s in sensors) {
          for (String option in s.actions.keys) {
            int matches = sub
                .allMatches(option)
                .length;
            matches += sub.allMatches(s.name).length;
            result.add(SensorAction(s, option, s.actions[option], matches: matches));
          }
        }
      }
      result.removeWhere((a) => a.matches <= 0);

      result.sort((a, b) => a.matches - b.matches);
    }
    catch(e, s){
      print(e);
      print(s);
    }
    return result;
  }

  Future<bool> addSensor(String sensorId) async{
    if((await firestore.collection("sensors").document(sensorId)) == null)
      return false;

    DocumentReference doc = firestore.collection("users").document(user.uid);
    List<dynamic> sensors = (await doc.get()).data["sensors"];
    sensors = sensors.toList();
    sensors.add(sensorId);

    try {
      await doc.updateData({"sensors": sensors});
    }
    catch(e, s){
      print(e);
      print(s);
      return false;
    }
    return true;
  }

  Future<List<Sensor>> listSensors() async{
    user = await FirebaseAuth.instance.currentUser();
    List<Future<Sensor>> sensorsFutures = <Future<Sensor>>[];
    List<Sensor> sensors = <Sensor>[];
    try {
      DocumentSnapshot docSnap = await firestore.collection("users").document(
          user.uid).get();
      Map<String, dynamic> data = docSnap.data;
      for (String sensorId in data["sensors"] as List<dynamic>) {
        sensorsFutures.add(getSensor(sensorId));
      }

      for (Future<Sensor> f in sensorsFutures) {
        sensors.add(await f);
      }
    }
    catch(e, s){
      print(e);
      print(s);
    }
    return sensors;
  }

  Future<Sensor> getSensor(String sensorId) async{
    DocumentReference ref = firestore.collection("sensors").document(sensorId);
    return parseSensorData((await ref.get()).data)..doc = ref;
  }

  Sensor parseSensorData(Map<String, dynamic> data){
    switch(data["type"]){
      case "AirTemperature":
        return parseTemperatureSensorData(data);
        break;
      case "Gate":
        return parseGateSensorData(data);
        break;
      case "Light":
        return parseLightSensorData(data);
        break;
    }
  }

  AirTemperatureSensor parseTemperatureSensorData(Map<String, dynamic> data){
    return AirTemperatureSensor(
      data["name"],
      temperature: data["temperature"],
      isOn: data["isOn"] == "true"
    );
  }

  bool isTrue(dynamic data){
    return data.toString().contains("true");
  }

  GateSensor parseGateSensorData(Map<String, dynamic> data){
    return GateSensor(
      data["name"],
      isLocked: isTrue(data["isLocked"]),
      isOpen: isTrue(data["isOpen"])
    );
  }

  LightSensor parseLightSensorData(Map<String, dynamic> data){
    return LightSensor(
      data["name"],
      isOn: data["isOn"] == "true"
    );
  }
}
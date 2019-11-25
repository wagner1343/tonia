

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
    return parseSensorData((await firestore.collection("sensors").document(sensorId).get()).data);
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
      temperature: int.parse(data["temperature"]),
      isOn: data["isOn"] == "true"
    );
  }

  GateSensor parseGateSensorData(Map<String, dynamic> data){
    return GateSensor(
      data["name"],
      isLocked: data["isLocked"] == "true",
      isOpen: data["isOpen"] == "true"
    );
  }

  LightSensor parseLightSensorData(Map<String, dynamic> data){
    return LightSensor(
      data["name"],
      isOn: data["isOn"] == "true"
    );
  }
}
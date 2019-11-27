import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Sensor {
  String get name;
  String get defaultName;
  DocumentReference doc;
  Future<void> setName(String name) async{
    await doc.updateData({"name": name});
  }

  Map<String, Function> get actions;
}

class SensorAction{
  String name;
  Sensor sensor;
  SensorAction(this.sensor, this.name, this.function,{this.matches});
  int matches;

  Future <void> Function() function;
}

class GateSensor extends Sensor {
  bool isOpen;

  GateSensor(this._name, {this.isOpen, this.isLocked, });

  bool isLocked;

  Future<void> setOpen(bool isOpen) async{
    await doc.updateData({"isOpen": isOpen.toString()});
  }
  Future<void> setLocked(bool isLocked) async{
    await doc.updateData({"isLocked": isLocked.toString()});
  }

  String _name;

  @override
  String get name => _name ;

  @override
  String get defaultName => "portão porta";

  @override
  Map<String, Future<void> Function()> get actions => {
    "abrir": () => setOpen(true),
    "abra": () => setOpen(true),
    "feche": () => setOpen(false),
    "fechar": () => setOpen(false),
    "trancar": () => setLocked(true),
    "tranque": () => setLocked(true),
    "destrancar": () => setLocked(false),
    "destranque": () => setLocked(false),
  };

}

class LightSensor extends Sensor {
  bool isOn;

  LightSensor(this._name, {this.isOn, });

  Future<void> setOn(bool isOn) async{
    print("ligando/desligando");
    await doc.updateData({"isOn": isOn.toString()});
  }

  @override
  String get defaultName => "luz luzes";

  String _name;
  @override
  String get name => _name;

  @override
  Map<String, Future<void> Function()> get actions => {
    "ligar": () => setOn(true),
    "desligar": () => setOn(false),
  };
}

class AirTemperatureSensor extends Sensor {
  int temperature;

  AirTemperatureSensor(this._name, {this.temperature, this.isOn, });

  bool isOn;

  Future<void> setTemperature(int temperature) async{
    await doc.updateData({"temperature": temperature});
  }

  Future<void> setOn(bool isOn) async{
    await doc.updateData({"isOn": isOn.toString()});
  }

  @override
  Map<String, Future<void> Function()> get actions => {
    "ligar": () => setOn(true),
    "desligar": () => setOn(false),
    "aumentar temperatura": () => setTemperature(temperature + 5),
    "diminuir temperatura": () => setTemperature(temperature - 5),
  };

  @override
  String get defaultName => "ar condicionado";

  String _name;
  @override
  String get name => _name;

}
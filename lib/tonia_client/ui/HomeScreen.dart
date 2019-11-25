import 'package:flutter/material.dart';
import 'package:tonia_client/tonia_client/core/sensors.dart';
import 'package:tonia_client/tonia_client/service/AuthService.dart';
import 'package:tonia_client/tonia_client/service/SensorService.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SensorService sensorService = SensorService.instance;
  AuthService authService = AuthService.instance;
  List<Sensor> sensors = [
    GateSensor(
      "Portão"
    ),
    AirTemperatureSensor(
      "ar"
    ),
    LightSensor(
      "luz da sala"
    )
  ];
  Future sensorsLoading;

  @override
  initState(){
    super.initState();
  }
  Widget _buildSensorCard(BuildContext ctx, int i) {
    Sensor s = sensors[i];
    if(s is LightSensor)
      return _buildLightSensorCard(s);
    if(s is AirTemperatureSensor)
      return _buildAirTemperatureSensorCard(s);
    if(s is GateSensor)
      return _buildGateSensorCard(s);
    return Container(child: Text(sensors[i].name, style: TextStyle(color: Colors.black),),);
  }

  void logoutOnPressed() async{
    await authService.logout();
    Navigator.pushReplacementNamed(context, "/");
  }
  Widget _buildGateSensorCard(GateSensor s) {
    return Container(

    )
  }
  Widget _buildLightSensorCard(LightSensor s) {}
  Widget _buildAirTemperatureSensorCard(AirTemperatureSensor S) {}
  Widget _buildSensorList(){
    return ListView.builder(
        shrinkWrap: true,
        itemCount: sensors.length,
        itemBuilder: _buildSensorCard);
  }
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _buildSensorList(),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(icon: Icon(Icons.exit_to_app, color: theme.primaryColor,), onPressed: logoutOnPressed,),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor,
              boxShadow: [BoxShadow(color: Colors.black26, spreadRadius: 12, blurRadius: 12)]
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide(width: 0), borderRadius: BorderRadius.all(Radius.circular(64))),
                      suffixIcon: IconButton(icon: Icon(Icons.mic), onPressed: null,)
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.only(bottom: 82),
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){},
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:slide_button/slide_button.dart';
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
    Widget controls;
    if(s is LightSensor)
      controls = _buildLightSensorCard(s);
    if(s is AirTemperatureSensor)
      controls = _buildAirTemperatureSensorCard(s);
    if(s is GateSensor)
      controls = _buildGateSensorCard(s);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 0)],
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Text(s.name, style: TextStyle(fontSize: 24),),
          ),

          controls

        ],
      ),
    );;
  }

  void logoutOnPressed() async{
    await authService.logout();
    Navigator.pushReplacementNamed(context, "/");
  }
  Widget _buildGateSensorCard(GateSensor s) {
    return Container(
      child: SlideButton(
        backgroundColor: Colors.red,
        slidingBarColor: Colors.lightGreen,
      ),
    );
  }
  Widget _buildLightSensorCard(LightSensor s) {
    return Container(

  );}
  Widget _buildAirTemperatureSensorCard(AirTemperatureSensor S) {
    return Container(

  );}
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
      backgroundColor: Color(0xFFfbfbfb),
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

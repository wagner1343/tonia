import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
  List<Sensor> sensors = [];
  TextEditingController sensorIdController = TextEditingController();
  TextEditingController actionController = TextEditingController();

  void addSensorOnPressed(BuildContext c) {
    showDialog<bool>(
        context: c,
        child: Container(
            child: SimpleDialog(
                contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                children: <Widget>[
          Container(
            child: Text("Adicionar sensor"),
          ),
          Container(
            child: TextField(
              controller: sensorIdController,
              decoration: InputDecoration(hintText: "Código do sensor"),
            ),
          ),
          Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(top: 6),
              child: RaisedButton(
                child: Text("Adicionar"),
                onPressed: () {
                  Navigator.pop(c);
                    sensorService.addSensor(sensorIdController.text).then(
                  (v) {
                    if (!v) {
                      SnackBar snack = SnackBar(
                        content: Text("Código de sensor inválido"),
                      );
                      Scaffold.of(c).showSnackBar(snack);
                    }
                  },
                );},
              ))
        ])));
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
                  child: FlatButton.icon(
                    label: Text("Sair"),
                    icon: Icon(
                      Icons.exit_to_app,
                      color: theme.primaryColor,
                    ),
                    onPressed: logoutOnPressed,
                  ),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: theme.primaryColor, boxShadow: [
              BoxShadow(color: Colors.black26, spreadRadius: 12, blurRadius: 12)
            ]),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TypeAheadField<SensorAction>(
                    hideOnEmpty: true,

                    direction: AxisDirection.up,
                    suggestionsCallback: (s){return sensorService.searchActions(s, sensors);},
                    itemBuilder: (c, s) => ListTile(title: Text( s.sensor.name), subtitle: Text(s.name),),
                    onSuggestionSelected: (s){actionController.text = s.name; s.function().then((s) => setState((){}));},
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: actionController,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderSide: BorderSide(width: 0),
                                borderRadius:
                                BorderRadius.all(Radius.circular(64))),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.mic),
                              onPressed: null,
                            ))
                    )
                    ,
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
          onPressed: () => addSensorOnPressed(context),
        ),
      ),
    );
  }

  @override
  initState() {
    super.initState();
    sensorService.listSensors().then((s) => setState(() => sensors = s));
    Firestore.instance.collection("sensors").snapshots().listen((snap) =>
        sensorService.listSensors().then((s) => setState(() => sensors = s)));

    authService.auth.currentUser().then((u) => Firestore.instance.collection("users").document(u.uid).snapshots().listen((snap) =>
        sensorService.listSensors().then((s) => setState(() => sensors = s))));
  }

  void logoutOnPressed() async {
    await authService.logout();
    Navigator.pushReplacementNamed(context, "/");
  }

  Widget _buildAirTemperatureSensorCard(AirTemperatureSensor s) {
    return Container(
        child: Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Temperatura:"),
              Expanded(
                child: Container(),
              ),
              IconButton(
                icon: Icon(
                  Icons.remove,
                  color: Colors.black87,
                ),
                onPressed: () => s.setTemperature(s.temperature - 1),
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(s.temperature.toString())),
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.black87,
                ),
                onPressed: () => s.setTemperature(s.temperature + 1),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: RaisedButton(
            onPressed: () => s.setOn(!s.isOn),
            child: Text(s.isOn ? "Desligar" : "Ligar"),
          ),
        ),
      ],
    ));
  }

  Widget _buildGateSensorCard(GateSensor s) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Trancar:"),
                Switch(
                  value: s.isLocked,
                  onChanged: (l) => s.setLocked(l),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: RaisedButton(
              onPressed: () => s.setOpen(!s.isOpen),
              child: Text(s.isOpen ? "Fechar" : "Abrir"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightSensorCard(LightSensor s) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: RaisedButton(
          onPressed: () => s.setOn(!s.isOn),
          child: Text(s.isOn ? "Desligar" : "Ligar"),
        ));
  }

  Widget _buildSensorCard(BuildContext ctx, int i) {
    Sensor s = sensors[i];
    Widget controls;
    if (s is LightSensor) controls = _buildLightSensorCard(s);
    if (s is AirTemperatureSensor) controls = _buildAirTemperatureSensorCard(s);
    if (s is GateSensor) controls = _buildGateSensorCard(s);
    return Container(
      margin: EdgeInsets.only(
          left: 12, right: 12, top: i == 0 ? 64 : 12, bottom: i == sensors.length -1 ? 102 : 12),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 0)
          ],
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(right: 24, left: 24, top: 24, bottom: 0),
            child: Text(
              s.name,
              style: TextStyle(fontSize: 24),
            ),
          ),
          controls
        ],
      ),
    );
    ;
  }

  Widget _buildSensorList() {
    return RefreshIndicator(
      onRefresh: () =>
          sensorService.listSensors().then((s) => setState(() => sensors = s)),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: sensors.length,
          itemBuilder: _buildSensorCard),
    );
  }
}

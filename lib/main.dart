import 'dart:convert';

import 'package:hsmob/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:hsmob/cp1251.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/models.dart';

late UserData user;
late List<PlanData> plans;
late DateTime _time = DateTime.now();
late Position _position;
late PlanData oneplan;
var api = new ApiService();

void main() => runApp(new MaterialApp(
      home: new MyApp(),
    ));

class MyApp extends StatelessWidget {
  late String _email;
  late String _password;
  final _sizeTextBlack = const TextStyle(fontSize: 20.0, color: Colors.black);
  final _sizeTextWhite = const TextStyle(fontSize: 20.0, color: Colors.white);
  final formKey = new GlobalKey<FormState>();
  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return new MaterialApp(
      home: new Scaffold(
        body: new Center(
          child: new Form(
              key: formKey,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    child: new TextFormField(
                      decoration: new InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 1,
                      style: _sizeTextBlack,
                      onSaved: (val) => _email = val!,
                      validator: (val) =>
                          !val!.contains("@") ? 'Not a valid email.' : null,
                    ),
                    width: 400.0,
                  ),
                  new Container(
                    child: new TextFormField(
                      decoration: new InputDecoration(labelText: "Password"),
                      obscureText: true,
                      maxLines: 1,
                      validator: (val) =>
                          val!.length < 1 ? 'Password too short.' : null,
                      onSaved: (val) => _password = val!,
                      style: _sizeTextBlack,
                    ),
                    width: 400.0,
                    padding: new EdgeInsets.only(top: 10.0),
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(top: 25.0),
                    child: new MaterialButton(
                      onPressed: submit,
                      color: Theme.of(context).accentColor,
                      height: 50.0,
                      minWidth: 150.0,
                      child: new Text(
                        "LOGIN",
                        style: _sizeTextWhite,
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  Future<void> submit() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      user = await api.login(_email, _password);
      plans = await api.getListOfPlans(user.id);
      performLogin();
    }
  }

  void performLogin() {
    hideKeyboard();
    Navigator.push(
        _context, MaterialPageRoute(builder: (context) => SecondScreen()));
  }

  void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}

class SecondScreen extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Gazon homeservice',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController editingController = TextEditingController();
  late BuildContext _context;

  @override
  void initState() {
    super.initState();

    updateLocation();

    StreamSubscription positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _position = position;
        _time = DateTime.now();
        var coord = new Coordinate();
        coord.date = _time;
        coord.empid = user.id;
        coord.lat = _position.latitude;
        coord.lng = _position.longitude;
        api.postgps(coord);
      });
    });
  }

  void updateLocation() async {
    try {
      Position newPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best)
          .timeout(new Duration(seconds: 5));

      setState(() {
        _position = newPosition;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void performSelectPlan(planid) async {
    oneplan = await api.getPlan(planid);
    Navigator.push(
        _context, MaterialPageRoute(builder: (context) => PlanScreen()));
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return new MaterialApp(
      theme: ThemeData(primaryColor: Colors.blueGrey),
      home: new Scaffold(
        appBar: AppBar(
          title: Text('Gazon homeservice'),
          backgroundColor: Colors.green[600],
          centerTitle: true,
        ),
        body: new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                child: new Text('Работник: ' +
                    user.fio +
                    '\n' +
                    'Должность: ' +
                    user.func_name),
                width: 400.0,
                padding: new EdgeInsets.only(top: 10.0),
              ),
              new Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: plans.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                            new Container(
                                child: Text(
                                    'Рабочий объект: ' +
                                        plans[index].propadr +
                                        '\n' +
                                        'Наименование работы: ' +
                                        plans[index].workname +
                                        '\n' +
                                        'Дата: ' +
                                        plans[index].date +
                                        '\n' +
                                        'Количество(объем работы): ' +
                                        plans[index].count.toString() +
                                        '\n' +
                                        'Количество людей: ' +
                                        plans[index]
                                            .number_of_people
                                            .toString() +
                                        '\n' +
                                        'Количество часов: ' +
                                        plans[index].hours.toString() +
                                        '\n'
                                            'ФИО клиента: ' +
                                        plans[index].clientfio +
                                        '\n',
                                    style: TextStyle(fontSize: 18))),
                            new Container(
                              child: new ElevatedButton(
                                  onPressed: () {
                                    performSelectPlan(plans[index].id);
                                  },
                                  child: Text(
                                    "Выполнить",
                                    style: TextStyle(fontSize: 22),
                                  )),
                            ),
                          ]));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlanScreen extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Gazon homeservice',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new MyPlanPage());
  }
}

class MyPlanPage extends StatefulWidget {
  @override
  _MyPlanPageState createState() => new _MyPlanPageState();
}

class _MyPlanPageState extends State<MyPlanPage> {
  TextEditingController editingController = TextEditingController();
  late BuildContext _context;

  @override
  void initState() {
    super.initState();

    updateLocation();

    StreamSubscription positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _position = position;
        _time = DateTime.now();
        var coord = new Coordinate();
        coord.date = _time;
        coord.empid = user.id;
        coord.lat = _position.latitude;
        coord.lng = _position.longitude;
        api.postgps(coord);
      });
    });
  }

  void updateLocation() async {
    try {
      Position newPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best)
          .timeout(new Duration(seconds: 5));

      setState(() {
        _position = newPosition;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void backToPlans() async {
    Navigator.push(
        _context, MaterialPageRoute(builder: (context) => SecondScreen()));
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return new MaterialApp(
      theme: ThemeData(primaryColor: Colors.blueGrey),
      home: new Scaffold(
        appBar: AppBar(
          title: Text('Gazon homeservice'),
          backgroundColor: Colors.green[600],
          centerTitle: true,
        ),
        body: new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                child: new Text('Работник: ' +
                    user.fio +
                    '\n' +
                    'Должность: ' +
                    user.func_name),
                width: 400.0,
                padding: new EdgeInsets.only(top: 10.0),
              ),
              new Container(
                child: new BackButton(
                  onPressed: () {
                    backToPlans();
                  },
                ),
              ),
              new Container(
                  child: Text(
                      'Рабочий объект: ' +
                          oneplan.propadr +
                          '\n' +
                          'Наименование работы: ' +
                          oneplan.workname +
                          '\n' +
                          'Дата: ' +
                          oneplan.date +
                          '\n' +
                          'Количество людей: ' +
                          oneplan.number_of_people.toString() +
                          '\n' +
                          'ФИО клиента: ' +
                          oneplan.clientfio +
                          '\n',
                      style: TextStyle(fontSize: 18))),
              new Container(
                child: new TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Количество(объем работы)"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                  ],
                  maxLines: 1,
                  initialValue: oneplan.count.toString(),
                  onSaved: (val) => oneplan.count = num.tryParse(val ?? "")!,
                ),
              ),
              new Container(
                child: new TextFormField(
                  decoration:
                      new InputDecoration(labelText: "Количество часов"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                  ],
                  maxLines: 1,
                  initialValue: oneplan.hours.toString(),
                  onSaved: (val) => oneplan.hours = int.parse(val!),
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: new TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Комментарий",
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal))),
                  onSaved: (val) => oneplan.hours = int.parse(val!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

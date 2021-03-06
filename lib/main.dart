import 'dart:convert';
import 'package:intl/intl.dart';
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
      debugShowCheckedModeBanner: false,
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.green),
      home: new Scaffold(
        body: new Center(
          child: new Form(
              key: formKey,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    child: new TextFormField(
                      decoration: new InputDecoration(
                          labelText: "Email",
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal))),
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
                      decoration: new InputDecoration(
                          labelText: "Password",
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal))),
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
                      color: Colors.lightGreen[900],
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
      plans = [];
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
        debugShowCheckedModeBanner: false,
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

    updatePlans();
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

  void updatePlans() async {
    plans = await api.getListOfPlans(user.id);
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.green),
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
              Container(
                padding: const EdgeInsets.all(10.0),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '????',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: new Text('??????: ' +
                      user.fio +
                      '\n' +
                      '??????????????????: ' +
                      user.func_name),
                ),
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
                                padding: EdgeInsets.only(top: 2),
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: Text('?????????????? ????????????: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                    ),
                                    new Expanded(
                                      child: Text(plans[index].propadr,
                                          style: TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                )),
                            new Container(
                              padding: EdgeInsets.only(top: 2),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: Text('???????????????????????? ????????????: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                  new Expanded(
                                    child: Text(plans[index].workname,
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              ),
                            ),
                            new Container(
                              padding: EdgeInsets.only(top: 2),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: Text('????????: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                  new Expanded(
                                    child: Text(
                                        (DateFormat('yyyy-MM-dd ??? kk:mm')
                                                .format(DateTime.parse(
                                                    plans[index].date)))
                                            .toString(),
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              ),
                            ),
                            new Container(
                              padding: EdgeInsets.only(top: 2),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: Text('????????????????????(?????????? ????????????): ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                  new Expanded(
                                    child: Text(plans[index].count.toString(),
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              ),
                            ),
                            new Container(
                              padding: EdgeInsets.only(top: 2),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: Text('???????????????????? ??????????: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                  new Expanded(
                                    child: Text(
                                        plans[index]
                                            .number_of_people
                                            .toString(),
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              ),
                            ),
                            new Container(
                              padding: EdgeInsets.only(top: 2),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: Text('???????????????????? ??????????: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                  new Expanded(
                                    child: Text(plans[index].hours.toString(),
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              ),
                            ),
                            new Container(
                              padding: EdgeInsets.only(top: 2),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: Text('?????? ??????????????: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                  new Expanded(
                                    child: Text(plans[index].clientfio,
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              ),
                            ),
                            new Container(
                              padding: const EdgeInsets.all(7.5),
                              child: new ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors
                                        .lightGreen[900], // Background color
                                  ),
                                  onPressed: () {
                                    performSelectPlan(plans[index].id);
                                  },
                                  child: Text(
                                    "??????????????????",
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
        debugShowCheckedModeBanner: false,
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
  bool butcheker = true;
  bool butcheker1 = false;
  bool butcheker2 = false;
  var repm = new Repmob();

  @override
  void initState() {
    super.initState();
    repm.com = "default";

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

  void buttonUpdate(int index) {
    switch (index) {
      case 1:
        setState(() {
          butcheker1 = true;
          butcheker = false;
        });
        break;
      case 2:
        setState(() {
          butcheker2 = true;
          butcheker1 = false;
        });
        break;
    }
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
    repm.empid = user.id;
    repm.planid = oneplan.id;
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.green),
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
              Container(
                padding: const EdgeInsets.all(10.0),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '????',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: new Text('??????: ' +
                      user.fio +
                      '\n' +
                      '??????????????????: ' +
                      user.func_name),
                ),
              ),
              new Container(
                child: new BackButton(
                  onPressed: () {
                    backToPlans();
                  },
                ),
              ),
              new Container(
                  padding: EdgeInsets.only(top: 2),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                        child: Text('?????????????? ????????????: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      new Expanded(
                        child: Text(oneplan.propadr,
                            style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  )),
              new Container(
                padding: EdgeInsets.only(top: 2),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: Text('???????????????????????? ????????????: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    new Expanded(
                      child: Text(oneplan.workname,
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
              new Container(
                padding: EdgeInsets.only(top: 2),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: Text('????????: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    new Expanded(
                      child: Text(
                          (DateFormat('yyyy-MM-dd ??? kk:mm')
                                  .format(DateTime.parse(oneplan.date)))
                              .toString(),
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
              new Container(
                padding: EdgeInsets.only(top: 2),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: Text('???????????????????? ??????????: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    new Expanded(
                      child: Text(oneplan.number_of_people.toString(),
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
              new Container(
                padding: EdgeInsets.only(top: 2),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: Text('?????? ??????????????: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    new Expanded(
                      child: Text(oneplan.clientfio,
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 10),
                child: new TextFormField(
                  decoration: new InputDecoration(
                      labelText: "????????????????????(?????????? ????????????)",
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal))),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                  ],
                  maxLines: 1,
                  initialValue: oneplan.count.toString(),
                  onFieldSubmitted: (val) {
                    oneplan.count = int.parse(val);
                  },
                  onChanged: (val) {
                    oneplan.count = int.parse(val);
                  },
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 10),
                child: new TextFormField(
                  decoration: new InputDecoration(
                      labelText: "???????????????????? ??????????",
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal))),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                  ],
                  maxLines: 1,
                  initialValue: oneplan.hours.toString(),
                  onFieldSubmitted: (val) {
                    oneplan.hours = int.parse(val);
                  },
                  onChanged: (val) {
                    oneplan.hours = int.parse(val);
                  },
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: new TextFormField(
                  decoration: new InputDecoration(
                      labelText: "??????????????????????",
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal))),
                  onFieldSubmitted: (val) {
                    repm.com = val;
                  },
                  onChanged: (val) {
                    repm.com = val.toString();
                  },
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: new MaterialButton(
                    onPressed: butcheker
                        ? () {
                            buttonUpdate(1);
                            api.startRoute(oneplan.id, user.id, DateTime.now());
                          }
                        : null,
                    child: Text(
                      "???????????? ??????????????",
                      style: TextStyle(fontSize: 22),
                    )),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: new MaterialButton(
                    onPressed: butcheker1
                        ? () {
                            buttonUpdate(2);
                            api.endRoute(oneplan.id, user.id, DateTime.now());
                          }
                        : null,
                    child: Text(
                      "?????????????????? ??????????????",
                      style: TextStyle(fontSize: 22),
                    )),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: new ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightGreen[900], // Background color
                    ),
                    onPressed: butcheker2
                        ? () {
                            api.genRep(repm);
                            api.executePlan(oneplan);
                            plans = [];
                            backToPlans();
                          }
                        : null,
                    child: Text(
                      "??????????????????",
                      style: TextStyle(fontSize: 22),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

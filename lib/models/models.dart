import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginData {
  late String email;
  late String password;
}

class UserData {
  late int id;
  late String fio;
  late String func_name;
}

class PlanData {
  // default plan
  late int id;
  late int workid;
  late int propertyid;
  late String date;
  late num count;
  late int number_of_people;
  late int hours;
  // another info
  late String propadr;
  late String clientfio;
  late String workname;
}

class Coordinate {
  late int empid;
  late DateTime date;
  late num lat;
  late num lng;
}

class Repmob {
  late int planid;
  late int empid;
  late String com;
}

import 'dart:convert';
import 'package:hsmob/models/models.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApiService {
  Future<UserData> login(email, password) async {
    final response = await http.Client().post(
      Uri.parse('http://192.168.1.4:3000/api/Mobile/getUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'login': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final Map parsed = json.decode(response.body);
      var result = new UserData();
      result.id = parsed["employee"]["id"];
      result.fio = parsed["employee"]["fio"];
      result.func_name = parsed["func_name"];
      return result;
    } else {
      throw Exception();
    }
  }

  Future<List<PlanData>> getListOfPlans(userid) async {
    final response = await http.Client().get(Uri.parse(
        'http://192.168.1.4:3000/api/Plan/getPlanByEmployeeId/${userid}'));
    if (response.statusCode == 200) {
      final List<dynamic> parsed = json.decode(response.body);
      List<PlanData> result = [];
      for (var pl in parsed) {
        var plan = new PlanData();
        plan.id = pl["plan"]["plan"]["id"];
        plan.workid = pl["plan"]["plan"]["workid"];
        plan.propertyid = pl["plan"]["plan"]["propertyid"];
        plan.date = pl["plan"]["plan"]["date"];
        plan.count = pl["plan"]["plan"]["count"];
        plan.number_of_people = pl["plan"]["plan"]["number_of_people"];
        plan.hours = pl["plan"]["plan"]["hours"];
        plan.clientfio = pl["client"]["fio"];
        plan.workname = pl["plan"]["workname"];
        plan.propadr = pl["property"]["adress"];
        result.add(plan);
      }
      return result;
    } else {
      throw Exception();
    }
  }

  Future<PlanData> getPlan(id) async {
    final response = await http.Client()
        .get(Uri.parse('http://192.168.1.4:3000/api/Plan/getPlansById/${id}'));
    if (response.statusCode == 200) {
      final dynamic parsed = json.decode(response.body);
      var plan = new PlanData();
      plan.id = parsed["plan"]["plan"]["id"];
      plan.workid = parsed["plan"]["plan"]["workid"];
      plan.propertyid = parsed["plan"]["plan"]["propertyid"];
      plan.date = parsed["plan"]["plan"]["date"];
      plan.count = parsed["plan"]["plan"]["count"];
      plan.number_of_people = parsed["plan"]["plan"]["number_of_people"];
      plan.hours = parsed["plan"]["plan"]["hours"];
      plan.clientfio = parsed["client"]["fio"];
      plan.workname = parsed["plan"]["workname"];
      plan.propadr = parsed["property"]["adress"];
      return plan;
    } else {
      throw Exception();
    }
  }

  void postgps(Coordinate gps) async {
    final response = await http.Client().post(
      Uri.parse('http://192.168.1.4:3000/api/Mobile/takegps'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'employeeid': gps.empid.toString(),
        'time': gps.date.toIso8601String(),
        'lat': gps.lat.toString(),
        'lng': gps.lng.toString(),
      }),
    );
    if (response.statusCode == 200) {
      //
    } else {
      throw Exception();
    }
  }

  void executePlan(PlanData plan) async {
    final response = await http.Client().post(
      Uri.parse('http://192.168.1.4:3000/api/Plan/addFactFromPlan'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': plan.id.toString(),
        'workid': plan.workid.toString(),
        'propertyid': plan.propertyid.toString(),
        'date': plan.date,
        'count': plan.count.toString(),
        'number_of_people': plan.number_of_people.toString(),
        'hours': plan.hours.toString(),
      }),
    );
    if (response.statusCode == 200) {
      //
    } else {
      throw Exception();
    }
  }

  void startRoute(int planid, int empid, DateTime time) async {
    final response = await http.Client().get(
      Uri.parse(
          'http://192.168.1.4:3000/api/Mobile/startRoute/${planid}&&${empid}&&${time}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      //
    } else {
      throw Exception();
    }
  }

  void endRoute(int planid, int empid, DateTime time) async {
    final response = await http.Client().get(
      Uri.parse(
          'http://192.168.1.4:3000/api/Mobile/endRoute/${planid}&&${empid}&&${time}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      //
    } else {
      throw Exception();
    }
  }

  void genRep(Repmob repm) async {
    final response = await http.Client().post(
      Uri.parse('http://192.168.1.4:3000/api/Mobile/genRep'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'planid': repm.planid.toString(),
        'empid': repm.empid.toString(),
        'com': repm.com,
      }),
    );
    if (response.statusCode == 200) {
      //
    } else {
      throw Exception();
    }
  }
}

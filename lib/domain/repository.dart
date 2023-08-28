import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/data_model.dart';

const String url = "https://qt.toutatice.fr/strapi/api/services?populate=*";
// const String url = "https://www.toutatice.fr/strapi/services";

List<Service> parseService(String responseBody) {
  var list = json.decode(responseBody)['data'] as List<dynamic>;
  var qualite = list[0]['attributes']['qualite_de_service']['data']['attributes'];
  print('--------------- [REFRESHED] ------------------');
  var services = list.map((e) => Service.fromJson(e)).toList();
  return services;
}

Future<List<Service>> fetchServices() async {
  final http.Response response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return compute(parseService, response.body);
  } else {
    throw Exception(response.statusCode);
  }
}

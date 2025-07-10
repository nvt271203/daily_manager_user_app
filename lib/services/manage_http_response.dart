import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void manageHttpResponse(
    http.Response response, BuildContext context, VoidCallback onSuccess) {
  switch (response.statusCode) {
    case 200:
      onSuccess();
      break;
    case 400:
      showSnackBar(context, json.decode(response.body)['message']);
      print('msg receive: '+ json.decode(response.body)['message']);
      break;
    case 500:
      showSnackBar(context, json.decode(response.body)['error']);
      print('error receive: '+ json.decode(response.body)['error']);
      break;
    case 201:
      onSuccess();
      break;
  }
}
void showSnackBar(BuildContext context, String title){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
}

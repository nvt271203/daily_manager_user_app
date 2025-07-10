import 'dart:convert';

import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:daily_manage_user_app/screens/main_screen.dart';
import 'package:daily_manage_user_app/services/manage_http_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../global_variables.dart';
import '../models/user.dart';
import '../screens/guest_screens/login_screen.dart';
import '../widgets/dialog_confirm_widget.dart';
final providerContainer = ProviderContainer();
class AuthController {
  // API request register
  Future<void> registerUser(
    context,
    String fullName,
    DateTime birthDay,
    String sex,
    String email,
    String password,
  ) async {
    try {
      User user = User(
        id: '',
        fullName: fullName,
        birthDay: birthDay,
        sex: sex,
        email: email,
        password: password,
        image: '',
        phoneNumber: '', token: '',
      );
      http.Response response = await http.post(
        Uri.parse('$uri/api/register'),
        body: user.toJson(),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
      );
      print('response - ${response.body.toString()}');
      manageHttpResponse(response, context, () {
        showSnackBar(context, 'Account has been created for you');
      });
    } catch (e) {
      print('Error request-response auth register: $e');
    }
  }

  // API request login
  Future<void> loginUser(BuildContext context, WidgetRef ref, String email, String password) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8"
        }
      );
      print('response - ${response.body.toString()}');
      manageHttpResponse(response, context, ()async{
        // Save data local
        SharedPreferences preferences = await SharedPreferences.getInstance();
        // save token user from backend
        String token = jsonDecode(response.body)['token'];
        await preferences.setString('auth_token', token);

        final userJson = jsonEncode(jsonDecode(response.body)['user']);
        //comment thay bằng dưới
        // providerContainer.read(userProvider.notifier).setUser(userJson);
        ref.read(userProvider.notifier).setUser(userJson);
        await preferences.setString('user', userJson);


        showSnackBar(context, 'Accout has been login success');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
          return MainScreen();
        },), (route) => false,);
      });

    } catch (e) {
      print('Error request-response auth register: $e');
    }
  }
  Future<void> logoutUser(context)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('auth_token');
    await preferences.remove('user');
    providerContainer.read(userProvider.notifier).signOut();

    showDialog(context: context, builder: (context) {
      return DialogConfirmWidget(title: 'Logout', content: 'Are you sure want to log out of your account !', onConfirm: () {
        Navigator.of(context).pop(); // Đóng Dialog
        // Đợi một khung hình rồi mới chuyển trang để tránh xung đột context
        Future.delayed(Duration(milliseconds: 100), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
          );
        });

      },);
    },);

    // showSnackBar(context, 'Logout success');


  }
}

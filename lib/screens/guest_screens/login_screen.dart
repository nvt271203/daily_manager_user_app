import 'package:daily_manage_user_app/controller/auth_controller.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/screens/guest_screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  AuthController _authController = AuthController();
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User user = User.newUser();
  late String _email;
  late String _password;
  Future<void> _login()async{
    if(_formKey.currentState != null && _formKey.currentState!.validate()){
      print(_email);
      print(_password);

      setState(() {
        isLoading = true;
      });
      await _authController.loginUser(context,ref, _email, _password);
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: HelpersColors.itemPrimary,
        title: Center(child: Text('Login account',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/bg_1.png',height: 250,width: double.infinity,fit: BoxFit.cover,),
                  Center(child: Text('App Daily Manage', style: TextStyle(
                      color: HelpersColors.itemPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),)),
                  // Center(
                  //   child: Text(
                  //     'Login',
                  //     style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                  SizedBox(height: 15),
                  TextFormField(
                    onChanged: (value) {
                      _email = value;
                    },
                    validator: (value) {
                      return user.emailValidate(value);
                    },
                    style: TextStyle(color: Colors.blue),
                    // 👈 Màu chữ khi gõ vào (focus)sss
                    decoration: InputDecoration(
                        fillColor: HelpersColors.bgFillTextField,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: HelpersColors.bgFillTextField,
                                width: 1.0)
                        ),
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                            color: HelpersColors.itemTextField.withOpacity(
                                0.8)),
                        prefixIcon: Icon(Icons.email,
                          color: HelpersColors.itemTextField,)
                    ),
                  ),

                  SizedBox(height: 15,),
                  TextFormField(
                    onChanged: (value) {
                      _password = value;
                    },
                    validator: (value) {
                      return user.passwordValidate(value);
                    },
                    obscureText: true,
                    style: TextStyle(color: Colors.blue),
                    // 👈 Màu chữ khi gõ vào (focus)sss
                    decoration: InputDecoration(
                        fillColor: HelpersColors.bgFillTextField,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: HelpersColors.bgFillTextField,
                                width: 1.0)
                        ),
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                            color: HelpersColors.itemTextField.withOpacity(
                                0.8)),
                        prefixIcon: Icon(Icons.lock,
                          color: HelpersColors.itemTextField,)
                    ),
                  ),


                  SizedBox(height: 40,),
                  InkWell(
                    onTap: () => isLoading ? null : _login(),
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: HelpersColors.itemPrimary,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 50,),
                          isLoading ? Center(child: CircularProgressIndicator(),) : Text('Login now',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 16),),
                          Spacer(),
                          Icon(Icons.arrow_right_alt,color: Colors.white,size: 30,),
                          SizedBox(width: 20,),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Text('Forget password ?',style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return RegisterScreen();
                          },));
                        }
                          ,child: Text('Register now !',style: TextStyle(color: HelpersColors.itemPrimary,fontWeight: FontWeight.bold),))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

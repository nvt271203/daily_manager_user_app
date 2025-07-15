import 'dart:io';

import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:flutter/material.dart';

import '../../../../../../helpers/tools_colors.dart';
import '../../../../../../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../services/manage_http_response.dart';

class InformationScreen extends ConsumerStatefulWidget {
  const InformationScreen({super.key});

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends ConsumerState<InformationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? image;
  String _selectedSex = 'Male'; // hoặc null nếu chưa chọn
  final List<String> sex = ['Male', 'Female', 'Other'];
  final ImagePicker picker = ImagePicker();

  // Lắng nghe sự kiện click
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _positionController;
  late TextEditingController _passwordController;

  // Lắng nghe sự kiên focus
  late FocusNode _focusNodeFullName;
  late FocusNode _focusNodePhoneNumber;
  bool _isEditing = false;

  Widget _buildTextFile(String title) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          color: HelpersColors.itemPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      showSnackBar(context, 'No Image Picked Selected');
    } else {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final user = ref.read(userProvider);
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _positionController = TextEditingController(
      text: (user?.image == null || user!.image.trim().isEmpty)
          ? 'Unset'
          : user.image,
    );
    _passwordController = TextEditingController();

    _focusNodeFullName = FocusNode();
    _focusNodePhoneNumber = FocusNode();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: HelpersColors.itemPrimary,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'Information',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image.asset(
                    //   'assets/images/bg_1.png',
                    //   height: 250,
                    //   width: double.infinity,
                    //   fit: BoxFit.cover,
                    // ),
                    // Center(
                    //   child: Text(
                    //     'App Daily Manage',
                    //     style: TextStyle(
                    //       color: HelpersColors.itemPrimary,
                    //       fontSize: 30,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black.withOpacity(0.6),
                                width: 4,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              // Đây là padding thực sự
                              child: ClipOval(
                                child: Image(
                                  image:
                                  user?.image == null ||
                                      user!.image.isEmpty
                                      ? AssetImage(
                                    user?.sex == 'Male'
                                        ? 'assets/images/avatar_boy_default.jpg'
                                        : user?.sex == "Female"
                                        ? 'assets/images/avatar_girl_default.jpg'
                                        : 'assets/images/avt_default_2.jpg',
                                  )
                                  as ImageProvider
                                      : NetworkImage(user.image),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                // chooseImage();
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                child: Icon(Icons.upload_rounded,color: Colors.white,),
                                decoration: BoxDecoration(
                                    color: HelpersColors.itemPrimary,
                                    border: Border.all(color: Colors.white, width: 4),
                                    borderRadius: BorderRadius.all(Radius.circular(50))
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),


                    SizedBox(height: 10),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (user?.fullName == null ||
                                    user!.fullName.trim().isEmpty)
                                ? 'Linh Hồn'
                                : user.fullName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // SizedBox(width: 60),
                          // Text(
                          //   '18',
                          //   style: TextStyle(
                          //     color: Colors.blue,
                          //     fontSize: 20,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          // Icon(Icons.male, color: Colors.blue),
                        ],
                      ),
                    ),

                    //Email
                    // SizedBox(height: 15),
                    _buildTextFile('Email'),
                    TextFormField(
                      readOnly: true,
                      controller: _emailController,
                      onChanged: (value) {
                        // _email = value;
                      },
                      validator: (value) {
                        // return user.emailValidate(value);
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: HelpersColors.itemTextField),
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
                            width: 1.0,
                          ),
                        ),
                        // hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: HelpersColors.itemTextField.withOpacity(0.8),
                        ),
                        prefixIcon: Icon(
                          Icons.email,
                          color: HelpersColors.itemTextField,
                        ),
                      ),
                    ),

                    //Position
                    _buildTextFile('Position'),
                    TextFormField(
                      readOnly: true,
                      controller: _positionController,
                      onChanged: (value) {
                        // _email = value;
                      },
                      validator: (value) {
                        // return user.emailValidate(value);
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: HelpersColors.itemTextField),
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
                            width: 1.0,
                          ),
                        ),
                        // hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: HelpersColors.itemTextField.withOpacity(0.8),
                        ),
                        prefixIcon: Icon(
                          Icons.work,
                          color: HelpersColors.itemTextField,
                        ),
                      ),
                    ),

                    //Full Name
                    _buildTextFile('Full Name'),
                    TextFormField(
                      focusNode: _focusNodeFullName,
                      controller: _fullNameController,
                      readOnly: !_isEditing,
                      onChanged: (value) {
                        // _fullName = value;
                      },
                      validator: (value) {
                        // return user.fullNameValidate(value);
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
                            width: 1.0,
                          ),
                        ),
                        hintText: 'Edit your fullname',
                        hintStyle: TextStyle(
                          color: HelpersColors.itemTextField.withOpacity(0.8),
                        ),
                        prefixIcon: Icon(
                          Icons.text_fields_sharp,
                          color: HelpersColors.itemTextField,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isEditing ? Icons.edit : Icons.edit,
                            color: _isEditing
                                ? HelpersColors.itemPrimary
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                            if (_isEditing) {
                              Future.delayed(Duration(milliseconds: 100), () {
                                _focusNodeFullName
                                    .requestFocus(); // ✅ focus đúng node
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    _buildTextFile('Sex'),
                    InkWell(
                      onTap: () async {
                        final selected = await showModalBottomSheet<String>(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: sex.map((item) {
                                return ListTile(
                                  title: Text(item),
                                  onTap: () {
                                    Navigator.pop(context, item);
                                  },
                                );
                              }).toList(),
                            );
                          },
                        );

                        if (selected != null) {
                          setState(() {
                            _selectedSex = selected;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: HelpersColors.bgFillTextField,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.transgender,
                              color: HelpersColors.itemTextField,
                            ),
                            SizedBox(width: 15),
                            Text(
                              _selectedSex.isEmpty ? 'Sex' : _selectedSex,
                              style: TextStyle(
                                color: HelpersColors.itemTextField,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.edit,
                              color: HelpersColors.itemTextField,
                            ),
                          ],
                        ),
                      ),
                    ),

                    _buildTextFile('Birthday'),
                    InkWell(
                      onTap: () {
                        // _presentDatePicker();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              // border:Border.all(color: HelpersColors.itemSelected, width: 1),
                              color: HelpersColors.bgFillTextField,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: HelpersColors.itemTextField,
                                ),
                                SizedBox(width: 15),
                                Text(
                                  ' Edit your birthday',
                                  // _birthDay == null
                                  //     ? 'Birthday'
                                  //     : FormatHelper.formatDate_DD_MM_YYYY(_birthDay!),
                                  style: TextStyle(
                                    color: HelpersColors.itemTextField,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.edit,
                                  color: HelpersColors.itemTextField,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildTextFile('Phone Number'),
                    TextFormField(
                      focusNode: _focusNodePhoneNumber,
                      controller: _phoneController,
                      readOnly: !_isEditing,
                      onChanged: (value) {
                        // _fullName = value;
                      },
                      validator: (value) {
                        // return user.fullNameValidate(value);
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
                            width: 1.0,
                          ),
                        ),
                        hintText: 'Edit your phone number',
                        hintStyle: TextStyle(
                          color: HelpersColors.itemTextField.withOpacity(0.8),
                        ),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: HelpersColors.itemTextField,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isEditing ? Icons.edit : Icons.edit,
                            color: _isEditing
                                ? HelpersColors.itemPrimary
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                            if (_isEditing) {
                              Future.delayed(Duration(milliseconds: 100), () {
                                _focusNodePhoneNumber
                                    .requestFocus(); // ✅ focus đúng node
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 15),
                    InkWell(
                      onTap: () {
                        // _isLoading ? null : _register();
                        // _isLoading ? null : _register();
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: HelpersColors.itemPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          children: [
                            Spacer(),
                            _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : Text(
                                    'Update',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                            Spacer(),
                            Icon(
                              Icons.arrow_right_alt,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

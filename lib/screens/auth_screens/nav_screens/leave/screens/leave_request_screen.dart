import 'package:daily_manage_user_app/controller/leave_controller.dart';
import 'package:daily_manage_user_app/helpers/format_helper.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/models/leave.dart';
import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  // Kiểm tra nếu có dữ liệu gửi để hiện chi tiết.

  LeaveController _leaveController = LeaveController();
  String? _leaveType;
  String? _leaveTimeType;

  late DateTime dateCreated;
  TimeOfDay? _startTime; // giờ bắt đầu
  DateTime? _startDate;

  TimeOfDay? _endTime; // giờ kết thúc
  DateTime? _endDate;

  late DateTime? _fullStartDateTime;
  late DateTime? _fullEndDateTime;
  late String _reason;
  bool _isLoading = false;
  bool _errorLeaveType = false;
  bool _errorLeaveTimeType = false;
  bool _errorStartTime = false;
  bool _errorStartDate = false;
  bool _errorEndTime = false;
  bool _errorEndDate = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _chooseStartTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _startTime = pickedTime;
      });

      // if (_startDate != null) {
      //   // Cập nhật lại _startDate kèm giờ
      //   final newDate = DateTime(
      //     _startDate!.year,
      //     _startDate!.month,
      //     _startDate!.day,
      //     pickedTime.hour,
      //     pickedTime.minute,
      //   );
      //   setState(() {
      //     _startDate = newDate;
      //   });
      // }
    }
  }
  void _chooseEndTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _endTime = pickedTime;
      });
      // if (_startDate != null) {
      //   // Cập nhật lại _startDate kèm giờ
      //   final newDate = DateTime(
      //     _startDate!.year,
      //     _startDate!.month,
      //     _startDate!.day,
      //     pickedTime.hour,
      //     pickedTime.minute,
      //   );
      //   setState(() {
      //     _startDate = newDate;
      //   });
      // }
    }
  }
  void _chooseDateStartPicker() async {
    final now = DateTime.now();
    final initialDate = DateTime.now();
    final firstDate = DateTime(now.year);
    final lastDate = DateTime(now.year + 1);
    final pickerDate = await showDatePicker(
      initialDate: initialDate,
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickerDate != null) {
      // final dateWithTime = DateTime(
      //   pickerDate.year,
      //   pickerDate.month,
      //   pickerDate.day,
      //   now.hour,
      //   now.minute,
      //   now.second,
      // );
      setState(() {
        _startDate = pickerDate;
      });
    }
  }

  void _chooseDateEndPicker() async {
    final now = DateTime.now();
    final initialDate = DateTime.now();
    final firstDate = DateTime(now.year);
    final lastDate = DateTime(now.year + 1);
    final pickerDate = await showDatePicker(
      initialDate: initialDate,
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickerDate != null) {
      final dateWithTime = DateTime(
        pickerDate.year,
        pickerDate.month,
        pickerDate.day,
        // now.hour,
        // now.minute,
        // now.second,
      );
      setState(() {
        _endDate = dateWithTime;
      });
    }
  }

  void _submit() async {
    if (_leaveType == null) {
      setState(() {
        _errorLeaveType = true;
      });
    } else {
      setState(() {
        _errorLeaveType = false;
      });
    }

    if (_leaveTimeType == null) {
      setState(() {
        _errorLeaveTimeType = true;
      });
    } else {
      setState(() {
        _errorLeaveTimeType = false;
      });
    }

    if (_startTime == null) {
      setState(() {
        _errorStartTime = true;
      });
    } else {
      setState(() {
        _errorStartTime = false;
      });
    }
    if (_startDate == null) {
      setState(() {
        _errorStartDate = true;
      });
    } else {
      setState(() {
        _errorStartDate = false;
      });
    }

    if (_endTime == null) {
      setState(() {
        _errorEndTime = true;
      });
    } else {
      setState(() {
        _errorEndTime = false;
      });
    }
    if (_endDate == null) {
      setState(() {
        _errorEndDate = true;
      });
    } else {
      setState(() {
        _errorEndDate = false;
      });
    }
    if(_startTime!=null && _startDate!=null){
      setState(() {
        _fullStartDateTime = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
            _startTime!.hour,
            _startTime!.minute
        );
      });
    }
    if(_endTime!=null && _endDate!=null){
      setState(() {
        _fullEndDateTime = DateTime(
            _endDate!.year,
            _endDate!.month,
            _endDate!.day,
            _endTime!.hour,
            _endTime!.minute
        );
      });
    }

    if (_formKey.currentState != null &&
        _formKey.currentState!.validate() &&
        _leaveType != null &&
        _leaveTimeType != null &&
        _fullStartDateTime != null &&
        _fullEndDateTime != null) {
      final user = ref.read(userProvider); // ✅ thêm dòng này ở đầu
      setState(() {
        _isLoading = true;
      });
      print('_leaveType  - ${_leaveType}');
      print('_leaveTimeType  - ${_leaveTimeType}');
      print('_startDate  - ${_startDate}');
      print('_endDate  - ${_endDate}');
      print('_reason  - ${_reason}');

      await _leaveController.requestLeave(
        context: context,
        dateCreated: DateTime.now(),
        leaveType: _leaveType!,
        leaveTimeType: _leaveTimeType!,
        startDate: _fullStartDateTime!,
        endDate: _fullEndDateTime!,
        reason: _reason,
        userId: user!.id,
      );
      // ✅ Sau khi gửi xong, quay lại trang trước và trả về `true`
      if (context.mounted) {
        Navigator.pop(context, true);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Request'),
        centerTitle: true,
        backgroundColor: HelpersColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextTitle(title: '* Leave Type'),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _errorLeaveType
                              ? HelpersColors.itemSelected
                              : HelpersColors.primaryColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: DropdownButton(
                        items: leaveType.map((e) {
                          return DropdownMenuItem(child: Text(e), value: e);
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _leaveType = value as String?);
                        },
                        hint: Center(child: Text('Choose Leave Type')),
                        value: _leaveType,
                        isExpanded: true,

                        dropdownColor: Colors.white,
                        underline: SizedBox(),
                      ),
                    ),
                    if (_errorLeaveType)
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          'Leave type is required',
                          style: TextStyle(color: HelpersColors.itemSelected),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),

                _buildTextTitle(title: '* Leave Time Type'),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _errorLeaveTimeType
                              ? HelpersColors.itemSelected
                              : HelpersColors.primaryColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: DropdownButton(
                        items: leaveTimeType.map((e) {
                          return DropdownMenuItem(child: Text(e), value: e);
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _leaveTimeType = value as String?;

                            if (_leaveTimeType == 'Full Time') {
                              _startTime = TimeOfDay(hour: 8, minute: 30); // 🕗 8:30 AM
                              _endTime = TimeOfDay(hour: 17, minute: 30);  // 🕔 5:30 PM
                            }
                            if (_leaveTimeType == 'Part Time') {
                              _startTime = null; // 🕗 8:30 AM
                              _endTime = null;  // 🕔 5:30 PM
                            }
                          });
                        },
                        hint: Center(child: Text('Choose Leave Time Type')),
                        value: _leaveTimeType,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        underline: SizedBox(),
                      ),
                    ),
                    if (_errorLeaveTimeType)
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          'Leave time type is required',
                          style: TextStyle(color: HelpersColors.itemSelected),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextTitle(title: '* Start Time'),
                          InkWell(
                            onTap: () {
                              _chooseStartTimePicker();
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _errorStartTime
                                          ? HelpersColors.itemSelected
                                          : HelpersColors.primaryColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time),
                                      SizedBox(width: 10),
                                      Text(
                                        _startTime == null
                                            ? 'Choose start time'
                                            : _startTime!.format(context),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_errorStartTime)
                                  Align(
                                    alignment: AlignmentDirectional.topStart,
                                    child: Text(
                                      'Time start is required',
                                      style: TextStyle(
                                        color: HelpersColors.itemSelected,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextTitle(title: '* Start Day'),
                          InkWell(
                            onTap: () {
                              _chooseDateStartPicker();
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _errorStartDate
                                          ? HelpersColors.itemSelected
                                          : HelpersColors.primaryColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today),
                                      SizedBox(width: 10),
                                      Text(
                                        _startDate == null
                                            ? 'Choose day start'
                                            : FormatHelper.formatDate_DD_MM_YYYY(
                                          _startDate!,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_errorStartDate)
                                  Align(
                                    alignment: AlignmentDirectional.topStart,
                                    child: Text(
                                      'Day start is required',
                                      style: TextStyle(
                                        color: HelpersColors.itemSelected,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextTitle(title: '* End time'),
                          InkWell(
                            onTap: () {
                              _chooseEndTimePicker();
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _errorEndTime
                                          ? HelpersColors.itemSelected
                                          : HelpersColors.primaryColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time_outlined),
                                      SizedBox(width: 10),
                                      Text(
                                        _endTime == null
                                            ? 'Choose end time'
                                            : _endTime!.format(context),

                                ),
                                    ],
                                  ),
                                ),
                                if (_errorEndTime)
                                  Align(
                                    alignment: AlignmentDirectional.topStart,
                                    child: Text(
                                      'Time end is required',
                                      style: TextStyle(
                                        color: HelpersColors.itemSelected,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextTitle(title: '* End Day'),
                          InkWell(
                            onTap: () {
                              _chooseDateEndPicker();
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _errorEndDate
                                          ? HelpersColors.itemSelected
                                          : HelpersColors.primaryColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today),
                                      SizedBox(width: 10),
                                      Text(
                                        _endDate == null
                                            ? 'Choose day end'
                                            : FormatHelper.formatDate_DD_MM_YYYY(
                                          _endDate!,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_errorEndDate)
                                  Align(
                                    alignment: AlignmentDirectional.topStart,
                                    child: Text(
                                      'Day end is required',
                                      style: TextStyle(
                                        color: HelpersColors.itemSelected,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                _buildTextTitle(title: '* Reason'),
                TextFormField(
                  maxLines: 7,
                  onChanged: (value) {
                    _reason = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Reason is required';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: HelpersColors.primaryColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: HelpersColors.primaryColor,
                        width: 1.0,
                      ),
                    ),
                    hintText: 'Please enter reason for leave',
                  ),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    _submit();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: HelpersColors.primaryColor,
                      gradient: LinearGradient(
                        colors: [
                          HelpersColors.primaryColor,
                          HelpersColors.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 50),
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Text(
                                'Leave request',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        Spacer(),
                        Icon(
                          Icons.arrow_right_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(width: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextTitle({required String title}) {
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}

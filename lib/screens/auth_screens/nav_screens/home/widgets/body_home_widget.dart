import 'dart:async';
import 'package:daily_manage_user_app/controller/work_controller.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/home/widgets/confirm_check_in_widget.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/home/widgets/weekly_overview_widget.dart';
import 'package:daily_manage_user_app/widgets/dialog_confirm_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/home/widgets/check_status_finish_dialog_widget.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/home/widgets/weekly_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../helpers/format_helper.dart';
import '../../../../../providers/work_provider.dart';
import 'mission_dialog_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class BodyHomeWidget extends ConsumerStatefulWidget {
  const BodyHomeWidget({super.key});

  @override
  _BodyHomeWidgetState createState() => _BodyHomeWidgetState();
}

class _BodyHomeWidgetState extends ConsumerState<BodyHomeWidget>
    with SingleTickerProviderStateMixin {
  WorkController _workController = WorkController();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // time nay k realtime
  // final now = DateTime.now();
  late DateTime _now;
  Timer? _timer;

  // Click check-in
  bool _isCheckedIn = false;
  Duration _checkInDuration = Duration.zero;
  Timer? _checkInTimer;

  //save time check-in
  late DateTime _checkInTime;
  late DateTime _checkOutTime;

  void _startCheckInTimer() {
    // _checkInDuration = Duration.zero;
    _checkInTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // if (!mounted) return; // Nên thêm sau này, nếu
      setState(() {
        _checkInDuration += Duration(seconds: 1);
      });
    });
  }

  // save SharedPreference timeCheckIn
  Future<void> _saveCheckInTime(DateTime dateTime) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final user = ref.read(userProvider);
    if (user != null) {
      await preferences.setString(
        'checkInTime_${user.id}',
        dateTime.toIso8601String(),
      );
      await preferences.setBool(
        'isCheckedIn_${user.id}',
        true,
      ); // 👈 thêm dòng này
    }
  }

  // save SharedPreference timeCheckIn
  Future<void> _savedCheckOutTime(DateTime dateTime) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // Xoá trạng thái đã check-in
    final user = ref.read(userProvider);
    await preferences.remove('checkInTime_${user!.id}');
    await preferences.remove('isCheckedIn_${user.id}');

    // _checkInTimer?.cancel();
    // // _checkInDuration = Duration.zero;
    // setState(() {
    //   _isCheckedIn = false;
    // });
  }

  Future<void> _loadCheckInTime() async {
    final user = ref.read(userProvider);
    if (user == null) return;

    SharedPreferences preferences = await SharedPreferences.getInstance();

    // 👉 Kiểm tra flag check-in trước
    final isCheckedIn = preferences.getBool('isCheckedIn_${user.id}') ?? false;
    final saved = preferences.getString('checkInTime_${user.id}');

    if (isCheckedIn && saved != null) {
      setState(() {
        _checkInTime = DateTime.parse(saved).toLocal();
        _isCheckedIn = true;
        final now = DateTime.now();
        _checkInDuration = now.difference(_checkInTime!);
        _startCheckInTimer();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    //Load xem da checkin chua
    _loadCheckInTime();

    _now = DateTime.now();

    // Cập nhật _now mỗi giây
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      // if (!mounted) return; ///
      setState(() {
        _now = DateTime.now();
      });
    });

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  // @override
  // void dispose() {
  //   _controller.dispose(); // Giải phóng animation
  //   _timer?.cancel(); // Dừng đồng hồ
  //
  //   super.dispose();
  // }
  @override
  void dispose() {
    _controller.dispose(); // Animation
    _timer?.cancel(); // Đồng hồ hiển thị giờ
    _checkInTimer?.cancel(); // ✅ Thêm dòng này để hủy bộ đếm thời gian check-in
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    return SafeArea(
      child: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          //   child:
          //
          //   Container(
          //     decoration: BoxDecoration(
          //       // color: const Color(0xFFE0F2FE), // 🌿 Nền xanh nhạt
          //       borderRadius: BorderRadius.circular(20), // 🌟 Bo góc
          //       gradient: LinearGradient(colors: [
          //         Color(0xFFE0F2FE), Colors.white
          //       ]),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black12.withOpacity(0.1), // 🌫 Bóng nhẹ
          //           blurRadius: 6,
          //           offset: const Offset(0, 3),
          //         ),
          //       ],
          //     ),
          //     padding: const EdgeInsets.all(16),
          //     child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         // 🔹 Phần chữ bên trái
          //         Expanded(
          //           flex: 3,
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 'Hello,',
          //                 style: GoogleFonts.oswald(
          //                   textStyle: TextStyle(
          //                     fontSize: 18,
          //                     fontWeight: FontWeight.w700,
          //                     color: Colors.grey.shade800.withOpacity(0.8),
          //                   ),
          //                 ),
          //               ),
          //               Text(
          //                 (user?.fullName == null || user!.fullName.trim().isEmpty) ?
          //                     'New user'
          //                 :
          //                 user.fullName,
          //                 style: GoogleFonts.oswald(
          //                   textStyle: TextStyle(
          //                     fontSize: 22,
          //                     fontWeight: FontWeight.w900,
          //                     color: HelpersColors.primaryColor,
          //                     letterSpacing: 1.5,
          //                   ),
          //                 ),
          //               ),
          //               const SizedBox(height: 6),
          //               Text(
          //                 'A fresh start, a new chance!',
          //                 style: TextStyle(
          //                   fontSize: 14,
          //                   color: Colors.grey.shade600,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //
          //         const SizedBox(width: 16),
          //
          //         // 🔹 Ảnh minh họa bên phải
          //         ClipRRect(
          //           borderRadius: BorderRadius.circular(100),
          //           child: user?.image == null || user!.image.isEmpty
          //               ? Image.asset(
          //             user?.sex == 'Male'
          //                 ? 'assets/images/avatar_boy_default.jpg'
          //                 : user?.sex == 'Female'
          //                 ? 'assets/images/avatar_girl_default.jpg'
          //                 : 'assets/images/avt_default_2.jpg',
          //             width: 100,
          //             height: 100,
          //             fit: BoxFit.cover,
          //           )
          //               : Image.network(
          //             user.image,
          //             width: 100,
          //             height: 100,
          //             fit: BoxFit.cover,
          //           ),
          //         ),
          //
          //       ],
          //     ),
          //   ),
          // ),

          WeeklyOverview(),
          // WeeklyCalendarWidget(currentDate: _now),
          SizedBox(height: 20),

          Text(
            // 'Thứ năm',
            FormatHelper.formatWeekdayVN(_now),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          Align(
            child: Text(
              // '26/06/2025',
              FormatHelper.formatDate_DD_MM_YYYY(_now),
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            child: Text(
              // '9:00 AM',
              FormatHelper.formatTimeVN(_now),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HelpersColors.itemPrimary,
                fontSize: 17,
              ),
            ),
          ),
          // if(_isCheckedIn) Text('You has been check-in at ${FormatHelper.formatTimeVN(_checkInTime!)}'),
          if (_isCheckedIn) // Hiển thị dữ liệu check in nếu đã check in
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: HelpersColors.itemPrimary.withOpacity(0.8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 20,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'Checked in at: '),
                        TextSpan(
                          text: FormatHelper.formatTimeVN(_checkInTime!),
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    // color: Colors.blue.withOpacity(0.1),
                    border: Border.all(
                      color: _isCheckedIn
                          ? HelpersColors.itemSelected
                          // : Colors.blue.withOpacity(0.1),
                          : HelpersColors.primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    // color: Colors.blue.withOpacity(0.1),
                    border: Border.all(
                      color: _isCheckedIn
                          ? HelpersColors.itemSelected.withOpacity(0.1)
                          // : Colors.blue.withOpacity(0.1),
                          : HelpersColors.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: _isCheckedIn
                        ? HelpersColors.itemSelected.withOpacity(0.3)
                        // : Colors.blue.withOpacity(0.3),
                        // : Colors.blue.withOpacity(0.3),
                        : HelpersColors.primaryColor.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  // Nếu check in thì hiện thông báo dialog, ko thì thôi.
                  if (!_isCheckedIn) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ConfirmCheckInWidget(
                          title: 'Do you want to Check In ?',
                          contentBuilder: () =>
                              'Confirm check in at ${FormatHelper.formatTimeVN(_now)}',
                          onConfirm: () {
                            _startCheckInTimer();
                            setState(() {
                              _checkInTime =
                                  DateTime.now(); // Gán tgian khi checkin
                              _saveCheckInTime(
                                _checkInTime,
                              ); // 👈 Lưu SharedPreferences
                              _isCheckedIn = true;
                            });
                          },
                        );
                      },
                    );
                    // showDialog(
                    //   context: context,
                    //   builder: (context) {
                    //     return CheckStatusFinishDialogWidget(
                    //       title: 'Checked-In',
                    //       time: _checkInTime,
                    //       message: "Have a productive workday!",
                    //       iconColor: Colors.green,
                    //       icon: Icons.check_circle,
                    //     );
                    //   },
                    // );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return MissionDialogWidget(
                          onCheckOut: (report, plan, note) async {
                            // Gửi dữ liệu về server hoặc log ra
                            print('REPORT: $report');
                            print('PLAN: $plan');
                            print('RESULT: $note');
                            final workedDuration =
                                _checkInDuration; // ✅ Lưu trước khi reset lại bộ đếm thời gian
                            final user = ref.read(userProvider);

                            setState(() {
                              _checkOutTime = DateTime.now();
                            });
                            // _savedCheckOutTime(_checkOutTime);

                            // lưu lại trạng thái upload dữ liệu, để biết dữ liệu có được upload thành công hay không
                            final workUploadSuccess = await _workController
                                .completeWork(
                                  context: context,
                                  checkInTime: _checkInTime,
                                  checkOutTime: _checkOutTime,
                                  workTime: workedDuration,
                                  // ✅ Paste lại bộ đếm thời gian
                                  report: report,
                                  plan: plan,
                                  note: note,
                                  userId: user!.id,
                                );
                            if (workUploadSuccess) {
                              _checkInTimer?.cancel(); // ✅ Huỷ timer
                              setState(() {
                                _isCheckedIn = false; // ✅ Cập nhật UI
                                _checkInDuration =
                                    Duration.zero; // ✅ Reset nếu cần
                              });
                              await _savedCheckOutTime(
                                _checkOutTime,
                              ); // ✅ Xử lý xoá SharedPreferences

                              // await _savedCheckOutTime(_checkOutTime);
                              /// Tự động cập nhập lại danh sách - mỗi khi dữ liệu đc thay đổi
                              ref
                                  .read(workProvider.notifier)
                                  .fetchWorks(); // 👈 Load lại danh sách
                              Navigator.of(context).pop();
                              print('_checkInDuration - $_checkInDuration');
                              showDialog(
                                context: context,
                                builder: (_) => CheckStatusFinishDialogWidget(
                                  title: "Checked Out",
                                  time: _checkOutTime,
                                  message: "Well done today!",
                                  iconColor: Colors.red,
                                  icon: Icons.logout,
                                  checkInTime: _checkInTime,
                                  checkOutTime: _checkOutTime,
                                  workDuration: workedDuration,
                                ),
                              );
                              return true;
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Error connection'),
                                    content: Text(
                                      'Unable to save data. \nPlease check your network or try again late',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return false;
                            }

                            // Navigator.of(context).pop();
                            // _stopCheckInTimer();
                          },
                          onLater: () => Navigator.pop(context),
                        );
                      },
                    );
                  }

                  // setState(() {
                  //   if (!_isCheckedIn) {
                  //
                  //     _startCheckInTimer();
                  //     _checkInTime = DateTime.now(); // Gán tgian khi checkin
                  //     _saveCheckInTime(
                  //       _checkInTime,
                  //     ); // 👈 Lưu SharedPreferences
                  //     _isCheckedIn = true;
                  //
                  //     // _startCheckInTimer();          // Không gán trong timer nữa
                  //   } else {
                  //     // _isCheckedIn = false;
                  //
                  //     showDialog(
                  //       context: context,
                  //       builder: (context) {
                  //         return MissionDialogWidget(
                  //           onCheckOut: (report, plan, result) async {
                  //             // Gửi dữ liệu về server hoặc log ra
                  //             print('REPORT: $report');
                  //             print('PLAN: $plan');
                  //             print('RESULT: $result');
                  //             _checkOutTime = DateTime.now();
                  //             final user = ref.read(userProvider);
                  //             // _savedCheckOutTime(_checkOutTime);
                  //
                  //             final workedDuration = _checkInDuration; // ✅ Lưu trước khi reset lại bộ đếm thời gian
                  //
                  //             // lưu lại trạng thái upload dữ liệu, để biết dữ liệu có được upload thành công hay không
                  //             final workUploadSuccess = await _workController.completeWork(
                  //               context: context,
                  //               checkInTime: _checkInTime,
                  //               checkOutTime: _checkOutTime,
                  //               workTime: workedDuration, // ✅ Paste lại bộ đếm thời gian
                  //               report: report,
                  //               plan: plan,
                  //               result: result,
                  //               userId: user!.id,
                  //             );
                  //             if(workUploadSuccess){
                  //               _checkInTimer?.cancel(); // ✅ Huỷ timer
                  //               setState(() {
                  //                 _isCheckedIn = false;         // ✅ Cập nhật UI
                  //                 _checkInDuration = Duration.zero; // ✅ Reset nếu cần
                  //               });
                  //               await _savedCheckOutTime(_checkOutTime); // ✅ Xử lý xoá SharedPreferences
                  //
                  //               // await _savedCheckOutTime(_checkOutTime);
                  //               /// Tự động cập nhập lại danh sách - mỗi khi dữ liệu đc thay đổi
                  //               ref.read(workProvider.notifier).fetchWorks(); // 👈 Load lại danh sách
                  //               Navigator.of(context).pop();
                  //               print('_checkInDuration - $_checkInDuration');
                  //               showDialog(
                  //                 context: context,
                  //                 builder: (_) => CheckStatusFinishDialogWidget(
                  //                   title: "Checked Out",
                  //                   time: _checkOutTime,
                  //                   message: "Well done today!",
                  //                   iconColor: Colors.red,
                  //                   icon: Icons.logout,
                  //                   checkInTime: _checkInTime,
                  //                   checkOutTime: _checkOutTime,
                  //                   workDuration: workedDuration,
                  //                 ),
                  //               );
                  //               return true;
                  //
                  //             }else{
                  //               showDialog(context: context, builder: (context) {
                  //                 return AlertDialog(title: Text('Error connection'),
                  //                 content: Text('Unable to save data. \nPlease check your network or try again late'),
                  //                 actions: [
                  //                   TextButton(onPressed: () {
                  //                     Navigator.of(context).pop();
                  //                   }, child: Text('Close'))
                  //                 ],);
                  //               },);
                  //               return false;
                  //             }
                  //
                  //
                  //             // Navigator.of(context).pop();
                  //             // _stopCheckInTimer();
                  //           },
                  //           onLater: () => Navigator.pop(context),
                  //         );
                  //       },
                  //     );
                  //     // _stopCheckInTimer();
                  //   }
                  // });
                },

                // child: Container(
                //   width: 130,
                //   height: 130,
                //   decoration: BoxDecoration(
                //     color:
                //     _isCheckedIn ?
                //     HelpersColors.itemSelected
                //     :
                //     Colors.blue,
                //     shape: BoxShape.circle,
                //   ),
                //   child:
                //
                //   _isCheckedIn ?
                //   Column(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Spacer(),
                //       Text(
                //         'Check Out',
                //         style: TextStyle(
                //           fontWeight: FontWeight.bold,
                //           color: Colors.white,
                //           fontSize: 20,
                //         ),
                //       ),
                //       Divider(),
                //       Text(
                //         FormatHelper.formatDuration(_checkInDuration),
                //         style: const TextStyle(
                //           color: Colors.white,
                //           fontSize: 14,
                //           fontWeight: FontWeight.bold
                //         ),
                //       ),
                //       Spacer(),
                //     ],
                //   )
                //       :
                //   Center(
                //     child: Text(
                //       'Check In',
                //       style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         color: Colors.white,
                //         fontSize: 20,
                //       ),
                //     ),
                //   )
                //   ,
                // ),i
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isCheckedIn
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            // colors: [HelpersColors.itemSelected, Colors.white],
                            // colors: [HelpersColors.itemSelected, Colors.black.withOpacity(0.9)],
                            colors: [Color(0xFFFF0061), Color(0xFFFEC194)],
                            // colors: [Color(0xFFFC0061), Color(0xFF1FC9FD)],
                          )
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              HelpersColors.primaryColor,
                              HelpersColors.secondaryColor,
                            ],
                          ),
                  ),
                  child: _isCheckedIn
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Spacer(),
                            const Text(
                              'Check Out',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            Divider(thickness: 4),
                            SizedBox(height: 10),
                            Text(
                              FormatHelper.formatDuration(_checkInDuration),
                              style: TextStyle(
                                color: HelpersColors.itemSelected,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                          ],
                        )
                      : const Center(
                          child: Text(
                            'Check In',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

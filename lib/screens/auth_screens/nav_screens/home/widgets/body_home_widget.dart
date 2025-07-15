import 'dart:async';
import 'dart:math';
import 'package:daily_manage_user_app/controller/work_controller.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/home/dialogs/confirm_check_dialog.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/home/widgets/weekly_overview_widget.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:daily_manage_user_app/widgets/dialog_confirm_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/home/dialogs/notification_result_check_dialog_widget.dart';
import 'package:daily_manage_user_app/screens/auth_screens/nav_screens/home/widgets/weekly_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../helpers/format_helper.dart';
import '../../../../../providers/work_provider.dart';
import 'arc_painter_widget.dart';
import '../dialogs/mission_dialog_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class BodyHomeWidget extends ConsumerStatefulWidget {
  const BodyHomeWidget({super.key});

  @override
  _BodyHomeWidgetState createState() => _BodyHomeWidgetState();
}

class _BodyHomeWidgetState extends ConsumerState<BodyHomeWidget>
    with TickerProviderStateMixin {
  WorkController _workController = WorkController();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // time nay k realtime
  // final now = DateTime.now();
  late DateTime _now;
  Timer? _timer;

  bool _isReported = false;
  late String _report;
  late String _plan;
  String? _note;

  // Click check-in
  bool _isCheckedIn = false;
  Duration _checkInDuration = Duration.zero;
  Timer? _checkInTimer;

  //save time check-in
  late DateTime _checkInTime;
  late DateTime _checkOutTime;

  late AnimationController _rotateController;

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

    _rotateController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat();
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

    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    return Container(
      color: Colors.white,
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
          Row(
            children: [
              Lottie.asset('assets/lotties/robot_primary.json', width: 150),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Thêm mainAxisAlignment để căn giữa cả nhóm
                    children: [
                      Text(
                        // 'Thứ năm',
                        FormatHelper.formatWeekdayEN(_now),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        ' - ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      Text(
                        // '26/06/2025',
                        FormatHelper.formatDate_DD_MM_YYYY(_now),
                        style: TextStyle(

                          fontSize: 17,
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                  _isCheckedIn
                      ?
                        // Hiển thị dữ liệu check in nếu đã check in
                        Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: HelpersColors.itemPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            // border: Border.all(
                            //   color: HelpersColors.itemPrimary.withOpacity(0.8),
                            // ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_filled_outlined,
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
                                      text: FormatHelper.formatTimeHH_MM(
                                        _checkInTime,
                                      ),
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
                        )
                      : Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Check In to start work !',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              // Layer 1 - lớn nhất, quay chậm
              AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateController.value * 2 * pi,
                    child: CustomPaint(
                      size: Size(180, 180),
                      painter: ArcPainter(
                        color: _isCheckedIn
                            ? HelpersColors.itemSelected.withOpacity(0.4)
                            : HelpersColors.primaryColor.withOpacity(0.4),
                        strokeWidth: 6,
                        sweepAngle: pi / 2, // 1/4 vòng
                      ),
                    ),
                  );
                },
              ),

              // Layer 2 - nhỏ hơn, quay nhanh hơn
              AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateController.value * 4 * pi, // nhanh gấp đôi
                    child: CustomPaint(
                      size: Size(165, 165),
                      painter: ArcPainter(
                        color: _isCheckedIn
                            ? HelpersColors.itemSelected.withOpacity(0.2)
                            : HelpersColors.primaryColor.withOpacity(0.5),
                        strokeWidth: 5,
                        sweepAngle: pi, // 2/3 vòng
                      ),
                    ),
                  );
                },
              ),

              // Layer 3 - nhỏ nhất, quay ngược
              // Layer 3 - nhỏ nhất, quay ngược
              AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    // Thay đổi tốc độ quay để nó là bội số của 1 vòng tròn (2*pi)
                    // và làm cho nó nhanh hơn một chút để tạo sự khác biệt
                    angle: -_rotateController.value * 6 * pi,
                    // Quay 3 vòng trong 8 giây, ngược chiều
                    child: CustomPaint(
                      size: Size(145, 145),
                      painter: ArcPainter(
                        color: _isCheckedIn
                            ? HelpersColors.itemSelected.withOpacity(
                                0.8,
                              ) // Tăng opacity lên chút cho nó rõ hơn
                            : HelpersColors.primaryColor.withOpacity(0.7),
                        // Tăng opacity lên chút cho nó rõ hơn
                        strokeWidth: 4,
                        // Điều chỉnh sweepAngle để nó là một cung có thể "hiển thị liên tục" khi quay.
                        // Nếu bạn muốn nó trông như một vòng gần hoàn chỉnh:
                        sweepAngle:
                            pi /
                            2, // Gần 2 * pi, có một khe hở nhỏ nhưng liên tục
                        // Hoặc nếu bạn muốn nó là một cung đơn giản nhưng quay mượt:
                        // sweepAngle: pi / 2, // hoặc pi
                      ),
                    ),
                  );
                },
              ),
              InkWell(
                onTap: () async {
                  // Nếu check in thì thực hiện luồng checkin.
                  if (!_isCheckedIn) {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return ConfirmCheckDialog(
                          type: CheckType.checkIn,
                          title: 'Do you want to Check In ?',
                          contentBuilder: () =>
                              'Confirm check in at ${FormatHelper.formatTimeVN(_now)}',
                          onConfirm: () async {
                            _startCheckInTimer();
                            setState(() {
                              _checkInTime =
                                  DateTime.now(); // Gán tgian khi checkin
                              _saveCheckInTime(
                                _checkInTime,
                              ); // 👈 Lưu SharedPreferences
                              _isCheckedIn = true;
                            });

                            showTopNotification(
                              context: context,
                              message: 'You are checked in successfully !',
                              type: NotificationType.success,
                            );

                            await showDialog(
                              context: context,
                              builder: (context) {
                                return NotificationResultCheckDialogWidget(
                                  title: 'Checked-In',
                                  time: _checkInTime,
                                  message: "Have a productive workday!",
                                  iconColor: Colors.green,
                                  icon: Icons.check_circle,
                                  onClose: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return MissionDialogWidget(
                                          onCheckOut: (report, plan, result) async {
                                            _report = report;
                                            _plan = plan;
                                            _note = result;

                                            // Gửi dữ liệu về_iss server hoặc log ra
                                            print('REPORT: $_report');
                                            print('PLAN: $_plan');
                                            print('RESULT: $_note');

                                            Navigator.of(context).pop();

                                            setState(() {
                                              _isReported = true;
                                            });
                                            showTopNotification(context: context, message: 'Job report saved successfully', type: NotificationType.success);
                                            
                                            return true;
                                          },
                                          onLater: () {
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  } else {
                    if (!_isReported) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return MissionDialogWidget(
                            onCheckOut: (report, plan, note) async {
                              print('REPORT: $report');
                              print('PLAN: $plan');
                              print('RESULT: $note');

                              final workedDuration = _checkInDuration;
                              final user = ref.read(userProvider);

                              setState(() {
                                _checkOutTime = DateTime.now();
                              });

                              final workUploadSuccess = await _workController.completeWork(
                                context: context,
                                checkInTime: _checkInTime,
                                checkOutTime: _checkOutTime,
                                workTime: workedDuration,
                                report: report,
                                plan: plan,
                                note: note,
                                userId: user!.id,
                              );

                              if (workUploadSuccess) {
                                _checkInTimer?.cancel();
                                setState(() {
                                  _isCheckedIn = false;
                                  _checkInDuration = Duration.zero;
                                });
                                await _savedCheckOutTime(_checkOutTime);
                                ref.read(workProvider.notifier).fetchWorks();

                                Navigator.pop(context);

                                showTopNotification(
                                  context: context,
                                  message: 'You are check out successfully!',
                                  type: NotificationType.success,
                                );

                                showDialog(
                                  context: context,
                                  builder: (context) => NotificationResultCheckDialogWidget(
                                    title: "Checked Out",
                                    time: _checkOutTime,
                                    message: "Well done today!",
                                    iconColor: Colors.red,
                                    icon: Icons.logout,
                                    checkInTime: _checkInTime,
                                    checkOutTime: _checkOutTime,
                                    workDuration: workedDuration,
                                    onClose: () => (){},
                                    // onClose: () => Navigator.of(context).pop(),
                                  ),
                                );

                                return true;
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Error connection'),
                                    content: Text(
                                      'Unable to save data. \nPlease check your network or try again later.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                                return false;
                              }
                            },
                            onLater: () => Navigator.pop(context),
                          );
                        },
                      );
                    } else {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return ConfirmCheckDialog(
                            type: CheckType.checkOut,
                            title: 'Do you want to Check Out ?',
                            contentBuilder: () =>
                            'Confirm check out at ${FormatHelper.formatTimeVN(_now)}',
                            onConfirm: () {
                              // Navigator.of(context).pop(true);
                            },
                          );
                        },
                      );

                      if (result == true) {
                        final workedDuration = _checkInDuration;
                        final user = ref.read(userProvider);

                        setState(() {
                          _checkOutTime = DateTime.now();
                        });

                        final workUploadSuccess = await _workController.completeWork(
                          context: context,
                          checkInTime: _checkInTime,
                          checkOutTime: _checkOutTime,
                          workTime: workedDuration,
                          report: _report,
                          plan: _plan,
                          note: _note,
                          userId: user!.id,
                        );

                        if (workUploadSuccess) {
                          _checkInTimer?.cancel();
                          setState(() {
                            _isCheckedIn = false;
                            _checkInDuration = Duration.zero;
                          });

                          await _savedCheckOutTime(_checkOutTime);
                          ref.read(workProvider.notifier).fetchWorks();

                          showTopNotification(
                            context: context,
                            message: 'You are check out successfully!',
                            type: NotificationType.success,
                          );

                          showDialog(
                            context: context,
                            builder: (context) => NotificationResultCheckDialogWidget(
                              title: "Checked Out",
                              time: _checkOutTime,
                              message: "Well done today!",
                              iconColor: Colors.red,
                              icon: Icons.logout,
                              checkInTime: _checkInTime,
                              checkOutTime: _checkOutTime,
                              workDuration: workedDuration,
                              // onClose: () => Navigator.of(context).pop(),
                              onClose: () => (){},
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Error connection'),
                              content: Text(
                                'Unable to save data. \nPlease check your network or try again later.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    }


                  }
                },
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    // === THÊM HIỆU ỨNG ĐỔ BÓNG TẠI ĐÂY ===
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        // Màu của bóng (đen, độ trong suốt 30%)
                        spreadRadius: 3,
                        // Độ lan rộng của bóng (làm bóng lớn hơn)
                        blurRadius: 10,
                        // Độ mờ của bóng (làm bóng mềm hơn)
                        offset: Offset(
                          0,
                          5,
                        ), // Vị trí của bóng (x=0, y=5px xuống dưới)
                      ),
                    ],

                    shape: BoxShape.circle,
                    gradient: _isCheckedIn
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            // colors: [HelpersColors.itemSelected, Colors.white],
                            // colors: [HelpersColors.itemSelected, Colors.black.withOpacity(0.9)],
                            // colors: [Color(0xFFFF0061), Color(0xFFFEC194)],
                            colors: [Colors.white, Colors.white],
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
                            Text(
                              'Check Out',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: HelpersColors.itemSelected,
                                fontSize: 16,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                vertical: 5,
                                horizontal: 50,
                              ),
                              child: Divider(thickness: 2),
                            ),
                            // SizedBox(height: 10),
                            Text(
                              FormatHelper.formatDuration(_checkInDuration),
                              style: TextStyle(
                                color: HelpersColors.itemSelected,
                                fontSize: 13,
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
          SizedBox(height: 10),

          if(!_isReported && _isCheckedIn)

            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MissionDialogWidget(
                      onCheckOut: (report, plan, result) async {
                        _report = report;
                        _plan = plan;
                        _note = result;

                        // Gửi dữ liệu về_iss server hoặc log ra
                        print('REPORT: $_report');
                        print('PLAN: $_plan');
                        print('RESULT: $_note');

                        Navigator.of(context).pop();

                        setState(() {
                          _isReported = true;
                        });
                        showTopNotification(context: context, message: 'Job report saved successfully', type: NotificationType.success);

                        return true;
                      },
                      onLater: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5), // màu bóng (mờ)
                      blurRadius: 8, // độ mờ (càng lớn càng mờ)
                      offset: Offset(4, 4), // vị trí bóng (x, y)
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.document_scanner_rounded,
                      size: 20,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Work report!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if(_isReported && _isCheckedIn)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF), // xanh dương nhạt
                borderRadius: BorderRadius.circular(12),
              ),child:
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.book_outlined, color: Color(0xFF1976D2)), // xanh dương đậm
                const SizedBox(width: 10),
                Text(
                  'You have reported your work',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0D47A1), // xanh dương đậm hơn
                  ),
                ),
                SizedBox(width: 20,),
                const Icon(Icons.check_circle, color: Color(0xFF2196F3), size: 22), // xanh dương
              ],
            ),

            )


        ],
      ),
    );
  }
}

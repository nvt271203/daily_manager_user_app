import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:flutter/material.dart';

class MissionDialogWidget extends StatefulWidget {
  // final void Function(String report, String plan, String result) onCheckOut;
  // phải sử dụng Future vì nó lắng nghe call back. chờ sau khi upload như nào thì tiếp tục set isLoading
  final Future<bool> Function(String report, String plan, String result)
  onCheckOut;

  final VoidCallback onLater;

  const MissionDialogWidget({
    super.key,
    required this.onCheckOut,
    required this.onLater,
  });

  @override
  State<MissionDialogWidget> createState() => _MissionDialogWidgetState();
}

class _MissionDialogWidgetState extends State<MissionDialogWidget> {
  final TextEditingController reportController = TextEditingController();
  final TextEditingController planController = TextEditingController();
  final TextEditingController resultController = TextEditingController();
  bool isLoadingCheckout = false;

  String? _reportError;
  String? _planError;
  String? _resultError;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mission',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMissionField(
                icon: Icons.assignment,
                title: 'Report',
                label: "* What did you do yesterday?",
                hint: "Write what you did yesterday, including tasks and results",
                color: Colors.blue,
                controller: reportController,
                errorText: _reportError,
              ),
              const SizedBox(height: 12),
              _buildMissionField(
                icon: Icons.event_note,
                title: 'Plan',
                label: "* What do you plan to do today?",
                hint: "Write your plan for today, including key goals or tasks.",
                color: Colors.blue,
                controller: planController,
                errorText: _planError,
              ),
              const SizedBox(height: 12),
              _buildMissionField(
                icon: Icons.fact_check,
                title: 'Note',
                label: "Do you need any help today?",
                hint: "Write if you need any help, support, or guidance today",
                color: Colors.blue,
                controller: resultController,
                errorText: null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: widget.onLater,
                      child: const Text(
                        'Later',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final report = reportController.text.trim();
                        final plan = planController.text.trim();
                        final result = resultController.text.trim();

                        setState(() {
                          _reportError = report.isEmpty
                              ? "Please enter your report"
                              : null;
                          _planError = plan.isEmpty
                              ? "Please enter your plan"
                              : null;
                          // _resultError = result.isEmpty
                          //     ? "Please enter your result"
                          //     : null;
                        });

                        if (_reportError == null &&
                            _planError == null &&
                            _resultError == null) {
                          // Navigator.of(context).pop();
                          setState(() {
                            isLoadingCheckout = true;
                          });
                          // Chờ quá trình call back
                          final success = await widget.onCheckOut(
                            report,
                            plan,
                            result,
                          );

                          if (success) {
                            // if (context.mounted) Navigator.of(context).pop();
                          }

                          setState(() {
                            isLoadingCheckout = false;
                          });
                        }
                      },
                      child: isLoadingCheckout
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Check Out',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionField({
    required IconData icon,
    required String title,
    required String label,
    required String hint,
    required Color color,
    required TextEditingController controller,
    required String? errorText,
  }) {
    return Stack(
      children: [
        Container(
          height: 170,
          margin: const EdgeInsets.only(left: 20, top: 20),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 55),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize:
                            13, // 👈 Điều chỉnh tại đây (hoặc 12 nếu bạn muốn nhỏ hơn nữa)
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(color: Colors.blueGrey),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),

                        helperText: errorText != null ? '⚠ $errorText' : null,
                        helperStyle: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: errorText != null
                                ? Colors.redAccent
                                : Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: errorText != null
                                ? Colors.redAccent
                                : HelpersColors.itemPrimary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: errorText != null
                                ? Colors.redAccent
                                : color.withOpacity(0.5),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: HelpersColors.itemTextField,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

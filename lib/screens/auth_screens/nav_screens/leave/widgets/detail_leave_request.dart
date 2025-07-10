import 'package:flutter/material.dart';
import '../../../../../helpers/format_helper.dart';
import '../../../../../helpers/tools_colors.dart';
import '../../../../../models/leave.dart';

class DetailLeaveRequest extends StatelessWidget {
  final Leave leave;
  const DetailLeaveRequest({super.key, required this.leave});

  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
  Color getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Approved':
        return Color(0xFFC9E4D6);

      case 'Rejected':
        return Color(0xFFFFC0CB);
      default:
        return Color(0xFFFFFAB3);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.timelapse;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Request Details'),
        centerTitle: true,
        backgroundColor: HelpersColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header status card
          Card(
            color: getStatusBackgroundColor(leave.status), // 👉 thêm dòng này
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: Icon(
                getStatusIcon(leave.status),
                size: 40,
                color: getStatusColor(leave.status),
              ),
              title: Text(
                'Status: ${leave.status}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getStatusColor(leave.status),
                ),
              ),
              subtitle: Text(
                'Requested on ${FormatHelper.formatDate_DD_MM_YYYY(leave.dateCreated)} at ${FormatHelper.formatTimeHH_MM(leave.dateCreated)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),


          const SizedBox(height: 16),

          _buildInfoCard(
            icon: Icons.category,
            title: 'Leave Type',
            content: leave.leaveType,
          ),
          _buildInfoCard(
            icon: Icons.access_time,
            title: 'Time Type',
            content: leave.leaveTimeType,
          ),
          _buildInfoCard(
            icon: Icons.today,
            title: 'Start Date',
            content:
            '${FormatHelper.formatDate_DD_MM_YYYY(leave.startDate)} (${FormatHelper.formatTimeHH_MM(leave.startDate)})',
          ),
          _buildInfoCard(
            icon: Icons.event_available,
            title: 'End Date',
            content:
            '${FormatHelper.formatDate_DD_MM_YYYY(leave.endDate)} (${FormatHelper.formatTimeHH_MM(leave.endDate)})',
          ),
          _buildInfoCard(
            icon: Icons.note_alt,
            title: 'Reason',
            content: leave.reason,
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    bool isMultiline = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16), // giảm padding cho gọn
        child: Row(
          crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: HelpersColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12), // hoặc 20 nếu muốn tròn hơn
              ),
              child: Icon(
                icon,
                size: 22,
                color: HelpersColors.primaryColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


}

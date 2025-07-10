import 'package:intl/intl.dart'; // Thêm thư viện định dạng số

class FormatHelper {

  /// Định dạng tiền VND: 1,000 đ
  static String formatCurrency(int amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return "${formatter.format(amount)} đ";
  }
  /// Định dạng ngày theo dd/MM/yyyy
  static String formatDate_DD_MM_YYYY (DateTime birthday){
    return DateFormat('dd/MM/yyyy').format(birthday);
  }
  /// Lấy giờ hiện tại theo múi giờ Việt Nam (UTC+7), định dạng HH:mm:ss
  static String formatTimeVN(DateTime dateTime) {
    final nowVN = dateTime.toUtc().add(Duration(hours: 7));
    return DateFormat('HH:mm:ss').format(nowVN);
  }
  static String formatTimeHH_MM(DateTime dateTime) {
    final nowVN = dateTime.toUtc().add(Duration(hours: 7));
    return DateFormat('hh:mm a').format(nowVN);
  }

  /// Lấy thứ hiện tại theo tiếng Việt
  static String formatWeekdayVN(DateTime dateTime) {
    final nowVN = dateTime.toUtc().add(Duration(hours: 7));
    return DateFormat.EEEE('vi_VN').format(nowVN); // e.g. Thứ Năm
  }
  //Format thời gian (giờ:phút:giây):
  static String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}';
  }


}
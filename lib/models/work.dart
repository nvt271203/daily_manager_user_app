import 'dart:async';
import 'dart:convert';

class Work {
  final String id;
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final Duration workTime;
  final String report;
  final String plan;
  final String note;
  final String userId;

  Work({required this.id, required this.checkInTime, required this.checkOutTime, required this.workTime, required this.report, required this.plan, this.note='Nothing', required this.userId});


  factory Work.fromMap(Map<String, dynamic> json) {
    return Work(id: json["_id"],
      //PHải có toLocal để nó convert từ giờ UTC về giờ địa phương
      checkInTime: DateTime.parse(json["checkInTime"]).toLocal(),
      checkOutTime: DateTime.parse(json["checkOutTime"]).toLocal(),
      // Dùng vầy tgian lưu bị về 0 - sẽ lưu về tổng số giây
      // workTime: DateTime.parse(json["workTime"]).difference(DateTime.utc(1970, 1, 1)),
      workTime: Duration(seconds: json["workTime"]),
      report: json["report"],
      plan: json["plan"],
      note: json["note"] ?? 'Nothingg',
      userId: json["userId"],);
  }

  factory Work.fromJson(String json) => Work.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
    // .toIso8601String() - sẽ bị trừ lui 7 tiếng;
      // "checkInTime": this.checkInTime.toIso8601String(),
      // "checkOutTime": this.checkOutTime.toIso8601String(),
      "checkInTime": this.checkInTime.toUtc().toIso8601String(), // 👈 thêm .toUtc()
      "checkOutTime": this.checkOutTime.toUtc().toIso8601String(), // 👈 thêm .toUtc()
      // Dùng vầy tgian lưu bị về 0
      // "workTime": this.workTime.inSeconds,
      "workTime": this.workTime.inSeconds,
      "report": this.report,
      "plan": this.plan,
      "note": this.note,
      "userId": this.userId,
    };
  }
  String toJson() => jsonEncode(toMap());
}
import 'dart:convert';

import 'package:daily_manage_user_app/services/manage_http_response.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;

import '../global_variables.dart';
import '../models/work.dart';

class WorkController {
  Future<bool> completeWork({
    required BuildContext context,
    required DateTime checkInTime,
    required DateTime checkOutTime,
    required Duration workTime,
    required String report,
    required String plan,
    required String note,
    required String userId,
  }) async {
    Work work = Work(
      id: '',
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      workTime: workTime,
      report: report,
      plan: plan,
      note: note.trim().isEmpty ? 'Nothing' : note.trim(), // 👈 xử lý tại đây,
      userId: userId,
    );
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/work'),
        body: work.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print('response - ${response.body.toString()}');
      // trả về true nếu upload dữ liệu thành công - nếu ko check mã trạng thái mà return thẳng true ở else thì dẫn đến dữ liệu upload thất bại nó cũng trả về true
      if(response.statusCode == 200 || response.statusCode == 201){
        manageHttpResponse(response, context, () {
          showSnackBar(context, 'Checkout success');
        },);
        return true;
      }else{
        return false;
      }

      // manageHttpResponse(response, context, () {
      //   showSnackBar(context, 'upload success');
      // });
      return true; // ✅ Trả về thành công
    } catch (e) {
      print('Error request-response auth work: $e');
      return false; // ✅ Trả về thất bại
    }
  }

  Future<List<Work>> loadWorkByUser({required String userId}) async{
    try{
      http.Response response = await http.get(Uri.parse('$uri/api/work/$userId'),
        headers: <String, String>{
          'Content-Type':'application/json; charset=UTF-8'
        }
      );
      print('response - ${response.body.toString()}');
      if(response.statusCode == 200){
        List<dynamic> works = jsonDecode(response.body);
        if(works.isNotEmpty){
          return works.map((work) => Work.fromMap(work)).toList();
        }else{
          print('subcategories not found');
          return [];
        }
      } else if(response.statusCode == 404){
        print('subcategories not found');
        return [];

      } else{
        throw Exception('Failed to load categories');
        return [];

      }

    }catch(e){
      print('Error request-response auth loadWorkByUser: $e');
      return [];
    }
  }
}

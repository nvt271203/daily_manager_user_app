import 'package:daily_manage_user_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart'; // nhớ import nếu chưa có

class HeaderHomeWidget extends ConsumerWidget {
  const HeaderHomeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Màu bạn muốn
        statusBarIconBrightness: Brightness.dark, // Icon màu trắng
      ),
    );

    final user = ref.watch(userProvider);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1652FF), Color(0xFFAB64FF)],
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.all(Radius.circular(50)),
              child: user?.image == null || user!.image.isEmpty
                  ? Image.asset(
                      user?.sex == 'Male'
                          ? 'assets/images/avatar_boy_default.jpg'
                          : 'assets/images/avatar_girl_default.jpg',
                      width: 50,
                      height: 50,
                    )
                  : Image.network(user.image, width: 50, height: 50),
            ),
          ),
          SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'Anonymous',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
              // Text(
              //   'Hello, ${user?.fullName ?? 'Anonymous'}',
              //   style: TextStyle(color: Colors.white),
              // ),
              Text(
                '${user?.email ?? 'nva@gmail.com'}',
                style: TextStyle(color: Colors.white.withOpacity(0.7),fontStyle: FontStyle.italic),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:radioquiz/core/constants/app_constants.dart';
import 'package:radioquiz/core/constants/ui_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = UIConstants().screenWidth * 0.6; // 按鈕寬度為螢幕 60%

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: UIConstants().screenWidth * 0.2,
        leading: SvgPicture.asset(AppConstants.iconPath),
        title: const Text(
          "Radio Quiz",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/quiz', arguments: 'level1');
                },
                child: const Text("Level 1",
                    style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16), // 增加間距
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/quiz', arguments: 'level2');
                },
                child: const Text("Level 2",
                    style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: buttonWidth,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/quiz', arguments: 'level3');
                },
                child: const Text("Level 3",
                    style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_service/src/constants/colors.dart';
import 'package:smart_service/src/constants/sizes.dart';
import 'package:smart_service/src/utils/helpers/helper_function.dart';
import 'package:smart_service/src/utils/texts/text_custom.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextCustom(
          TheText: "Paramètre",
          TheTextSize: 14,
          TheTextFontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: tFormHeight),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tSombreColor
                      : ColorApp.tBlackColor,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      TextCustom(
                        TheText: 'Change de mode',
                        TheTextSize: 13,
                        TheTextFontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        Get.changeTheme(
                          Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
                        );
                      });
                    },
                    icon: Icon(
                      isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:smart_service/src/constants/colors.dart';
import 'package:smart_service/src/constants/sizes.dart';
import 'package:smart_service/src/utils/texts/text_custom.dart';
import 'package:flutter/material.dart';

class ButtonCustom extends StatelessWidget {
  const ButtonCustom({
    required this.buttonBackgroundColor,
    required this.onPressed,
    required this.text,
    required this.textSize,
    this.buttonWith = double.infinity,
    this.buttonRaduis = 5,
    this.buttonPaddingVertical = tButtonHeight,
    super.key,
  });

  final Color buttonBackgroundColor;
  final void Function()? onPressed;
  final String text;
  final double textSize;
  final double buttonWith;
  final double buttonRaduis;
  final double buttonPaddingVertical;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWith,
      child: ElevatedButton(
        onPressed: onPressed,
        child: TextCustom(
          TheText: text,
          TheTextSize: textSize,
          TheTextFontWeight: FontWeight.bold,
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRaduis)),
          foregroundColor: ColorApp.tWhiteColor,
          backgroundColor: ColorApp.tPrimaryColor,
          side: BorderSide(color: buttonBackgroundColor),
          padding: EdgeInsets.symmetric(vertical: tButtonHeight),
        ),
      ),
    );
  }
}

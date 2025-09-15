import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';

class TextCustom extends StatelessWidget {
  const TextCustom({
    required this.TheText,
    required this.TheTextSize,
    this.TheTextColor,
    this.TheTextFontWeight,
    this.TheTextFontFamily,
    this.TheTextMaxLines = 1,
    this.TheTextAlign,
    super.key,
  });

  final String TheText;
  final String? TheTextFontFamily;
  final double TheTextSize;
  final Color? TheTextColor;
  final FontWeight? TheTextFontWeight;
  final int? TheTextMaxLines;
  final TextAlign? TheTextAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      TheText,
      maxLines: TheTextMaxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      textAlign: TheTextAlign,
      style: GoogleFonts.urbanist(
         fontWeight: TheTextFontWeight,
        fontSize: TheTextSize,
        color: TheTextColor,
      ),
    );
  }
}

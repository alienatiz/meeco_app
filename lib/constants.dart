import 'package:flutter/material.dart';

const Map<String, Color> categoryColors = {};

const primaryColorLight = Color(0xFF505C84);
const primaryColorDark = Color(0xFF505C84);
const secondaryColor = Color(0xFF686CAC);
const secondaryColorDark = Color(0xFF686CAC);
const voteColorLight = Color(0xFFFA7470);
const voteColorDark = Color(0xFFFA7470);

const bgLight = Color(0xFFFFFFFF);
const bgDark = Color(0xFF17181B);

const bgOverlayLight = Color(0xFFEBEBEB);
const bgOverlayDark = Color(0xFF111111);

const bgTextFieldLight = Colors.white30;
const bgTextFieldDark = Colors.white30;

const textLight = Color(0xFF000000);
const textDark = Color(0xFFFFFFFF);

const textOnPrimary = Color(0xFFFFFFFF);

const textInfoLight = Color(0xFF666666);
const textInfoDark = Color(0xFF999999);

appBarTextStyle(isDark) => TextStyle(
      color: isDark ? textDark : textLight,
      fontWeight: FontWeight.w700,
      fontSize: 20,
    );

headlineTextStyle(isDark) => TextStyle(
      fontSize: 24,
      color: isDark ? textDark : textLight,
      fontWeight: FontWeight.w700,
    );

boardItemTitleTextStyle(isDark) => TextStyle(
      fontSize: 18,
      color: isDark ? textDark : textLight,
      fontWeight: FontWeight.w600,
    );

bodyTextStyle(isDark) => TextStyle(
      fontSize: 16,
      color: isDark ? textDark : textLight,
      fontWeight: FontWeight.normal,
    );

infoTextStyle(isDark) => TextStyle(
      fontSize: 15,
      color: isDark ? textInfoDark : textInfoLight,
      fontWeight: FontWeight.normal,
    );

customModalBottomSheet({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) =>
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      )),
      context: context,
      builder: builder,
    );

ThemeData generateTheme({isDark = false}) {
  return ThemeData(
    primaryColor: isDark ? primaryColorDark : primaryColorLight,
    scaffoldBackgroundColor: isDark ? bgDark : bgLight,
    dividerColor: isDark ? textInfoDark : textInfoLight,
    iconTheme: IconThemeData(color: isDark ? textDark : textLight),
    appBarTheme: AppBarTheme(
      actionsIconTheme: IconThemeData(color: isDark ? textDark : textLight),
      color: isDark ? bgOverlayDark : bgOverlayLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: isDark ? textDark : textLight),
      titleTextStyle: appBarTextStyle(isDark),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: isDark ? bgOverlayDark : bgOverlayLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? bgOverlayDark : bgOverlayLight,
      selectedItemColor: isDark ? primaryColorDark : primaryColorLight,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    textTheme: TextTheme(
      headline5: headlineTextStyle(isDark),
      headline6: boardItemTitleTextStyle(isDark),
      bodyText1: bodyTextStyle(isDark),
      caption: infoTextStyle(isDark),
    ),
  );
}

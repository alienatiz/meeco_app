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
      fontFamily: 'SUIT',
    );

headlineTextStyle(isDark) => TextStyle(
      fontSize: 24,
      color: isDark ? textDark : textLight,
      fontWeight: FontWeight.w700,
    );

boardItemTitleTextStyle(isDark) => TextStyle(
      fontSize: 18,
      color: isDark ? textDark : textLight,
      fontWeight: FontWeight.w800,
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
    fontFamily: 'SUIT',
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

const categoryColor = {
  '미니': Color(0xFFA9D6FF),
  '소식': Color(0xFFADFED4),
  '음향': Color(0xFFEDB172),
  '리뷰': Color(0xFFFDA7D3),
  '대형': Color(0xFF7DE350),
  '자유': Color(0xFFEFEFF0),
  '사진': Color(0xFFCBD0FE),
  '익명': Color(0xFFC3C4C4),
  '유머': Color(0xFFFDEFCC),
  '장터': Color(0xFFFDC4B7),
  '특가': Color(0xFF89B1BA),
  '홍보': Color(0xFF62D3EC),
  '공지': secondaryColor,
};

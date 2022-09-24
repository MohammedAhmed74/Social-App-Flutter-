import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:social_app/shared/styles/colors.dart';

ThemeData lightTheme = ThemeData(
    textTheme: const TextTheme(
        bodyText1: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16),
        bodyText2: TextStyle(
            color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 14)),
    primarySwatch: defaultColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
        actionsIconTheme: IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(246, 255, 255, 255),
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: defaultColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: defaultColor,
    ));

ThemeData darkTheme = ThemeData(
    textTheme: const TextTheme(
        bodyText1: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
    primarySwatch: defaultColor,
    scaffoldBackgroundColor: HexColor('#181818'),
    appBarTheme: AppBarTheme(
        actionsIconTheme: const IconThemeData(
          color: Colors.white,
          size: 30,
        ),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: HexColor('#181818'),
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: const Color(0x474747),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: HexColor('#181818'),
        unselectedItemColor: Colors.grey,
        selectedItemColor: defaultColor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: defaultColor,
    ));

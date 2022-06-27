import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:manycooks/auth/blocs/bookmark_bloc.dart';
import 'package:manycooks/auth/blocs/data_bloc.dart';
import 'package:manycooks/auth/blocs/internet_bloc.dart';
import 'package:manycooks/auth/blocs/sign_in_bloc.dart';
import 'package:manycooks/auth/blocs/userdata_bloc.dart';
import 'package:manycooks/auth/signIn.dart';
import 'package:manycooks/kitchen/kitchen_home.dart';
import 'package:manycooks/state_manager.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: Color.fromRGBO(147, 196, 125, .1),
      100: Color.fromRGBO(147, 196, 125, .2),
      200: Color.fromRGBO(147, 196, 125, .3),
      300: Color.fromRGBO(147, 196, 125, .4),
      400: Color.fromRGBO(147, 196, 125, .5),
      500: Color.fromRGBO(147, 196, 125, .6),
      600: Color.fromRGBO(147, 196, 125, .7),
      700: Color.fromRGBO(147, 196, 125, .8),
      800: Color.fromRGBO(147, 196, 125, .9),
      900: Color.fromRGBO(147, 196, 125, 1),
    };
    MaterialColor colorCustom = MaterialColor(0xFFF0B432, color);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<DataBloc>(
            create: (context) => DataBloc(),
          ),
          ChangeNotifierProvider<SignInBloc>(
            create: (context) => SignInBloc(),
          ),
          ChangeNotifierProvider<UserBloc>(
            create: (context) => UserBloc(),
          ),
          ChangeNotifierProvider<BookmarkBloc>(
            create: (context) => BookmarkBloc(),
          ),
          ChangeNotifierProvider<InternetBloc>(
            create: (context) => InternetBloc(),
          ),
          ChangeNotifierProvider<EditorProvider>(
            create: (context) => EditorProvider(),
          ),
        ],
        child: MaterialApp(
            title: 'Many Cooks',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: colorCustom,
              fontFamily: 'Nunito',
              brightness: Brightness.dark,
              appBarTheme: AppBarTheme(
                brightness: Brightness.dark,
                color: colorCustom.shade300,
                textTheme: TextTheme(
                    headline6: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600)),
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
              ),
              textTheme: TextTheme(
                  headline6: TextStyle(
                color: Colors.black,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              )),
            ),
            home: MyApp1()));
  }
}

class MyApp1 extends StatelessWidget {
  const MyApp1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    return sb.isSignedIn == false && sb.guestUser == false
        ? SignInPage()
        : KitchenHomePage();
  }
}

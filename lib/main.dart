import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/Layout/SocialLayout/socialLayout.dart';
import 'package:social_app/modules/Login/cubit/cubit.dart';
import 'package:social_app/modules/Login/cubit/states.dart';
import 'package:social_app/modules/Login/loginScreen.dart';
import 'package:social_app/shared/bloc_observer.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';
import 'package:social_app/shared/network/cacheHelper.dart';
import 'package:social_app/shared/styles/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  print(CacheHelper.getValue(key: 'uId'));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SocialCubit()..getPosts(),
        ),
        BlocProvider(
          create: (context) => SocialLoginCubit(),
        ),
      ],
      child: BlocConsumer<SocialLoginCubit, SocialLoginStates>(
        listener: (context, state) {},
        builder: (context, state) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: lightTheme,
          // theme: CacheHelper.getValue(key: 'lightMode') == true? lightTheme : darkTheme,
          home: CacheHelper.getValue(key: 'uId') == null
              ? LoginScreen()
              : SocialLayout(),
        ),
      ),
    );
  }
}

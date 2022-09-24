import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:social_app/Layout/SocialLayout/socialLayout.dart';
import 'package:social_app/modules/Login/cubit/cubit.dart';
import 'package:social_app/modules/Login/cubit/states.dart';
import 'package:social_app/modules/Login/registerScreen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/network/cacheHelper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SocialLoginCubit(),
      child: BlocConsumer<SocialLoginCubit, SocialLoginStates>(
        listener: (context, state) {
          if (state is SuccessLoginState) {
            print("Navigate to LayOUttttttttttttttttttttttttttt");

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SocialLayout(
                          login: true,
                        )));
          } else if (state is ErrorLoginState) {
            Fluttertoast.showToast(
                msg: state.error.toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        },
        builder: (context, state) {
          SocialLoginCubit cubit = SocialLoginCubit.get(context);
          return SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            width: 280,
                            height: 160,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'lib/assets/images/welcome_cats.png',
                                ),
                                fit: BoxFit.fill,
                              ),
                            )),
                        const SizedBox(
                          height: 40,
                        ),
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Text(
                            'Login',
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .copyWith(
                                    color: Colors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Login now to communicate with your frindes',
                          style: TextStyle(fontSize: 14, color: Colors.black45),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: HexColor('639CFF').withOpacity(0.3),
                                    blurRadius: 20.0,
                                    offset: Offset(0, 10))
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                defaultFormField(
                                    txtcon1: emailCtrl,
                                    lable: 'Email',
                                    type: TextInputType.emailAddress,
                                    color: Colors.black,
                                    warningMsg: 'Email can\'t be empty',
                                    pre: const Icon(
                                      Icons.email_outlined,
                                      size: 20,
                                    )),
                                const SizedBox(
                                  height: 0,
                                ),
                                defaultFormField(
                                  txtcon1: passwordCtrl,
                                  lable: 'Password',
                                  type: TextInputType.visiblePassword,
                                  color: Colors.black,
                                  pre: const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                  ),
                                  onFieldSubmitted: (text) {
                                    if (formKey.currentState!.validate()) {
                                      cubit.userLogin(
                                        email: emailCtrl.text,
                                        password: passwordCtrl.text,
                                      );
                                    }
                                  },
                                  warningMsg: 'Password is too short or empty',
                                  suff: SocialLoginCubit.get(context)
                                      .passwordSuff,
                                  isPassword:
                                      SocialLoginCubit.get(context).isPassword,
                                  suffOnPressed: () {
                                    SocialLoginCubit.get(context)
                                        .showPassword();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ConditionalBuilder(
                          condition: state is! LoadingLoginState,
                          builder: (context) => defaultButton(
                              text: 'LOGIN',
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  cubit.userLogin(
                                    email: emailCtrl.text,
                                    password: passwordCtrl.text,
                                  );
                                }
                              }),
                          fallback: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: Colors.black, fontSize: 15),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RegisterScreen()));
                                },
                                child: Text(
                                  'REGISTER',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: HexColor('639CFF'),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15),
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Align(
                          alignment: AlignmentDirectional.bottomStart,
                          child: Container(
                              width: 150,
                              height: 150,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'lib/assets/images/with_love.png',
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

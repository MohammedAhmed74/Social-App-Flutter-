import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:social_app/Layout/SocialLayout/socialLayout.dart';
import 'package:social_app/modules/Login/cubit/cubit.dart';
import 'package:social_app/modules/Login/cubit/states.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/network/cacheHelper.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var emailCtrl = TextEditingController();
  var phoneCtrl = TextEditingController();
  var nameCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SocialLoginCubit(),
      child: BlocConsumer<SocialLoginCubit, SocialLoginStates>(
        listener: (context, state) {
          if (state is SuccessRegisterState) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SocialLayout(
                          login: true,
                        )));
          } else if (state is ErrorRegisterState) {
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Text(
                            'Register',
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
                          'Register now to communicate with your frindes',
                          style: TextStyle(fontSize: 14, color: Colors.black45),
                        ),
                        const SizedBox(
                          height: 10,
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
                                    txtcon1: nameCtrl,
                                    lable: 'User Name',
                                    type: TextInputType.name,
                                    color: Colors.black,
                                    warningMsg: 'User Name can\'t be empty',
                                    pre: const Icon(
                                      Icons.person_outline,
                                      size: 20,
                                    )),
                                const SizedBox(
                                  height: 0,
                                ),
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
                                      cubit.userRegister(
                                        name: nameCtrl.text,
                                        phone: phoneCtrl.text,
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
                                const SizedBox(
                                  height: 0,
                                ),
                                defaultFormField(
                                    txtcon1: phoneCtrl,
                                    lable: 'Phone',
                                    type: TextInputType.phone,
                                    color: Colors.black,
                                    warningMsg: 'Phone can\'t be empty',
                                    pre: const Icon(
                                      Icons.phone_enabled_outlined,
                                      size: 20,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ConditionalBuilder(
                          condition: state is! LoadingLoginState,
                          builder: (context) => TextButton(
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                color: HexColor('639CFF'),
                                child: const Center(
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  cubit.userRegister(
                                    name: nameCtrl.text,
                                    phone: phoneCtrl.text,
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

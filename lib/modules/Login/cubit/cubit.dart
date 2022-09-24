import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/modules/Login/cubit/states.dart';
import 'package:social_app/shared/network/cacheHelper.dart';

import '../../../models/Users/userModel.dart';

class SocialLoginCubit extends Cubit<SocialLoginStates> {
  SocialLoginCubit() : super(initialSocialLoginState());
  static SocialLoginCubit get(context) => BlocProvider.of(context);

  bool isPassword = true;
  IconData passwordSuff = Icons.visibility_off_rounded;
  showPassword() {
    isPassword = !isPassword;
    passwordSuff =
        !isPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded;
    emit(ShowPasswordState());
  }

  void userLogin({required String email, required String password}) async {
    print('userLoginnnnnnnnnnnnnnnnnnnnnnn');
    emit(LoadingLoginState());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      print(value.user!.email);
      print('loooooooooooooooooooooooooooooooooooolll');
      CacheHelper.setValue(key: 'uId', value: value.user!.uid);
      print(value.user!.uid);
      print('loooooooooooooooooooooooooooooooooooolll');
      print(CacheHelper.getValue(key: 'uId'));
      print('loooooooooooooooooooooooooooooooooooolll');
      emit(SuccessLoginState());
    }).catchError((error) {
      List<String> Error = [];
      Error = error.toString().split(']');
      emit(ErrorLoginState(Error[1]));
    });
  }

  void userRegister(
      {required String email,
      required String password,
      required String name,
      required String phone}) async {
    emit(LoadingLoginState());
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      UserModel? user;
      user = UserModel(
          email: email, name: name, phone: phone, uId: value.user!.uid);
      CacheHelper.setValue(key: 'uId', value: value.user!.uid);
      FirebaseFirestore.instance
          .collection('Users')
          .doc(value.user!.uid)
          .set(user.toMap())
          .then((value) {
        emit(SuccessRegisterState());
      }).catchError((error) {
        print(error);
        List<String> Error = [];
        Error = error.toString().split(']');
        emit(ErrorRegisterState(Error[1]));
      });
    }).catchError((error) {
      print(error);

      List<String> Error = [];
      Error = error.toString().split(']');
      emit(ErrorRegisterState(Error[1]));
    });
  }
}

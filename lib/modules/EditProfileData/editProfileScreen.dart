import 'dart:io';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';
import 'package:social_app/shared/styles/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late var nameCtrl = TextEditingController();
  late var bioCtrl = TextEditingController();
  late var phoneCtrl = TextEditingController();
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        if (state is SuccessProfileUpdateState) {
          Fluttertoast.showToast(
              msg: 'Profile Updated',
              textColor: Colors.white,
              backgroundColor: Colors.green);
        } else if (state is ErrorProfileUpdateState) {
          Fluttertoast.showToast(
              msg: 'Something went wrong',
              textColor: Colors.white,
              backgroundColor: Colors.red);
        }
      },
      builder: (context, state) {
        return ConditionalBuilder(
          condition: SocialCubit.get(context).user != null,
          fallback: (context) => Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          builder: (context) {
            var cubit = SocialCubit.get(context);
            nameCtrl.text = cubit.user!.name;
            bioCtrl.text = cubit.user!.bio;
            phoneCtrl.text = cubit.user!.phone;
            late File? profileImage;
            late File? coverImage;
            bool updateProfile = false;
            bool updateCover = false;
            if (cubit.profileImage != null) {
              profileImage = cubit.profileImage!;
              updateProfile = true;
            }
            if (cubit.coverImage != null) {
              coverImage = cubit.coverImage!;
              updateCover = true;
            }
            return Form(
              key: formKey,
              child: Scaffold(
                appBar: AppBar(
                    titleSpacing: 0.0,
                    title: Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 16),
                    ),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        updateProfile = false;
                        updateCover = false;
                        profileImage = null;
                        coverImage = null;
                        cubit.profileImage = null;
                        cubit.coverImage = null;
                        cubit.canselEdit();
                        Navigator.pop(context);
                      },
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              print(bioCtrl.text);
                              cubit.EditProfileData(
                                  bio: bioCtrl.text,
                                  name: nameCtrl.text,
                                  phone: phoneCtrl.text);
                            }
                          },
                          child: Text(
                            'Update',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontSize: 16),
                          )),
                      const SizedBox(
                        width: 10,
                      )
                    ]),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (state is LoadingProfileUpdateState)
                          Container(
                              width: double.infinity,
                              height: 4,
                              child: LinearProgressIndicator()),
                        Container(
                          height: 240,
                          child: Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: [
                              Align(
                                alignment: AlignmentDirectional.topCenter,
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Container(
                                      height: 180,
                                      width: double.infinity,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                          image: !updateCover
                                              ? DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      cubit.user!.cover))
                                              : DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image:
                                                      FileImage(coverImage!))),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            Colors.black.withOpacity(0.4),
                                        child: IconButton(
                                          onPressed: () {
                                            cubit.getPhotoFromGallary(
                                                image: 'cover');
                                          },
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                alignment: AlignmentDirectional.bottomEnd,
                                children: [
                                  CircleAvatar(
                                      radius: 64,
                                      backgroundColor: Colors.white,
                                      child: !updateProfile
                                          ? CircleAvatar(
                                              radius: 60,
                                              backgroundImage: NetworkImage(
                                                  cubit.user!.userImage),
                                            )
                                          : CircleAvatar(
                                              radius: 60,
                                              backgroundImage:
                                                  FileImage(profileImage!),
                                            )),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                          Colors.black.withOpacity(0.4),
                                      child: IconButton(
                                        onPressed: () {
                                          cubit.getPhotoFromGallary(
                                              image: 'profile');
                                        },
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 15),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Name',
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(fontSize: 14),
                                      ),
                                      Container(
                                        width: 300,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: TextFormField(
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                22),
                                          ],
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          textAlign: TextAlign.start,
                                          controller: nameCtrl,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Name can\'t be empty';
                                            }
                                          },
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 15),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'BIO',
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(fontSize: 14),
                                      ),
                                      Container(
                                        width: 300,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: TextFormField(
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                100),
                                          ],
                                          textAlign: TextAlign.start,
                                          controller: bioCtrl,
                                          minLines: 1,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 15),
                                    child: Icon(
                                      Icons.phone,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                  Container(
                                    width: 300,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Phone',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(fontSize: 14),
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.phone,
                                          textAlign: TextAlign.start,
                                          controller: phoneCtrl,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                11),
                                          ],
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Phone can\'t be empty';
                                            }
                                          },
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

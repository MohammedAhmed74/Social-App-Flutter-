import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:social_app/modules/UsersProfile/usersProfile.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';
import 'package:social_app/shared/network/cacheHelper.dart';
import 'package:social_app/shared/styles/colors.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

String searchVal = '';

class _SearchScreenState extends State<SearchScreen> {
  var searchCtrl = TextEditingController();
  double searchIconOpacity = 0.4;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        //searchCtrl.notifyListeners((vale)=>{});
      },
      builder: (context, state) {
        return SafeArea(
            child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: CacheHelper.getValue(key: 'lightMode') == false
                    ? darkTextcolor
                    : lightTextColor,
              ),
              onPressed: () {
                searchCtrl.text = '';
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                SearchBarAnimation(
                    textEditingController: searchCtrl,
                    isSearchBoxOnRightSide: true,
                    isOriginalAnimation: false,
                    buttonBorderColour: Colors.black45,
                    buttonIcon: Icons.search,
                    buttonShadowColour:
                        Colors.black.withOpacity(searchIconOpacity),
                    onFieldSubmitted: (String value) {
                      debugPrint('onFieldSubmitted value $value');
                    },
                    onPressButton: (isOpen) {
                      setState(() {});
                      if (isOpen) {
                        searchIconOpacity = 0;
                      } else {
                        searchIconOpacity = 0.4;
                      }
                    },
                    enableKeyboardFocus: true,
                    onChanged: (val) {
                      setState(() {
                        searchVal = searchCtrl.text;
                      });
                    }),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      return (snapshot.connectionState ==
                              ConnectionState.waiting)
                          ? const Center(
                              child: const CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              itemBuilder: (context, index) {
                                var data = snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                                if (searchVal.isEmpty) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          data['name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: CacheHelper.getValue(
                                                          key: 'lightMode') ==
                                                      false
                                                  ? darkTextcolor
                                                  : lightTextColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          data['email'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: CacheHelper.getValue(
                                                          key: 'lightMode') ==
                                                      false
                                                  ? Colors.grey[400]
                                                  : lightTextColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(data['userImage']),
                                          radius: 30,
                                        ),
                                        onTap: () {
                                          SocialCubit.get(context)
                                              .getMyPosts(data['uId']);
                                          SocialCubit.get(context)
                                              .searchForPostsForMe(true);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UsersProfile(
                                                        userUid: data['uId']),
                                              ));
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 15),
                                        child: Container(
                                          color: Colors.grey[300],
                                          height: 0.5,
                                          width: double.maxFinite,
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (data['name']
                                    .toString()
                                    .toLowerCase()
                                    .startsWith(searchVal.toLowerCase())) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          data['name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: CacheHelper.getValue(
                                                          key: 'lightMode') ==
                                                      false
                                                  ? darkTextcolor
                                                  : lightTextColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          data['email'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: CacheHelper.getValue(
                                                          key: 'lightMode') ==
                                                      false
                                                  ? Colors.grey[400]
                                                  : lightTextColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(data['userImage']),
                                          radius: 30,
                                        ),
                                        onTap: () {
                                          SocialCubit.get(context)
                                              .getMyPosts(data['uId']);
                                          SocialCubit.get(context)
                                              .searchForPostsForMe(true);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UsersProfile(
                                                        userUid: data['uId']),
                                              ));
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 15),
                                        child: Container(
                                          color: Colors.grey[300],
                                          height: 0.5,
                                          width: double.maxFinite,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Container();
                                }
                              },
                              itemCount: snapshot.data!.docs.length);
                    },
                  ),
                )
              ],
            ),
          ),
        ));
      },
    );
  }
}

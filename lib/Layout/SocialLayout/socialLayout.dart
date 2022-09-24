import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/modules/EditProfileData/editProfileScreen.dart';
import 'package:social_app/modules/Login/cubit/states.dart';
import 'package:social_app/modules/Search/searchScreen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';
import 'package:page_transition/page_transition.dart';

class SocialLayout extends StatelessWidget {
  SocialLayout({
    Key? key,
    this.login = false,
  }) : super(key: key);
  bool login;
  @override
  Widget build(BuildContext context) {
    if (login) {
      SocialCubit.get(context).user = null;
      SocialCubit.get(context).changeBottomNav(0, context);
      SocialCubit.get(context).getUserData();
      login = false;
    }
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        if (state is SuccessLoginState) {}
      },
      builder: (context, state) {
        var cubit = SocialCubit.get(context);
        return ConditionalBuilder(
            condition: cubit.user != null,
            builder: (context) {
              print(cubit.user!.name);
              return SafeArea(
                child: Scaffold(
                  appBar: AppBar(
                      title: Text(cubit.titles[cubit.currentIndex]),
                      iconTheme: const IconThemeData(color: Colors.black),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: IconButton(
                              onPressed: () {},
                              icon:
                                  const Icon(Icons.notifications_on_outlined)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        child: SearchScreen(),
                                        type: PageTransitionType.size,
                                        alignment: Alignment.topRight));
                              },
                              icon: const Icon(Icons.search_outlined)),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ]),
                  drawer: const NavigationDrawer(),
                  body: cubit.Screens[cubit.currentIndex],
                  floatingActionButton: FloatingActionButton(
                    child: const Icon(
                      Icons.post_add_outlined,
                    ),
                    onPressed: () {
                      cubit.createPostButton(context);
                    },
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  bottomNavigationBar: AnimatedBottomNavigationBar(
                    icons: const [
                      Icons.home_outlined,
                      Icons.chat_outlined,
                      Icons.location_on_outlined,
                      Icons.person_outline
                    ],
                    activeColor: Colors.blue,
                    splashColor: Colors.black,
                    activeIndex: cubit.currentIndex,
                    gapLocation: GapLocation.center,
                    notchSmoothness: NotchSmoothness.softEdge,
                    onTap: (index) {
                      cubit.changeBottomNav(index, context);
                    },
                  ),
                ),
              );
            },
            fallback: (context) {
              cubit.getUserData();
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            });
      },
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHeader(context),
              buildMenuItems(context),
            ],
          ),
        ),
      );
  Widget buildHeader(BuildContext context) => Container(
        color: Colors.amber[100],
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  NetworkImage(SocialCubit.get(context).user!.userImage),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              SocialCubit.get(context).user!.name,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              SocialCubit.get(context).user!.email,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ],
        ),
      );
  Widget buildMenuItems(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
              leading: Icon(
                Icons.dark_mode_outlined,
                size: 26,
              ),
              onTap: () {
                Navigator.pop(context);
                SocialCubit.get(context).changeBottomNav(3, context);
              },
            ),
            ListTile(
              title: Text(
                'Profile',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
              leading: Icon(
                Icons.person_outline,
                size: 26,
              ),
              onTap: () {
                Navigator.pop(context);
                SocialCubit.get(context).changeBottomNav(3, context);
              },
            ),
            ListTile(
              title: Text(
                'Search',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
              leading: Icon(
                Icons.search,
                size: 26,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(),
                    ));
              },
            ),
            ListTile(
              title: Text(
                'Settings',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
              leading: Icon(
                Icons.settings_outlined,
                size: 26,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ));
              },
            ),
          ],
        ),
      );
}

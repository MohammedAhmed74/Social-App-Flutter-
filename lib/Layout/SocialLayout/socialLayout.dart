import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/modules/EditProfileData/editProfileScreen.dart';
import 'package:social_app/modules/Login/cubit/states.dart';
import 'package:social_app/modules/Search/searchScreen.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';
import 'package:page_transition/page_transition.dart';
import 'package:social_app/shared/network/cacheHelper.dart';
import 'package:social_app/shared/styles/colors.dart';

class SocialLayout extends StatefulWidget {
  SocialLayout({
    Key? key,
    this.login = false,
  }) : super(key: key);
  bool login;

  @override
  State<SocialLayout> createState() => _SocialLayoutState();
}

class _SocialLayoutState extends State<SocialLayout> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    if (widget.login) {
      SocialCubit.get(context).user = null;
      SocialCubit.get(context).changeBottomNav(0, context);
      SocialCubit.get(context).getUserData();
      widget.login = false;
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
                  backgroundColor:
                      CacheHelper.getValue(key: 'lightMode') == true
                          ? Colors.white
                          : darkBackground,
                  appBar: AppBar(
                      backgroundColor:
                          CacheHelper.getValue(key: 'lightMode') == true
                              ? Colors.white
                              : darkBackground,
                      title: Text(
                        cubit.titles[cubit.currentIndex],
                        style: TextStyle(
                          color: CacheHelper.getValue(key: 'lightMode') == true
                              ? lightTextColor
                              : darkTextcolor,
                        ),
                      ),
                      iconTheme: IconThemeData(
                        color: CacheHelper.getValue(key: 'lightMode') == true
                            ? lightTextColor
                            : darkTextcolor,
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.notifications_on_outlined,
                                color: CacheHelper.getValue(key: 'lightMode') ==
                                        true
                                    ? lightTextColor
                                    : darkTextcolor,
                              )),
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
                              icon: Icon(
                                Icons.search_outlined,
                                color: CacheHelper.getValue(key: 'lightMode') ==
                                        true
                                    ? lightTextColor
                                    : darkTextcolor,
                              )),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ]),
                  drawer: NavigationDrawer(),
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
                    backgroundColor:
                        CacheHelper.getValue(key: 'lightMode') == false
                            ? darkBackground
                            : Colors.white,
                    icons: const [
                      Icons.home_outlined,
                      Icons.chat_outlined,
                      Icons.location_on_outlined,
                      Icons.person_outline
                    ],
                    activeColor: Colors.blue,
                    splashColor: CacheHelper.getValue(key: 'lightMode') == false
                        ? Colors.white
                        : Colors.black,
                    activeIndex: cubit.currentIndex,
                    inactiveColor:
                        CacheHelper.getValue(key: 'lightMode') == false
                            ? Colors.white
                            : Colors.black,
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
  NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
        width: 300,
        backgroundColor: CacheHelper.getValue(key: 'lightMode') == false
            ? darkBackground
            : Colors.white,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  NetworkImage(SocialCubit.get(context).user!.userImage),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              SocialCubit.get(context).user!.name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              SocialCubit.get(context).user!.email,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ],
        ),
      );
  Widget buildMenuItems(BuildContext context) => Container(
        color: CacheHelper.getValue(key: 'lightMode') == false
            ? darkBackground
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              if (CacheHelper.getValue(key: 'lightMode'))
                ListTile(
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(
                        fontSize: 14,
                        color: CacheHelper.getValue(key: 'lightMode') == true
                            ? lightTextColor
                            : darkTextcolor,
                        fontWeight: FontWeight.w500),
                  ),
                  leading: Icon(
                    Icons.dark_mode_outlined,
                    size: 26,
                    color: CacheHelper.getValue(key: 'lightMode') == false
                        ? Colors.white
                        : Colors.black,
                  ),
                  onTap: () {
                    SocialCubit.get(context).changeLightMode();
                  },
                ),
              if (!CacheHelper.getValue(key: 'lightMode'))
                ListTile(
                  title: Text(
                    'Light Mode',
                    style: TextStyle(
                        fontSize: 14,
                        color: CacheHelper.getValue(key: 'lightMode') == true
                            ? lightTextColor
                            : darkTextcolor,
                        fontWeight: FontWeight.w500),
                  ),
                  leading: Icon(
                    Icons.light_mode_outlined,
                    size: 26,
                    color: CacheHelper.getValue(key: 'lightMode') == false
                        ? Colors.white
                        : Colors.black,
                  ),
                  onTap: () {
                    SocialCubit.get(context).changeLightMode();
                  },
                ),
              ListTile(
                title: Text(
                  'Profile',
                  style: TextStyle(
                      fontSize: 14,
                      color: CacheHelper.getValue(key: 'lightMode') == true
                          ? lightTextColor
                          : darkTextcolor,
                      fontWeight: FontWeight.w500),
                ),
                leading: Icon(
                  Icons.person_outline,
                  size: 26,
                  color: CacheHelper.getValue(key: 'lightMode') == false
                      ? Colors.white
                      : Colors.black,
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
                      color: CacheHelper.getValue(key: 'lightMode') == true
                          ? lightTextColor
                          : darkTextcolor,
                      fontWeight: FontWeight.w500),
                ),
                leading: Icon(
                  Icons.search,
                  size: 26,
                  color: CacheHelper.getValue(key: 'lightMode') == false
                      ? Colors.white
                      : Colors.black,
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
                      color: CacheHelper.getValue(key: 'lightMode') == true
                          ? lightTextColor
                          : darkTextcolor,
                      fontWeight: FontWeight.w500),
                ),
                leading: Icon(
                  Icons.settings_outlined,
                  size: 26,
                  color: CacheHelper.getValue(key: 'lightMode') == false
                      ? Colors.white
                      : Colors.black,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ));
                },
              ),
            ],
          ),
        ),
      );
}

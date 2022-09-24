import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/models/App/postModel.dart';
import 'package:social_app/modules/Chats/openImageScreen.dart';
import 'package:social_app/modules/Comments/commentsScreen.dart';
import 'package:social_app/modules/EditProfileData/editProfileScreen.dart';
import 'package:social_app/modules/Post/postScreen.dart';
import 'package:social_app/shared/components/constants.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class ProfileScreen extends StatelessWidget {
  var emailCtrl = TextEditingController();
  var phoneCtrl = TextEditingController();
  var nameCtrl = TextEditingController();
  Map numberToMonth = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = SocialCubit.get(context);
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: 240,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(SwipeablePageRoute(
                              builder: (BuildContext context) =>
                                  OpenImageScreen(
                                imageUrl: cubit.user!.cover,
                              ),
                            ));
                          },
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(cubit.user!.cover))),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(SwipeablePageRoute(
                            builder: (BuildContext context) => OpenImageScreen(
                              imageUrl: cubit.user!.userImage,
                            ),
                          ));
                        },
                        child: CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                NetworkImage(cubit.user!.userImage),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 300,
                  child: Text(
                    cubit.user!.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Container(
                  width: 300,
                  child: Align(
                    child: Text(
                      cubit.user!.bio,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontSize: 14),
                    ),
                    alignment: AlignmentDirectional.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '100',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                            Text(
                              'Posts',
                              style: Theme.of(context).textTheme.caption,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '74',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                            Text(
                              'Photos',
                              style: Theme.of(context).textTheme.caption,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '1208',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                            Text(
                              'Followers',
                              style: Theme.of(context).textTheme.caption,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '80',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                            Text(
                              'Following',
                              style: Theme.of(context).textTheme.caption,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          const PostScreen())));
                            },
                            child: Text(
                              'Add Posts',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.blue,
                                  ),
                            )),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton(
                          onPressed: () {
                            cubit.errorCoverUpdate = false;
                            cubit.errorProfileUpdate = false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) =>
                                        EditProfileScreen())));
                          },
                          child: Icon(Icons.edit_outlined)),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton(
                          onPressed: () {
                            if (!cubit.signOut) {
                              Fluttertoast.showToast(
                                  msg: 'press again to signOut',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green.withOpacity(1),
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              cubit.doSignOut(true);
                            } else {
                              cubit.logOut(context);
                            }
                          },
                          child: Icon(Icons.logout_outlined)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ConditionalBuilder(
                  condition: cubit.myPosts!.isNotEmpty,
                  builder: (context) {
                    return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: ((context, index) {
                          Timestamp t = cubit.posts[index].time;
                          DateTime time = t.toDate();
                          if (index == cubit.myPosts!.length - 1) {
                            cubit.refreshPostScreen();
                          }
                          return buildHomeItem(
                            context,
                            cubit.myPosts![index],
                            index,
                            time,
                          );
                        }),
                        separatorBuilder: ((context, index) => const SizedBox(
                              height: 13,
                            )),
                        itemCount: cubit.myPosts!.length);
                  },
                  fallback: (context) {
                    if (cubit.noPostsForMe) {
                      Timer(const Duration(seconds: 3), () {
                        cubit.searchForPostsForMe(false);
                      });
                      return Column(
                        children: [
                          SizedBox(
                            height: 100,
                          ),
                          CircularProgressIndicator(),
                        ],
                      );
                    } else {
                      return SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 50,
                              ),
                              Lottie.network(
                                  "https://assets2.lottiefiles.com/packages/lf20_g4wqji2g.json",
                                  height: 120),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                'No posts yet..',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(fontSize: 14),
                              ),
                              const SizedBox(
                                height: 60,
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildHomeItem(
    BuildContext context,
    PostModel post,
    int index,
    DateTime time,
  ) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(SocialCubit.get(context)
                                  .getUserInfo(post.uId, 'image') !=
                              ''
                          ? SocialCubit.get(context)
                              .getUserInfo(post.uId, 'image')
                          : 'https://c.files.bbci.co.uk/10E5A/production/_105901296_male.jpg')),
                ),
                const SizedBox(
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (SocialCubit.get(context)
                                .getUserInfo(post.uId, 'name') ==
                            '')
                          Text(
                            post.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontSize: 15),
                          ),
                        if (SocialCubit.get(context)
                                .getUserInfo(post.uId, 'name') !=
                            '')
                          Text(
                            SocialCubit.get(context)
                                .getUserInfo(post.uId, 'name'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontSize: 15),
                          ),
                        const SizedBox(
                          width: 3,
                        ),
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 8,
                          child: Icon(
                            Icons.check_circle,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      '${numberToMonth[time.month]} ${time.day} at ${time.hour}:${time.minute}',
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                ),
                const Spacer(),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz,
                      size: 22,
                    ))
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              color: Colors.grey,
              height: 0.1,
              width: double.infinity,
            ),
          ),
          if (post.text != '')
            Padding(
              padding: EdgeInsets.only(right: 12, left: 12, top: 10, bottom: 3),
              child: Text(
                post.text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ),
          if (false)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                children: [
                  Container(
                    height: 25,
                    child: MaterialButton(
                      onPressed: () {},
                      minWidth: 1,
                      padding: EdgeInsets.zero,
                      child: Text(
                        '#Flutter',
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            color: Colors.blue, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Container(
                    height: 25,
                    child: MaterialButton(
                      onPressed: () {},
                      minWidth: 1,
                      padding: EdgeInsets.zero,
                      child: Text(
                        '#Flutter',
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            color: Colors.blue, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Container(
                    height: 25,
                    child: MaterialButton(
                      onPressed: () {},
                      minWidth: 1,
                      padding: EdgeInsets.zero,
                      child: Text(
                        '#Flutter',
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            color: Colors.blue, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Container(
                    height: 25,
                    child: MaterialButton(
                      onPressed: () {},
                      minWidth: 1,
                      padding: EdgeInsets.zero,
                      child: Text(
                        '#Flutter',
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            color: Colors.blue, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Container(
                    height: 25,
                    child: MaterialButton(
                      onPressed: () {},
                      minWidth: 1,
                      padding: EdgeInsets.zero,
                      child: Text(
                        '#Flutter_Development',
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            color: Colors.blue, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (post.postImage != '')
            InkWell(
              onTap: () {
                Navigator.of(context).push(SwipeablePageRoute(
                  builder: (BuildContext context) => OpenImageScreen(
                    imageUrl: post.postImage,
                    text: post.text,
                  ),
                ));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: NetworkImage(post.postImage))),
                ),
              ),
            ),
          SizedBox(
            height: 8,
          ),
          if (post.likes_num > 0 || post.comments_num > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 8, bottom: 5),
              child: Row(
                children: [
                  if (post.likes_num > 0)
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            post.likes_num.toString(),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  if (post.comments_num > 0)
                    InkWell(
                      onTap: () {
                        SocialCubit.get(context).comments = [];
                        SocialCubit.get(context).searchComments(true);
                        SocialCubit.get(context).getComments(post.postId);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return CommentsScreen(
                            postIndex: index,
                            postId: post.postId,
                            uId: SocialCubit.get(context).user!.uId,
                          );
                        }));
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_outlined,
                            color: Colors.amber,
                            size: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Text(
                              post.comments_num.toString(),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          Text(
                            'comments',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              color: Colors.grey,
              height: 0.1,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: InkWell(
                    onTap: () {
                      SocialCubit.get(context).comments = [];
                      SocialCubit.get(context).searchComments(true);
                      SocialCubit.get(context).getComments(post.postId);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CommentsScreen(
                          postIndex: index,
                          postId: post.postId,
                          uId: SocialCubit.get(context).user!.uId,
                        );
                      }));
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(SocialCubit.get(
                                              context)
                                          .user!
                                          .userImage !=
                                      null
                                  ? SocialCubit.get(context).user!.userImage
                                  : 'https://c.files.bbci.co.uk/10E5A/production/_105901296_male.jpg')),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'write a comment..',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            SocialCubit.get(context).posts[index].iLikeIt =
                                !SocialCubit.get(context).posts[index].iLikeIt;
                            SocialCubit.get(context).likePost(post.postId,
                                SocialCubit.get(context).user!.uId, index);
                          },
                          child: Container(
                            height: 30,
                            child: Row(
                              children: [
                                if (SocialCubit.get(context)
                                    .posts[index]
                                    .iLikeIt)
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                if (!SocialCubit.get(context)
                                    .posts[index]
                                    .iLikeIt)
                                  const Icon(
                                    Icons.favorite_border,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Like',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            PostModel post2 = post;
                            post2.name = SocialCubit.get(context).user!.name;
                            post2.uId = SocialCubit.get(context).user!.uId;
                            SocialCubit.get(context).sharePost(post: post2);
                          },
                          child: Container(
                            height: 30,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.ios_share_rounded,
                                  color: Colors.deepPurple,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Share',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

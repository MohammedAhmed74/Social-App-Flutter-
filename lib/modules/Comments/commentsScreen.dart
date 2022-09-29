import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/models/App/commentModel.dart';
import 'package:social_app/modules/Chats/openImageScreen.dart';
import 'package:social_app/modules/Likes/postLikesScreen.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';
import 'package:social_app/shared/network/cacheHelper.dart';
import 'package:social_app/shared/styles/colors.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class CommentsScreen extends StatelessWidget {
  CommentsScreen(
      {required this.postIndex, required this.uId, required this.postId});
  int postIndex;
  String uId;
  String postId;

  var commentCtrl = TextEditingController();
  var replyEditingCtrl = TextEditingController();
  var commentEditingCtrl = TextEditingController();

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
    return BlocConsumer<SocialCubit, SocialStates>(builder: ((context, state) {
      print(SocialCubit.get(context).comments);
      var cubit = SocialCubit.get(context);
      return SafeArea(
          child: Scaffold(
        backgroundColor: CacheHelper.getValue(key: 'lightMode') == true
            ? Colors.white
            : darkBackground,
        appBar: AppBar(
          titleSpacing: 0,
          title: const Text(
            'Comments',
            style: TextStyle(fontSize: 16),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: CacheHelper.getValue(key: 'lightMode') == false
                  ? darkTextcolor
                  : lightTextColor,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              ConditionalBuilder(
                  condition: SocialCubit.get(context).comments.isNotEmpty,
                  fallback: (context) {
                    // if (!SocialCubit.get(context).searchForComments ||
                    //     cubit.posts[postIndex].comments_num == 0 &&
                    //     state is! SuccessDeleteCommentState && state is! SuccessCommentPostState)
                    if (SocialCubit.get(context)
                            .posts[postIndex]
                            .comments_num ==
                        0) {
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.network(
                                "https://assets2.lottiefiles.com/packages/lf20_g4wqji2g.json",
                                height: 200),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              'No comments in this post.',
                              style:
                                  Theme.of(context).textTheme.caption!.copyWith(
                                        fontSize: 14,
                                        color: CacheHelper.getValue(
                                                    key: 'lightMode') ==
                                                false
                                            ? darkTextcolor
                                            : lightTextColor,
                                      ),
                            ),
                            const SizedBox(
                              height: 60,
                            )
                          ],
                        ),
                      );
                    } else {
                      Timer(const Duration(seconds: 10), () {
                        SocialCubit.get(context).searchComments(false);
                      });
                      return const Expanded(
                          child: Center(child: CircularProgressIndicator()));
                    }
                  },
                  builder: (context) {
                    return Expanded(
                      child: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          Container(
                            child: ListView.separated(
                                itemBuilder: ((context, index) {
                                  Timestamp t = cubit.comments[index].dateTime;
                                  DateTime time = t.toDate();
                                  return buildCommentItem(
                                      context,
                                      cubit.getUserImage(
                                          SocialCubit.get(context)
                                              .comments[index]
                                              .userId),
                                      cubit.getUserName(SocialCubit.get(context)
                                          .comments[index]
                                          .userId),
                                      SocialCubit.get(context).comments[index],
                                      index,
                                      time);
                                }),
                                separatorBuilder: ((context, index) =>
                                    const SizedBox(
                                      height: 20,
                                    )),
                                itemCount:
                                    SocialCubit.get(context).comments.length),
                          ),
                          if (SocialCubit.get(context).isReplay)
                            InkWell(
                              onTap: () {
                                SocialCubit.get(context).writingReplay(false);
                                SocialCubit.get(context).commentOwner = '';
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10, right: 10),
                                child: Container(
                                  height: 25,
                                  width: 73,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          'Reply',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 0.5,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      child: CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(
                              SocialCubit.get(context).user!.userImage)),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: commentCtrl,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  CacheHelper.getValue(key: 'lightMode') == true
                                      ? lightTextColor
                                      : darkTextcolor,
                            ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: cubit.switchCommentHint(),
                          // hintText: 'Write a comment',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(
                                fontSize: 12,
                                color: CacheHelper.getValue(key: 'lightMode') ==
                                        true
                                    ? lightTextColor
                                    : darkTextcolor,
                              ),
                        ),
                      ),
                    ),
                    // if (state is! LoadingUploadCommentImageState &&
                    //     state is! SuccessPickedImageState &&
                    //     state is! CheckImagePickedState)
                    if (SocialCubit.get(context).commentImage == null)
                      IconButton(
                        onPressed: () {
                          cubit.getPhotoFromGallary(image: 'comment');
                        },
                        icon: Icon(
                          Icons.image_outlined,
                          color: defaultColor,
                          size: 26,
                        ),
                      ),
                    if (state is LoadingUploadMessageImageState)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15, right: 13),
                        child: Container(
                          height: 20,
                          width: 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    // if (state is SuccessPickedImageState ||
                    //     state is CheckImagePickedState)
                    if (SocialCubit.get(context).commentImage != null)
                      InkWell(
                        onTap: () {
                          cubit.clearImage();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10, right: 10),
                          child: Container(
                            height: 25,
                            width: 65,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'image',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (state is! LoadingCommentPostState)
                      IconButton(
                          onPressed: () {
                            if (!SocialCubit.get(context).isReplay) {
                              SocialCubit.get(context).createComment0(
                                  context: context,
                                  text: commentCtrl.text,
                                  postId: postId,
                                  postIndex: postIndex);
                            } else {
                              SocialCubit.get(context).createReply(
                                context: context,
                                text: commentCtrl.text,
                                postId: postId,
                                commentIndex: SocialCubit.get(context)
                                    .currentCommentIndex!,
                                commentId:
                                    SocialCubit.get(context).currentCommentId!,
                              );
                            }
                            commentCtrl.text = '';
                            SocialCubit.get(context).commentImage = null;
                          },
                          icon: Icon(
                            Icons.send_outlined,
                            color: defaultColor,
                          )),
                    if (state is LoadingCommentPostState)
                      Container(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    }), listener: ((context, state) {
      if (state is ErrorPickedImageState) {
        SocialCubit.get(context).pickedImage(false);
      }
      if (state is SuccessPickedImageState) {
        SocialCubit.get(context).pickedImage(true);
      }
    }));
  }

  Widget buildCommentItem(
    BuildContext context,
    String userImage,
    String userName,
    CommentModel comment,
    int index,
    DateTime time,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onLongPress: () {
                    SocialCubit.get(context).commentImage = null;
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        )),
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  child: OutlinedButton(
                                      onPressed: () {
                                        editCommentButton(
                                          commentId: comment.commentId,
                                          context: context,
                                          beforepick: true,
                                          comment: comment,
                                          index: index,
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.edit,
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Edit',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .copyWith(
                                                    fontSize: 16,
                                                    color: Colors.blue),
                                          ),
                                        ],
                                      )),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  child: OutlinedButton(
                                      onPressed: () {
                                        SocialCubit.get(context).deleteComment(
                                          postId,
                                          comment.commentId,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.delete_rounded,
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Delete',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .copyWith(
                                                    fontSize: 16,
                                                    color: Colors.blue),
                                          ),
                                        ],
                                      )),
                                )
                              ],
                            ),
                          );
                        });
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: CacheHelper.getValue(key: 'lightMode') == true
                          ? Colors.grey[200]
                          : Colors.grey[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(userImage)),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 120,
                              child: Row(
                                children: [
                                  Text(
                                    userName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                            fontSize: 16, color: Colors.black),
                                  ),
                                  Spacer(),
                                  Text(
                                    '${time.hour}:${time.minute}',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            if (comment.comment != '')
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Container(
                                  width: 260,
                                  child: Text(
                                    comment.comment,
                                    maxLines: 6,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                  ),
                                ),
                              ),
                            const SizedBox(
                              height: 5,
                            ),
                            if (comment.image != '')
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(SwipeablePageRoute(
                                    builder: (BuildContext context) =>
                                        OpenImageScreen(
                                      imageUrl: comment.image,
                                      text: comment.comment,
                                    ),
                                  ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Image(
                                    image: NetworkImage(comment.image),
                                    width: 270,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            SocialCubit.get(context).writingReplay(true,
                                commentId: comment.commentId,
                                commentIndex: index);
                            SocialCubit.get(context).commentOwner = userName;
                            SocialCubit.get(context).openReplays(
                              commentIndex: index,
                              open: true,
                            );
                            SocialCubit.get(context)
                                .getReplys(postId, comment.commentId);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Container(
                              height: 30,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'write a reply..',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                          color: CacheHelper.getValue(
                                                      key: 'lightMode') ==
                                                  true
                                              ? lightTextColor
                                              : darkTextcolor,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          SocialCubit.get(context).likeComment(
                              postId: postId,
                              uId: SocialCubit.get(context).user!.uId,
                              index: index,
                              commentId: comment.commentId);
                        },
                        onLongPress: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LikesScreen(
                                    userWhoLikeIds:
                                        comment.usersWhoLikeComment!),
                              ));
                        },
                        child: Container(
                          height: 30,
                          child: Row(
                            children: [
                              if (comment.usersWhoLikeComment != null)
                                if (comment.usersWhoLikeComment!.contains(
                                    SocialCubit.get(context).user!.uId))
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                              if (comment.usersWhoLikeComment == null ||
                                  !comment.usersWhoLikeComment!.contains(
                                      SocialCubit.get(context).user!.uId))
                                const Icon(
                                  Icons.favorite_border,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Like ${comment.likes_num}',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                      color: CacheHelper.getValue(
                                                  key: 'lightMode') ==
                                              true
                                          ? lightTextColor
                                          : darkTextcolor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () {
                          SocialCubit.get(context).openReplays(
                            commentIndex: index,
                          );
                          SocialCubit.get(context)
                              .getReplys(postId, comment.commentId);
                        },
                        child: Container(
                          height: 30,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_outlined,
                                color: Colors.amber,
                                size: 20,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                'Replys ${comment.replays_num}',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                      color: CacheHelper.getValue(
                                                  key: 'lightMode') ==
                                              true
                                          ? lightTextColor
                                          : darkTextcolor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.showReplays &&
                    SocialCubit.get(context).replys.isNotEmpty)
                  SizedBox(
                    height: 15,
                  ),
                if (comment.showReplays &&
                    SocialCubit.get(context).replys.isNotEmpty)
                  // if(false)
                  Container(
                    width: double.infinity,
                    child: ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: ((context, index) {
                          Timestamp t =
                              SocialCubit.get(context).replys[index].dateTime;
                          DateTime time = t.toDate();
                          return buildReplayItem(
                              context,
                              SocialCubit.get(context).getUserImage(
                                  SocialCubit.get(context)
                                      .replys[index]
                                      .userId),
                              SocialCubit.get(context).getUserName(
                                  SocialCubit.get(context)
                                      .replys[index]
                                      .userId),
                              SocialCubit.get(context).replys[index],
                              index,
                              time,
                              comment.commentId);
                        }),
                        separatorBuilder: ((context, index) => const SizedBox(
                              height: 10,
                            )),
                        itemCount: SocialCubit.get(context).replys.length),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25, left: 3),
            child: RotatedBox(
              quarterTurns: 90 + 45,
              child: Text(
                '${numberToMonth[time.month]} ${time.day}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption!.copyWith(
                      fontSize: 10,
                      color: CacheHelper.getValue(key: 'lightMode') == true
                          ? lightTextColor
                          : darkTextcolor,
                    ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildReplayItem(
      BuildContext context,
      String userImage,
      String userName,
      CommentModel reply,
      int index,
      DateTime time,
      String commentId) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: Container(
        width: MediaQuery.of(context).size.width - 90,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 110,
              child: Column(
                children: [
                  InkWell(
                    onLongPress: () {
                      SocialCubit.get(context).commentImage = null;
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          )),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 40,
                                    child: OutlinedButton(
                                        onPressed: () {
                                          editReplyButton(
                                              commentId: commentId,
                                              replyId: reply.commentId,
                                              context: context,
                                              reply: reply,
                                              index: index,
                                              beforepick: true);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.edit,
                                              size: 20,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Edit',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                      fontSize: 16,
                                                      color: Colors.blue),
                                            ),
                                          ],
                                        )),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 40,
                                    child: OutlinedButton(
                                        onPressed: () {
                                          SocialCubit.get(context).deleteReply(
                                            postId,
                                            commentId,
                                            reply.commentId,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.delete_rounded,
                                              size: 20,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Delete',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                      fontSize: 16,
                                                      color: Colors.blue),
                                            ),
                                          ],
                                        )),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(235, 253, 233, 172),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(userImage)),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 190,
                                child: Row(
                                  children: [
                                    Text(
                                      userName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              fontSize: 14,
                                              color: Colors.black),
                                    ),
                                    Spacer(),
                                    Text(
                                      '${time.hour}:${time.minute}',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                              fontSize: 8, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              if (reply.comment != '')
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Container(
                                    width: 200,
                                    child: Text(
                                      reply.comment,
                                      maxLines: 6,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                height: 5,
                              ),
                              if (reply.image != '')
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(SwipeablePageRoute(
                                      builder: (BuildContext context) =>
                                          OpenImageScreen(
                                        imageUrl: reply.image,
                                        text: reply.comment,
                                      ),
                                    ));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Image(
                                      image: NetworkImage(reply.image),
                                      width: 200,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            SocialCubit.get(context).likeReply(
                              postId: postId,
                              uId: SocialCubit.get(context).user!.uId,
                              index: index,
                              commentId: commentId,
                              replyId: reply.commentId,
                            );
                          },
                          onLongPress: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LikesScreen(
                                      userWhoLikeIds:
                                          reply.usersWhoLikeComment!),
                                ));
                          },
                          child: Container(
                            height: 30,
                            child: Row(
                              children: [
                                if (reply.usersWhoLikeComment != null &&
                                    reply.usersWhoLikeComment!.contains(
                                        SocialCubit.get(context).user!.uId))
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                if (reply.usersWhoLikeComment == null ||
                                    !reply.usersWhoLikeComment!.contains(
                                        SocialCubit.get(context).user!.uId))
                                  const Icon(
                                    Icons.favorite_border,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Like ${reply.likes_num}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .copyWith(
                                        color: CacheHelper.getValue(
                                                    key: 'lightMode') ==
                                                true
                                            ? lightTextColor
                                            : darkTextcolor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25, left: 3),
              child: RotatedBox(
                quarterTurns: 90 + 45,
                child: Text(
                  '${numberToMonth[time.month]} ${time.day}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                        fontSize: 8,
                        color: CacheHelper.getValue(key: 'lightMode') == true
                            ? lightTextColor
                            : darkTextcolor,
                      ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  editReplyButton(
      {required BuildContext context,
      required String commentId,
      required String replyId,
      required CommentModel reply,
      required int index,
      required bool beforepick}) {
    if (beforepick) {
      SocialCubit.get(context).commentImage = null;
      replyEditingCtrl.text = reply.comment;
    }
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      )),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: replyEditingCtrl,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: reply.comment == '' ? 'Write a comment..' : '',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 12),
                  ),
                ),
                if (reply.image != '')
                  const SizedBox(
                    height: 5,
                  ),
                if (SocialCubit.get(context).commentImage == null &&
                    SocialCubit.get(context).replys[index].image != '')
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5)),
                        child: Image(
                          image: NetworkImage(
                              SocialCubit.get(context).replys[index].image),
                          width: double.maxFinite,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  SocialCubit.get(context)
                                      .getPhotoFromGallary(image: 'comment')
                                      .then((value) {
                                    Timer(const Duration(seconds: 2), () {
                                      // Navigator.pop(context);
                                      editReplyButton(
                                        commentId: commentId,
                                        replyId: replyId,
                                        context: context,
                                        reply: reply,
                                        index: index,
                                        beforepick: false,
                                      );
                                    });
                                  });
                                },
                                icon: Icon(Icons.edit),
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  SocialCubit.get(context).replys[index].image =
                                      '';
                                  SocialCubit.get(context)
                                      .clearImage(clear: true);
                                  editReplyButton(
                                    commentId: commentId,
                                    context: context,
                                    reply: reply,
                                    replyId: replyId,
                                    index: index,
                                    beforepick: false,
                                  );
                                },
                                icon: Icon(Icons.close),
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                if (SocialCubit.get(context).commentImage != null)
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5)),
                        child: Image(
                          image:
                              FileImage(SocialCubit.get(context).commentImage!),
                          width: double.maxFinite,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  SocialCubit.get(context)
                                      .getPhotoFromGallary(image: 'comment')
                                      .then((value) {
                                    Timer(const Duration(seconds: 2), () {
                                      // Navigator.pop(context);
                                      editReplyButton(
                                        commentId: commentId,
                                        replyId: replyId,
                                        context: context,
                                        reply: reply,
                                        index: index,
                                        beforepick: false,
                                      );
                                    });
                                  });
                                },
                                icon: Icon(Icons.edit),
                                color: defaultColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  SocialCubit.get(context).replys[index].image =
                                      '';
                                  SocialCubit.get(context)
                                      .clearImage(clear: true);
                                  editReplyButton(
                                    commentId: commentId,
                                    context: context,
                                    reply: reply,
                                    replyId: replyId,
                                    index: index,
                                    beforepick: false,
                                  );
                                },
                                icon: Icon(Icons.close),
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                if (SocialCubit.get(context).replys[index].image == '' &&
                    SocialCubit.get(context).commentImage == null)
                  OutlinedButton(
                      onPressed: () {
                        SocialCubit.get(context)
                            .getPhotoFromGallary(image: 'comment')
                            .then((value) {
                          Timer(const Duration(seconds: 2), () {
                            // Navigator.pop(context);
                            editReplyButton(
                              commentId: commentId,
                              context: context,
                              reply: reply,
                              replyId: replyId,
                              index: index,
                              beforepick: false,
                            );
                          });
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Add Photo',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      )),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 40,
                  width: double.maxFinite,
                  child: OutlinedButton(
                      onPressed: () {
                        if (SocialCubit.get(context).commentImage == null) {
                          if (SocialCubit.get(context).commentImageCleared) {
                            SocialCubit.get(context).editReply(
                                postId, commentId, replyId, {
                              'comment': replyEditingCtrl.text,
                              'image': ''
                            });
                          } else {
                            SocialCubit.get(context).editReply(
                                postId,
                                commentId,
                                replyId,
                                {'comment': replyEditingCtrl.text});
                          }
                          // return commentImageCleared to normal value
                          SocialCubit.get(context).clearImage(clear: false);
                        } else {
                          SocialCubit.get(context).editReplyWithImage(
                              postId: postId,
                              commentId: commentId,
                              replyId: replyId,
                              comment: replyEditingCtrl.text);
                        }
                        SocialCubit.get(context).commentImage = null;
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.tips_and_updates,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Update',
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  editCommentButton(
      {required BuildContext context,
      required String commentId,
      required CommentModel comment,
      required int index,
      required bool beforepick}) {
    if (beforepick) {
      SocialCubit.get(context).commentImage = null;
      commentEditingCtrl.text = comment.comment;
    }
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      )),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: commentEditingCtrl,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: comment.comment == '' ? 'Write a comment..' : '',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 12),
                  ),
                ),
                if (comment.image != '')
                  const SizedBox(
                    height: 5,
                  ),
                if (SocialCubit.get(context).commentImage == null &&
                    SocialCubit.get(context).comments[index].image != '')
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5)),
                        child: Image(
                          image: NetworkImage(
                              SocialCubit.get(context).comments[index].image),
                          width: double.maxFinite,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  SocialCubit.get(context)
                                      .getPhotoFromGallary(image: 'comment')
                                      .then((value) {
                                    Timer(const Duration(seconds: 2), () {
                                      // Navigator.pop(context);
                                      editCommentButton(
                                        commentId: commentId,
                                        context: context,
                                        comment: comment,
                                        index: index,
                                        beforepick: false,
                                      );
                                    });
                                  });
                                },
                                icon: Icon(Icons.edit),
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  SocialCubit.get(context)
                                      .comments[index]
                                      .image = '';
                                  SocialCubit.get(context)
                                      .clearImage(clear: true);
                                  editCommentButton(
                                    commentId: commentId,
                                    context: context,
                                    comment: comment,
                                    index: index,
                                    beforepick: false,
                                  );
                                },
                                icon: Icon(Icons.close),
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                if (SocialCubit.get(context).commentImage != null)
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5)),
                        child: Image(
                          image:
                              FileImage(SocialCubit.get(context).commentImage!),
                          width: double.maxFinite,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  SocialCubit.get(context)
                                      .getPhotoFromGallary(image: 'comment')
                                      .then((value) {
                                    Timer(const Duration(seconds: 2), () {
                                      // Navigator.pop(context);
                                      editCommentButton(
                                        commentId: commentId,
                                        context: context,
                                        comment: comment,
                                        index: index,
                                        beforepick: false,
                                      );
                                    });
                                  });
                                },
                                icon: Icon(Icons.edit),
                                color: defaultColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.4),
                              child: IconButton(
                                onPressed: () {
                                  SocialCubit.get(context)
                                      .comments[index]
                                      .image = '';
                                  SocialCubit.get(context)
                                      .clearImage(clear: true);
                                  editCommentButton(
                                    commentId: commentId,
                                    context: context,
                                    comment: comment,
                                    index: index,
                                    beforepick: false,
                                  );
                                },
                                icon: Icon(Icons.close),
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                if (SocialCubit.get(context).comments[index].image == '' &&
                    SocialCubit.get(context).commentImage == null)
                  OutlinedButton(
                      onPressed: () {
                        SocialCubit.get(context)
                            .getPhotoFromGallary(image: 'comment')
                            .then((value) {
                          Timer(const Duration(seconds: 2), () {
                            // Navigator.pop(context);
                            editCommentButton(
                              commentId: commentId,
                              context: context,
                              comment: comment,
                              index: index,
                              beforepick: false,
                            );
                          });
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Add Photo',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      )),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 40,
                  width: double.maxFinite,
                  child: OutlinedButton(
                      onPressed: () {
                        if (SocialCubit.get(context).commentImage == null) {
                          if (SocialCubit.get(context).commentImageCleared) {
                            SocialCubit.get(context).editComment(
                                postId, commentId, {
                              'comment': commentEditingCtrl.text,
                              'image': ''
                            });
                          } else {
                            SocialCubit.get(context).editComment(
                                postId,
                                commentId,
                                {'comment': commentEditingCtrl.text});
                          }
                          // return commentImageCleared to normal value
                          SocialCubit.get(context).clearImage(clear: false);
                        } else {
                          SocialCubit.get(context).editCommentWithImage(
                              postId: postId,
                              commentId: commentId,
                              comment: commentEditingCtrl.text);
                        }
                        SocialCubit.get(context).commentImage = null;
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.tips_and_updates,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Update',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

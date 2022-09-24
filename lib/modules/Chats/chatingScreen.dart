import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/models/App/messageModel.dart';
import 'package:social_app/models/Users/userModel.dart';
import 'package:social_app/modules/Chats/openImageScreen.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';
import 'package:social_app/shared/network/cacheHelper.dart';
import 'package:social_app/shared/styles/colors.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'dart:async';

class ChatingScreen extends StatelessWidget {
  ChatingScreen({Key? key, required this.receiver});
  var messageCtrl = TextEditingController();
  UserModel receiver;
  @override
  Widget build(BuildContext context) {
    var cubit = SocialCubit.get(context);
    return BlocConsumer<SocialCubit, SocialStates>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: darkBackground,
          appBar: AppBar(
            titleSpacing: 0,
            elevation: 0.5,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
                cubit.messages = [];
              },
              // CacheHelper.getValue(key: 'lightMode') == true
              //       ? lightTextColor
              //       : darkTextcolor
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: CacheHelper.getValue(key: 'lightMode') == true
                    ? lightTextColor
                    : darkTextcolor,
              ),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(receiver.userImage),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  receiver.name,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                ConditionalBuilder(
                  condition: cubit.messages.isNotEmpty &&
                      cubit.users.isNotEmpty &&
                      cubit.user != null,
                  fallback: (context) {
                    if (cubit.noMessages) {
                      Timer(const Duration(seconds: 2), () {
                        cubit.seaarchForMessages(false);
                      });
                      cubit.getMessages(receiver.uId);
                      return const Expanded(
                          child: Center(child: CircularProgressIndicator()));
                    } else {
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.network(
                                'https://assets10.lottiefiles.com/packages/lf20_ctVPin.json',
                                height: 200),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Send a message for ${receiver.name}',
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
                      );
                    }
                  },
                  builder: (context) {
                    return Expanded(
                        child: ListView.separated(
                            reverse: true,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: ((context, index) {
                              List<String> msgTime =
                                  cubit.messages[index].dateTime.split(' ');
                              if (cubit.messages[index].senderId ==
                                  cubit.user!.uId) {
                                return buildMyMessage(
                                    context, cubit.messages[index], msgTime);
                              }
                              return buildOtherMessage(
                                  context, cubit.messages[index], msgTime);
                            }),
                            separatorBuilder: ((context, index) =>
                                const SizedBox(
                                  height: 5,
                                )),
                            itemCount: cubit.messages.length));
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, right: 0),
                                  child: TextFormField(
                                    minLines: 1,
                                    maxLines: 4,
                                    controller: messageCtrl,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'write your message..',
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              if (state is! LoadingUploadMessageImageState &&
                                  state is! SuccessPickedImageState)
                                IconButton(
                                  onPressed: () {
                                    cubit.getPhotoFromGallary(image: 'message');
                                  },
                                  icon: Icon(
                                    Icons.image_outlined,
                                    color: defaultColor,
                                    size: 26,
                                  ),
                                ),
                              if (state is LoadingUploadMessageImageState)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 15, right: 13),
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ),
                              if (state is SuccessPickedImageState)
                                InkWell(
                                  onTap: () {
                                    cubit.clearMessageImage();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, right: 10),
                                    child: Container(
                                      height: 25,
                                      width: 65,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text(
                                              'image',
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
                                )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      CircleAvatar(
                        backgroundColor: defaultColor,
                        radius: 24,
                        child: IconButton(
                          onPressed: () async {
                            MessageModel msg;
                            if (cubit.messageImage == null) {
                              msg = MessageModel(
                                  resiverId: receiver.uId,
                                  senderId: cubit.user!.uId,
                                  dateTime: DateFormat('MM-dd KK:mm a')
                                      .format(DateTime.now())
                                      .toString(),
                                  message: messageCtrl.text);
                              messageCtrl.text = '';
                              cubit.uploadMessage(msg, receiver);
                            } else {
                              print('elseeeeeee');
                              cubit.uploadMessageImage();
                              // cubit.messages = [];
                              // cubit.getMessages(receiver.uId,
                              //     newMessage: true,
                              //     resiverId: receiver.uId,
                              //     dateTime: DateTime.now().toString(),
                              //     message: messageCtrl.text);
                            }
                          },
                          icon: Icon(
                            Icons.send_outlined,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state is SuccessUploadMessageImageState) {
          MessageModel msg;
          msg = MessageModel(
              resiverId: receiver.uId,
              senderId: cubit.user!.uId,
              image: cubit.messageImg!,
              dateTime:
                  DateFormat('MM-dd KK:mm a').format(DateTime.now()).toString(),
              message: messageCtrl.text);
          cubit.uploadMessage(msg, receiver);
          messageCtrl.text = '';
        }
        // if (state is SuccessAddingMessage) {
        // }
      },
    );
  }

  Widget buildOtherMessage(
      BuildContext context, MessageModel message, List<String> msgTime) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      right: 10, left: 10, top: 10, bottom: 10),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(107, 158, 158, 158),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.message != '')
                        Text(
                          message.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      if (message.image != '' && message.message != '')
                        const SizedBox(
                          height: 5,
                        ),
                      if (message.image != '')
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(SwipeablePageRoute(
                              builder: (BuildContext context) =>
                                  OpenImageScreen(
                                imageUrl: message.image,
                              ),
                            ));
                          },
                          child: Image(
                            image: NetworkImage(
                              message.image,
                            ),
                            width: 200,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      // Text(
                      //   '~${SocialCubit.get(context).getUserInfo(message.senderId, 'name')}',
                      //   textAlign: TextAlign.start,
                      //   style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      //       color: Colors.grey.withOpacity(0),
                      //       // color: CacheHelper.getValue(key: 'lightMode') == true? lightTextColor : darkTextcolor,
                      //       fontSize: 10,
                      //       height: 0,
                      //       fontWeight: FontWeight.w300),
                      // ),
                    ],
                  ),
                ),
                Text(
                  '~${SocialCubit.get(context).getUserInfo(message.senderId, 'name')}',
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontSize: 10, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              '${msgTime[1]} ${msgTime[2]}',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: CacheHelper.getValue(key: 'lightMode') == true
                      ? lightTextColor
                      : darkTextcolor,
                  fontSize: 8,
                  height: 0,
                  fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMyMessage(
      BuildContext context, MessageModel message, List<String> msgTime) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              '${msgTime[1]} ${msgTime[2]}',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: CacheHelper.getValue(key: 'lightMode') == true
                      ? lightTextColor
                      : darkTextcolor,
                  fontSize: 8,
                  height: 0,
                  fontWeight: FontWeight.w300),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      right: 10, left: 10, top: 10, bottom: 10),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(144, 255, 236, 179),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.message != '')
                        Text(
                          message.message,
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      if (message.image != '' && message.message != '')
                        const SizedBox(
                          height: 5,
                        ),
                      if (message.image != '')
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(SwipeablePageRoute(
                              builder: (BuildContext context) =>
                                  OpenImageScreen(
                                imageUrl: message.image,
                              ),
                            ));
                          },
                          child: Image(
                            image: NetworkImage(
                              message.image,
                            ),
                            width: 200,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      // Text(
                      //   '~${SocialCubit.get(context).getUserInfo(message.senderId, 'name')}',
                      //   textAlign: TextAlign.start,
                      //   style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      //       color: Colors.amber.withOpacity(0),
                      //       // color: CacheHelper.getValue(key: 'lightMode') == true? lightTextColor : darkTextcolor,
                      //       fontSize: 10,
                      //       height: 0,
                      //       fontWeight: FontWeight.w300),
                      // ),
                    ],
                  ),
                ),
                Text(
                  '~${SocialCubit.get(context).getUserInfo(message.senderId, 'name')}',
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontSize: 10, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

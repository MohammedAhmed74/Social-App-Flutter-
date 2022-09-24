import 'dart:ffi';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:social_app/Layout/SocialLayout/socialLayout.dart';
import 'package:social_app/models/App/commentModel.dart';
import 'package:social_app/models/App/messageModel.dart';
import 'package:social_app/models/App/postModel.dart';
import 'package:social_app/models/Users/userModel.dart';
import 'package:social_app/modules/Chats/chatsScreen.dart';
import 'package:social_app/modules/Comments/commentsScreen.dart';
import 'package:social_app/modules/EditProfileData/editProfileScreen.dart';
import 'package:social_app/modules/Feeds/feedsScreen.dart';
import 'package:social_app/modules/Login/loginScreen.dart';
import 'package:social_app/modules/Notifications/notifications.dart';
import 'package:social_app/modules/Post/postScreen.dart';
import 'package:social_app/modules/Profile/profileScreen.dart';
import 'package:social_app/modules/Users/users.dart';
import 'package:social_app/shared/cubit/socialStates.dart';
import 'package:social_app/shared/network/cacheHelper.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SocialCubit extends Cubit<SocialStates> {
  SocialCubit() : super(InitialSocialState());
  static SocialCubit get(context) => BlocProvider.of(context);

  List<CommentModel> comments = [];
  List<CommentModel> replys = [];
  List<String> usersWhoLikePost = [];
  List<UserModel> usersWhoLikeThePost = [];
  bool searchForComments = true; // reload commentsScreen

  UserModel? user;
  Future<void> getUserData() async {
    user = null;
    // emit(LoadingUserDataState());
    if (CacheHelper.getValue(key: 'uId') != null) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(CacheHelper.getValue(key: 'uId'))
          .get()
          .then((value) {
        user = UserModel.fromJson(value.data()!);
        print(user!.email);
        emit(SuccessUserDataState());
        getAllUsers();
      }).catchError((error) {
        print(error);
        emit(ErrorUserDataState());
      });
    }
  }

  int currentIndex = 0;
  List<Widget> Screens = [
    FeedsScreen(),
    ChatsScreen(),
    //PostScreen(),
    UsersScreen(),
    ProfileScreen(),
  ];

  List<String> titles = ['Home', 'Chats', 'Users', 'Profile'];

  void changeBottomNav(int index, BuildContext context) {
    if (index == 0) searchForPosts(true);
    if (index == 3) {
      getMyPosts(user!.uId);
      doSignOut(false);
      searchForPostsForMe(true);
    }
    ;
    currentIndex = index;
    emit(ChangeNavState());
  }

  void createPostButton(BuildContext context) {
    postImage = null;
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => const PostScreen())));
    emit(CreatePostState());
  }

  final ImagePicker picker = ImagePicker();
  // Pick an image
  File? profileImage;
  File? coverImage;
  File? postImage;
  File? messageImage;
  File? commentImage;
  Future<bool> getPhotoFromGallary({required String image}) async {
    picker
        .pickImage(source: ImageSource.gallery, imageQuality: 70)
        .then((value) {
      if (value != null) {
        switch (image) {
          case 'profile':
            profileImage = File(value.path);
            break;

          case 'cover':
            coverImage = File(value.path);
            break;

          case 'message':
            messageImage = File(value.path);
            break;

          case 'comment':
            commentImage = File(value.path);
            break;

          case 'post':
            postImage = File(value.path);
        }
        emit(SuccessPickedImageState());
      } else {
        {
          print('No image selected !!');
          emit(ErrorPickedImageState());
        }
      }
    });
    return false;
  }

  bool errorProfileUpdate = false;
  Future<void> uploadProfileImage() async {
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Users/${Uri.file(profileImage!.path).pathSegments.last}')
        .putFile(profileImage!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) {
        user!.userImage = value;
        // if (CacheHelper.getValue(key: 'profileImage') != null) {
        //   deleteImageFromStorage(CacheHelper.getValue(key: 'profileImage'));
        // }
        FirebaseFirestore.instance
            .collection('Users')
            .doc(CacheHelper.getValue(key: 'uId'))
            .update({'userImage': value}).then((value) {
          // CacheHelper.setValue(
          //     key: 'profileImage',
          //     value: 'Users/${Uri.file(profileImage!.path).pathSegments.last}');

          emit(SuccessUploadProfileImageState());
        });
      }).catchError((error) {
        print(error);
        errorProfileUpdate = true;
        emit(ErrorUploadProfileImageState());
      });
    }).catchError((error) {
      print(error);
      errorProfileUpdate = true;
      emit(ErrorUploadProfileImageState());
    });
  }

  bool errorCoverUpdate = false;
  Future<void> uploadCoverImage() async {
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Users/${Uri.file(coverImage!.path).pathSegments.last}')
        .putFile(coverImage!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) {
        user!.cover = value;
        // if (CacheHelper.getValue(key: 'coverImage') != null) {
        //   deleteImageFromStorage(CacheHelper.getValue(key: 'coverImage'));
        // }
        FirebaseFirestore.instance
            .collection('Users')
            .doc(CacheHelper.getValue(key: 'uId'))
            .update({'cover': value}).then((value) {
          // CacheHelper.setValue(
          //     key: 'coverImage',
          //     value: Uri.file(coverImage!.path).pathSegments.last);
          emit(SuccessUploadCoverImageState());
        });
      }).catchError((error) {
        print(error);
        errorCoverUpdate = true;
        emit(ErrorUploadCoverImageState());
      });
    }).catchError((error) {
      print(error);
      errorCoverUpdate = true;
      emit(ErrorUploadCoverImageState());
    });
  }

  late String? messageImg;
  Future<void> uploadMessageImage() async {
    emit(LoadingUploadMessageImageState());
    messageImg = '';
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Users/${Uri.file(messageImage!.path).pathSegments.last}')
        .putFile(messageImage!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) {
        messageImg = value;
        emit(SuccessUploadMessageImageState());
        print(messageImg);
        print('done');
      }).catchError((error) {
        print(error);
        emit(ErrorUploadMessageImageState());
      });
    }).catchError((error) {
      print(error);
      emit(ErrorUploadMessageImageState());
    });
  }

  void clearMessageImage() {
    messageImage = null;
    emit(SuccessClearMessageImage());
  }

  Future<void> EditProfileData({
    required String name,
    required String bio,
    required String phone,
  }) async {
    emit(LoadingProfileUpdateState());
    print(bio);
    FirebaseFirestore.instance
        .collection('Users')
        .doc(CacheHelper.getValue(key: 'uId'))
        .update({
      'bio': bio,
      'name': name,
      'phone': phone,
    }).then((value) async {
      if (profileImage != null) {
        await uploadProfileImage();
      }
      if (coverImage != null) {
        await uploadCoverImage().then((value) {});
      }
      if (profileImage != null && errorProfileUpdate == false ||
          profileImage == null) {
        if (coverImage != null && errorCoverUpdate == false ||
            coverImage == null) {
          getUserData().then((value) {
            emit(SuccessProfileUpdateState());
          });
        } else {
          emit(ErrorProfileUpdateState());
        }
      } else {
        emit(ErrorProfileUpdateState());
      }
    }).catchError((error) {
      print(error);
    });
  }

  deleteImageFromStorage(String path) {
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child(path)
        .delete()
        .then((value) {})
        .catchError((error) {
      print(error);
    });
  }

  canselEdit() {
    emit(CanselEditState());
  }

  PostModel? post;
  Future createPost(
      {required String text, required BuildContext context}) async {
    emit(LoadingCreatePostState());
    if (postImage != null) {
      await uploadPostWithImage(text);
    } else {
      post = PostModel(
        uId: user!.uId,
        name: user!.name,
        time: Timestamp.now(),
        //time: DateFormat('MM-dd KK:mm a').format(DateTime.now()),
        text: text,
      );
      FirebaseFirestore.instance
          .collection('Posts')
          .add(post!.toMap())
          .then((value) {
        noPosts = true;
        getPosts().then((value) {
          getMyPosts(SocialCubit.get(context).user!.uId);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SocialLayout()));
        });
      });
    }
  }

  Future sharePost({required PostModel post}) async {
    //post.time = DateFormat('MM-dd KK:mm a').format(DateTime.now());
    post.time = Timestamp.now();
    FirebaseFirestore.instance
        .collection('Posts')
        .add(post.toMap())
        .then((value) {
      getPosts();
    });
  }

  Future<void> uploadPostWithImage(String text) async {
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Posts/${Uri.file(postImage!.path).pathSegments.last}')
        .putFile(postImage!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) {
        post = PostModel(
          uId: user!.uId,
          name: user!.name,
          time: Timestamp.now(),
          text: text,
          postImage: value,
        );
        FirebaseFirestore.instance
            .collection('Posts')
            .add(post!.toMap())
            .then((value) {
          getPosts();
        });
        emit(SuccessCreatePostState());
      }).catchError((error) {
        print(error);
        emit(ErrorCreatePostState());
      });
    }).catchError((error) {
      print(error);
      emit(ErrorCreatePostState());
    });
  }

  removeImagePost() {
    postImage = null;
    emit(RemovePostImageState());
  }

  List<PostModel> posts = [];
  List<String> usersWhoLike = [];
  Future<void> getPosts() async {
    QuerySnapshot<Map<String, dynamic>>? likesTest;
    QuerySnapshot<Map<String, dynamic>>? commentsTest;
    posts = [];
    FirebaseFirestore.instance
        .collection('Posts')
        .orderBy('time', descending: true)
        .get()
        .then((value) async {
      for (int i = 0; i < value.docs.length; i++) {
        commentsTest = null;
        likesTest = null;
        usersWhoLike = [];
        likesTest = await value.docs[i].reference.collection('Likes').get();
        commentsTest =
            await value.docs[i].reference.collection('Comments').get();
        for (int j = 0; j < likesTest!.docs.length; j++) {
          usersWhoLike.add(likesTest!.docs[j].data().keys.first);
        }
        posts.add(PostModel.fromJson(
            json: value.docs[i].data(),
            id: value.docs[i].id,
            usersWhoLike: usersWhoLike,
            likes: likesTest!.docs.length,
            comments: commentsTest!.docs.length));
      }
      emit(SuccessGetPostsState());
    }).catchError((error) {
      print(error);
      emit(ErrorGetPostsState());
    });
  }

  List<PostModel>? myPosts = [];
  getMyPosts(String uId) {
    myPosts = [];
    for (int i = 0; i < posts.length; i++) {
      if (posts[i].uId == uId) {
        myPosts!.add(posts[i]);
      } else {
        continue;
      }
    }
    if (myPosts!.isNotEmpty) {
      emit(SuccessGetPostsState());
    } else {
      searchForPostsForMe(false);
      emit(ErrorGetPostsState());
    }
  }

  UserModel? tempUser;
  Future<void> getUserById(String uId) async {
    FirebaseFirestore.instance.collection('Users').doc(uId).get().then((value) {
      tempUser = UserModel.fromJson(value.data()!);
    }).catchError((error) {
      print(error);
    });
  }

  bool refresh = true;
  refreshPostScreen() {
    if (refresh) {
      emit(SuccessGetUserImageState());
      refresh = false;
    }
  }

  Future likePost(String postId, String uId, int index) async {
    await getLikeId(postId, uId, index);
  }

  Future getLikeId(String postId, String uId, int index) async {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .get()
        .then((value) {
      PostModel tempPost =
          PostModel.fromJson(json: value.data()!, id: value.id);

      if (posts[index].userWhoLikeIds!.contains(user!.uId) == false) {
        posts[index].likes_num = posts[index].likes_num + 1;
        posts[index].userWhoLikeIds!.add(user!.uId);
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Likes')
            .add({uId: true}).then((value) {
          FirebaseFirestore.instance
              .collection('Posts')
              .doc(postId)
              .update({'myLikeId': value.id});
          emit(SuccessLikePostState());
        });
      } else {
        posts[index].likes_num = posts[index].likes_num - 1;
        posts[index].userWhoLikeIds!.remove(user!.uId);
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Likes')
            .doc(tempPost.myLikeId)
            .delete()
            .then((value) {
          emit(SuccessUnlikePostState());
        }).catchError((error) {
          print(error);

          emit(ErrorUnlikePostState());
        });
      }
    });
  }

  // Future commentPost(
  //     String postId, String uId, int index, String comment) async {
  //   emit(LoadingCommentPostState());
  //   await getcommentId(postId, uId, index, comment);
  // }

  // Future getcommentId(
  //     String postId, String uId, int index, String comment) async {
  //   FirebaseFirestore.instance
  //       .collection('Posts')
  //       .doc(postId)
  //       .get()
  //       .then((value) {
  //     PostModel tempPost =
  //         PostModel.fromJson(json: value.data()!, id: value.id);
  //     posts[index].comments_num = posts[index].comments_num + 1;
  //     FirebaseFirestore.instance
  //         .collection('Posts')
  //         .doc(postId)
  //         .collection('Comments')
  //         .add({uId: comment.toString()}).then((value) async {
  //       searchForComments = true;
  //       await getComments(postId);
  //       // emit(SuccessCommentPostState());
  //     }).catchError((error) {
  //       print(error);
  //       emit(ErrorCommentPostState());
  //     });
  //   });
  // }

  String getUserInfo(String userUid, String requist) {
    String response = '';
    if (requist == 'image') {
      if (userUid == user!.uId) return user!.userImage;
      users.forEach((element) {
        if (element.uId == userUid) {
          response = element.userImage;
        }
      });
    } else if (requist == 'name') {
      if (userUid == user!.uId) return user!.name;
      users.forEach((element) {
        if (element.uId == userUid) {
          response = element.name;
        }
      });
    }
    return response;
  }

  // Future getCommentt(String postId) async {
  //   commentsMap = [];
  //   usersComments = [];
  //   comments = [];
  //   FirebaseFirestore.instance
  //       .collection('Posts')
  //       .doc(postId)
  //       .collection('Comments')
  //       .get()
  //       .then((value) {
  //     value.docs.forEach((element) {
  //       commentsMap.add(element.data());
  //     });
  //     print(commentsMap);
  //     commentsMap.forEach((element) {
  //       element.forEach((key, value) {
  //         usersComments.add(key);
  //         print(usersComments);
  //         comments.add(value);
  //         print(comments);
  //       });
  //     });
  //     if (comments.isNotEmpty) {
  //       getUsersInfoForsComments();
  //     } else {
  //       emit(ErrorGettingCommentsState());
  //     }
  //   }).catchError((error) {
  //     print(error);
  //     emit(ErrorGettingCommentsState());
  //   });
  // }

  openComments() {
    searchForComments = true;
    emit(OpenCommentsState());
  }

  searchComments(bool search) {
    searchForComments = search;
    emit(OpenCommentsState());
  }

  // List<String> usersCommentImages = [];
  // List<String> usersCommentNames = [];
  // late UserModel tempUser2;
  // getUsersInfoForsComments() {
  //   usersCommentImages = [];
  //   usersCommentNames = [];
  //   usersComments.forEach((element) {
  //     FirebaseFirestore.instance
  //         .collection('Users')
  //         .doc(element)
  //         .get()
  //         .then((value) {
  //       tempUser2 = UserModel.fromJson(value.data()!);
  //       usersCommentImages.add(tempUser2.userImage);
  //       usersCommentNames.add(tempUser2.name);
  //       print(usersCommentNames);
  //       emit(SuccessGettingCommentsState());
  //     }).catchError((error) {
  //       print(error);
  //     });
  //   });
  // }

  List<UserModel> users = [];
  Future getAllUsers() async {
    emit(LoadingAllUsersDataState());
    FirebaseFirestore.instance.collection('Users').get().then((value) {
      users = [];
      value.docs.forEach((element) {
        if (element.data()['uId'] != user!.uId) {
          users.add(UserModel.fromJson(element.data()));
        }
      });
      emit(SuccessAllUsersDataState());
    }).catchError((error) {
      print(error);
      emit(ErrorAllUsersDataState());
    });
  }

  Future uploadMessage(MessageModel message, UserModel receiver) async {
    emit(LoadingSendMessageState());
    FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uId)
        .collection('Chats')
        .doc(receiver.uId)
        .collection('Messages')
        .add(message.toMap())
        .then((value) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(receiver.uId)
          .collection('Chats')
          .doc(user!.uId)
          .collection('Messages')
          .add(message.toMap())
          .then((value) {
        messageImage = null;
        messageImg = '';
        emit(SuccessSendMessageState());
      }).catchError((error) {
        print(error);
        emit(ErrorSendMessageState());
      });
    }).catchError((error) {
      print(error);
      emit(ErrorSendMessageState());
    });
  }

  List<MessageModel> messages = [];
  Future getMessages(
    String receiverUid, {
    bool newMessage = false,
    String? resiverId,
    String? dateTime,
    String? message,
  }) async {
    emit(LoadingGettingMessagesState());
    FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uId)
        .collection('Chats')
        .doc(receiverUid)
        .collection('Messages')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((event) {
      messages = [];
      event.docs.forEach((element) {
        messages.add(MessageModel.fromJson(json: element.data()));
      });
      if (newMessage) {
        messages.add(MessageModel(
            resiverId: resiverId!,
            senderId: user!.uId,
            dateTime: dateTime!,
            fileImage: messageImage,
            message: message!));
        newMessage = false;
      }
      emit(SuccessGettingMessagesState());
    });
  }

  bool noMessages = true;
  seaarchForMessages(bool found) {
    noMessages = found;
    emit(FoundMessagesState());
  }

  bool noPosts = true;
  searchForPosts(bool found) {
    noPosts = found;
    emit(FoundPostsState());
  }

  bool noPostsForMe = true;
  searchForPostsForMe(bool found) {
    noPostsForMe = found;
    emit(FoundPostsState());
  }

  bool signOut = false;
  doSignOut(bool order) {
    signOut = order;
    emit(SignOutState());
  }

  Future logOut(BuildContext context) async {
    FirebaseAuth.instance.signOut();
    user = null;
    myPosts = [];
    CacheHelper.removeValue(key: 'uId').then((value) {
      if (value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
    print('logout');
    print(CacheHelper.getValue(key: 'uId'));
  }

  // addManMessageManually({
  //   required String resiverId,
  //   required String dateTime,
  //   required String message,
  // }) {
  //   print('addManMessageManuallyyyyyyyyyyyyyyyyyyyyyyyyyy');
  //   print(messages[messages.length - 1].message);
  //   messages.add(MessageModel(
  //       resiverId: resiverId,
  //       senderId: user!.uId,
  //       dateTime: dateTime,
  //       fileImage: messageImage,
  //       message: message));
  //   print(messages[messages.length - 1].message);
  //   emit(SuccessAddingMessage());
  // }

  CommentModel? comment0;
  Future createComment0(
      {required String text,
      required BuildContext context,
      required String postId,
      required int postIndex}) async {
    emit(LoadingCommentPostState());
    if (commentImage != null) {
      await uploadCommentWithImage(text, postId, postIndex);
    } else {
      comment0 = CommentModel(
        comment: text,
        userId: user!.uId,
        dateTime: Timestamp.now(),
      );
      FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .collection('Comments')
          .add(comment0!.toMap())
          .then((value) {
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc(value.id)
            .update({'commentId': value.id});
      }).then((value) async {
        posts[postIndex].comments_num = posts[postIndex].comments_num + 1;
        searchForComments = true;
        getComments(postId);
        getMyPosts(SocialCubit.get(context).user!.uId);
        emit(SuccessCommentPostState());
      });
    }
  }

  Future<void> uploadCommentWithImage(
      String text, String postId, int postIndex) async {
    // comments.add(CommentModel(
    //     userId: user!.uId,
    //     dateTime: Timestamp.now(),
    //     comment: text,
    //     fileImage: commentImage));
    posts[postIndex].comments_num = posts[postIndex].comments_num + 1;

    // test
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Comments/${Uri.file(commentImage!.path).pathSegments.last}')
        .putFile(commentImage!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) {
        comment0 = CommentModel(
          comment: text,
          userId: user!.uId,
          dateTime: Timestamp.now(),
          image: value,
        );
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .add(comment0!.toMap())
            .then((value) {
          FirebaseFirestore.instance
              .collection('Posts')
              .doc(postId)
              .collection('Comments')
              .doc(value.id)
              .update({'commentId': value.id}).then((value) {
            comments[comments.length - 1].fileImage = null;
            searchForComments = true;
            getComments(postId);
            emit(SuccessCommentPostState());
          });
        });
      }).catchError((error) {
        print(error);
        emit(ErrorCommentPostState());
      });
    }).catchError((error) {
      print(error);
      emit(ErrorCommentPostState());
    });
  }

  List<String> usersWhoLikeComment = [];
  Future<void> getComments(String postId) async {
    QuerySnapshot<Map<String, dynamic>>? likesTest;
    QuerySnapshot<Map<String, dynamic>>? replysTest;
    comments = [];
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .orderBy('dateTime', descending: true)
        .get()
        .then((value) async {
      for (int i = 0; i < value.docs.length; i++) {
        replysTest = null;
        likesTest = null;
        usersWhoLikeComment = [];
        likesTest = await value.docs[i].reference.collection('Likes').get();
        replysTest = await value.docs[i].reference.collection('Replys').get();
        for (int j = 0; j < likesTest!.docs.length; j++) {
          usersWhoLikeComment.add(likesTest!.docs[j].data().keys.first);
        }
        comments.add(CommentModel.fromJson(
            json: value.docs[i].data(),
            id: value.docs[i].id,
            usersWhoLikeComment: usersWhoLikeComment,
            likes: likesTest!.docs.length,
            replays: replysTest!.docs.length));
      }
      emit(SuccessGettingCommentsState());
    }).catchError((error) {
      print(error);
      emit(ErrorGettingCommentsState());
    });
  }

  bool commentImageCleared = false;
  void clearImage({bool? clear}) {
    commentImage = null;
    commentImageCleared = clear ?? false;
    emit(SuccessClearCommentImage());
  }
  // Future getPostComments(String postId) async {
  //   getComments(postId).then((value) {
  //     emit(SuccessGettingCommentsState());
  //   });
  // }

  String getUserImage(String userId) {
    print(users);
    String userImage = '';
    users.forEach(
      (element) {
        if (element.uId == userId) {
          userImage = element.userImage;
        }
      },
    );
    if (userImage == '') return user!.userImage;
    return userImage;
  }

  String getUserName(String userId) {
    String userName = '';
    users.forEach(
      (element) {
        if (element.uId == userId) {
          userName = element.name;
        }
      },
    );
    if (userName == '') return user!.name;
    return userName;
  }

  Future likeComment(
      {required String postId,
      required String commentId,
      required String uId,
      required int index}) async {
    await getLikeCommentId(postId, commentId, uId, index);
  }

  Future getLikeCommentId(
    String postId,
    String commentId,
    String uId,
    int index,
  ) async {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .doc(commentId)
        .get()
        .then((value) {
      CommentModel tempComment = CommentModel.fromJson(
        json: value.data()!,
        id: value.id,
      );

      if (!comments[index].usersWhoLikeComment!.contains(user!.uId)) {
        comments[index].usersWhoLikeComment!.add(user!.uId);
        comments[index].likes_num = comments[index].likes_num + 1;
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc(commentId)
            .collection('Likes')
            .add({uId: true}).then((value) {
          FirebaseFirestore.instance
              .collection('Posts')
              .doc(postId)
              .collection('Comments')
              .doc(commentId)
              .update({'myLikeId': value.id.toString()});
          emit(SuccessLikeCommentState());
        }).catchError((error) {
          print(error);
          emit(ErrorLikeCommentState());
        });
      } else {
        comments[index].usersWhoLikeComment!.remove(user!.uId);
        comments[index].likes_num = comments[index].likes_num - 1;
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc(commentId)
            .collection('Likes')
            .doc(tempComment.myLikeId)
            .delete()
            .then((value) {
          FirebaseFirestore.instance
              .collection('Posts')
              .doc(postId)
              .collection('Comments')
              .doc(commentId)
              .update({'myLikeId': ''}).then((value) {
            emit(SuccessUnlikeCommentState());
          }).catchError((error) {
            print(error);

            emit(ErrorUnlikeCommentState());
          });
        }).catchError((error) {
          print(error);

          emit(ErrorUnlikeCommentState());
        });
      }
    });
  }

  late int? currentCommentIndex;
  late String? currentCommentId;
  bool isReplay = false;
  writingReplay(bool replay, {int? commentIndex, String? commentId}) {
    isReplay = replay;
    currentCommentIndex = commentIndex;
    currentCommentId = commentId;
    emit(WritingReplayState());
  }

  late String commentOwner;
  String switchCommentHint() {
    if (isReplay) {
      return 'replying to $commentOwner';
    } else {
      return 'write a comment..';
    }
  }

  //                     replys

  CommentModel? reply;
  Future createReply(
      {required BuildContext context,
      required String text,
      required String postId,
      required String commentId,
      required int commentIndex}) async {
    emit(LoadingCommentPostState());
    if (commentImage != null) {
      await uploadReplyWithImage(text, postId, commentId, commentIndex);
    } else {
      reply = CommentModel(
        comment: text,
        userId: user!.uId,
        dateTime: Timestamp.now(),
      );
      FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .collection('Comments')
          .doc(commentId)
          .collection('Replys')
          .add(reply!.toMap())
          .then((value) {
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc(commentId)
            .collection('Replys')
            .doc(value.id)
            .update({'commentId': value.id});
      }).then((value) {
        comments[commentIndex].replays_num =
            comments[commentIndex].replays_num + 1;
        getMyPosts(SocialCubit.get(context).user!.uId);
        replys.add(CommentModel(
            userId: user!.uId, dateTime: Timestamp.now(), comment: text));
        emit(SuccessCommentPostState());
      });
    }
  }

  Future<void> uploadReplyWithImage(
    String text,
    String postId,
    String commentId,
    int commentIndex,
  ) async {
    comments[commentIndex].replays_num = comments[commentIndex].replays_num + 1;
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Replys/${Uri.file(commentImage!.path).pathSegments.last}')
        .putFile(commentImage!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) {
        reply = CommentModel(
          comment: text,
          userId: user!.uId,
          dateTime: Timestamp.now(),
          image: value,
        );
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc(commentId)
            .collection('Replys')
            .add(reply!.toMap())
            .then((value) {
          FirebaseFirestore.instance
              .collection('Posts')
              .doc(postId)
              .collection('Comments')
              .doc(commentId)
              .collection('Replys')
              .doc(value.id)
              .update({'commentId': value.id});
        });
        emit(SuccessCommentPostState());
      }).catchError((error) {
        print(error);
        emit(ErrorCommentPostState());
      });
    }).catchError((error) {
      print(error);
      emit(ErrorCommentPostState());
    });
  }

  List<String> usersWhoLikeReply = [];
  Future<void> getReplys(String postId, String commentId) async {
    QuerySnapshot<Map<String, dynamic>>? likesTest;
    QuerySnapshot<Map<String, dynamic>>? replysTest;
    replys = [];
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .doc(commentId)
        .collection('Replys')
        .orderBy('dateTime', descending: true)
        .get()
        .then((value) async {
      for (int i = 0; i < value.docs.length; i++) {
        replysTest = null;
        likesTest = null;
        usersWhoLikeReply = [];
        likesTest = await value.docs[i].reference.collection('Likes').get();
        for (int j = 0; j < likesTest!.docs.length; j++) {
          usersWhoLikeReply.add(likesTest!.docs[j].data().keys.first);
        }
        replys.add(CommentModel.fromJson(
          json: value.docs[i].data(),
          id: value.docs[i].id,
          usersWhoLikeComment: usersWhoLikeReply,
          likes: likesTest!.docs.length,
        ));
      }
      emit(SuccessGettingCommentsState());
    }).catchError((error) {
      print(error);
      emit(ErrorGettingCommentsState());
    });
  }

  openReplays({
    required int commentIndex,
    bool? open,
  }) {
    if (open != null) {
      if (open == true) {
        for (int i = 0; i < comments.length; i++) {
          if (i == commentIndex) {
            comments[i].showReplays = true;
          } else {
            comments[i].showReplays = false;
          }
        }
      } else {
        comments[commentIndex].showReplays = false;
      }
    } else {
      if (comments[commentIndex].showReplays == false) {
        for (int i = 0; i < comments.length; i++) {
          if (i == commentIndex) {
            comments[i].showReplays = true;
          } else {
            comments[i].showReplays = false;
          }
        }
      } else {
        comments[commentIndex].showReplays = false;
      }
    }
    emit(ShowReplaysState());
  }

  Future likeReply(
      {required String postId,
      required String commentId,
      required String uId,
      required int index,
      required String replyId}) async {
    await getLikeReplyId(postId, commentId, uId, index, replyId);
  }

  Future getLikeReplyId(String postId, String commentId, String uId, int index,
      String replyId) async {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .doc(commentId)
        .collection('Replys')
        .doc(replyId)
        .get()
        .then((value) {
      CommentModel tempReply =
          CommentModel.fromJson(json: value.data()!, id: value.id);

      if (!replys[index].usersWhoLikeComment!.contains(user!.uId)) {
        print('likeeeeeeeeeeeeeeeeee');
        replys[index].usersWhoLikeComment!.add(user!.uId);
        replys[index].likes_num = replys[index].likes_num + 1;
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc(commentId)
            .collection('Replys')
            .doc(replyId)
            .collection('Likes')
            .add({uId: true}).then((value) {
          FirebaseFirestore.instance
              .collection('Posts')
              .doc(postId)
              .collection('Comments')
              .doc(commentId)
              .collection('Replys')
              .doc(replyId)
              .update({'myLikeId': value.id.toString()});
          emit(SuccessLikeCommentState());
        }).catchError((error) {
          print(error);
          emit(ErrorLikeCommentState());
        });
      } else {
        print('unLikeeeeeeeeeeeeeeeeeeeeee');
        replys[index].likes_num = replys[index].likes_num - 1;
        replys[index].usersWhoLikeComment!.remove(user!.uId);
        FirebaseFirestore.instance
            .collection('Posts')
            .doc(postId)
            .collection('Comments')
            .doc(commentId)
            .collection('Replys')
            .doc(replyId)
            .collection('Likes')
            .doc(tempReply.myLikeId)
            .delete()
            .then((value) {
          FirebaseFirestore.instance
              .collection('Posts')
              .doc(postId)
              .collection('Comments')
              .doc(commentId)
              .collection('Replys')
              .doc(replyId)
              .update({'myLikeId': ''}).then((value) {
            emit(SuccessUnlikeCommentState());
          }).catchError((error) {
            print(error);

            emit(ErrorUnlikeCommentState());
          });
        }).catchError((error) {
          print(error);

          emit(ErrorUnlikeCommentState());
        });
      }
    });
  }

  Future deleteReply(
    String postId,
    String commentId,
    String replyId,
  ) async {
    late int commentIndex;
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].commentId == commentId) {
        commentIndex = i;
        break;
      }
    }
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .doc(commentId)
        .collection('Replys')
        .doc(replyId)
        .delete()
        .then((value) {
      comments[commentIndex].replays_num =
          comments[commentIndex].replays_num - 1;
      getReplys(postId, commentId);
      emit(SuccessDeleteCommentState());
    }).catchError((error) {
      print(error);
      emit(ErrorDeleteCommentState());
    });
  }

  Future editReply(
    String postId,
    String commentId,
    String replyId,
    Map<String, dynamic> newData,
  ) async {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .doc(commentId)
        .collection('Replys')
        .doc(replyId)
        .update(newData)
        .then((value) {
      getReplys(postId, commentId);
      emit(SuccessUpdateCommentState());
    }).catchError((error) {
      print(error);
      emit(ErrorUpdateCommentState());
    });
  }

  late String? commentEditedImg;
  Future<void> editReplyWithImage(
      {required String postId,
      required String commentId,
      required String replyId,
      required String comment}) async {
    emit(LoadingUploadCommentEditedImageState());
    commentEditedImg = '';

    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Replys/${Uri.file(commentImage!.path).pathSegments.last}')
        .putFile(commentImage!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) {
        editReply(
            postId, commentId, replyId, {'image': value, 'comment': comment});
        emit(SuccessUploadCommentEditedImageState());
        print('done');
      }).catchError((error) {
        print(error);
        emit(ErrorUploadCommentEditedImageState());
      });
    }).catchError((error) {
      print(error);
      emit(ErrorUploadCommentEditedImageState());
    });
  }

  Future deleteComment(
    String postId,
    String commentId,
  ) async {
    late int postIndex;
    for (int i = 0; i < posts.length; i++) {
      if (posts[i].postId == postId) {
        postIndex = i;
        break;
      }
    }
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .doc(commentId)
        .delete()
        .then((value) {
      getComments(postId);
      posts[postIndex].comments_num = posts[postIndex].comments_num - 1;
      searchForComments = true;

      emit(SuccessDeleteCommentState());
    }).catchError((error) {
      print(error);
      emit(ErrorDeleteCommentState());
    });
  }

  Future editComment(
    String postId,
    String commentId,
    Map<String, dynamic> newData,
  ) async {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .doc(commentId)
        .update(newData)
        .then((value) {
      getComments(postId);
      commentImage = null;
      emit(SuccessUpdateCommentState());
    }).catchError((error) {
      print(error);
      emit(ErrorUpdateCommentState());
    });
  }

  late String? commentEditedImg2;
  Future<void> editCommentWithImage(
      {required String postId,
      required String commentId,
      required String comment}) async {
    emit(LoadingUploadCommentEditedImageState());
    commentEditedImg2 = '';

    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Comments/${Uri.file(commentImage!.path).pathSegments.last}')
        .putFile(commentImage!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) {
        editComment(postId, commentId, {'image': value, 'comment': comment});
        emit(SuccessUploadCommentEditedImageState());
        print('done');
      }).catchError((error) {
        print(error);
        emit(ErrorUploadCommentEditedImageState());
      });
    }).catchError((error) {
      print(error);
      emit(ErrorUploadCommentEditedImageState());
    });
  }

  bool? imagePicked = false;

  pickedImage(bool picked) {
    imagePicked = picked;

    emit(CheckImagePickedState());
  }

  Future deletePost(
    String postId,
  ) async {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .delete()
        .then((value) {
      noPosts = true;
      getPosts();
      emit(SuccessDeletePostState());
    }).catchError((error) {
      print(error);
      emit(ErrorDeletePostState());
    });
  }

  Future editPost(
    String postId,
    Map<String, dynamic> newData,
  ) async {
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .update(newData)
        .then((value) {
      noPosts = true;
      getPosts();
      emit(SuccessUpdatePostState());
    }).catchError((error) {
      print(error);
      emit(ErrorUpdatePostState());
    });
  }

  late String? PostEditedImg2;
  Future<void> editPostWithImage(
      {required String postId, required String text}) async {
    emit(LoadingUploadPostEditedImageState());
    PostEditedImg2 = '';

    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('Posts/${Uri.file(postImage!.path).pathSegments.last}')
        .putFile(postImage!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) {
        editPost(postId, {'postImage': value, 'text': text});
        emit(SuccessUploadPostEditedImageState());
        print('done');
      }).catchError((error) {
        print(error);
        emit(ErrorUploadPostEditedImageState());
      });
    }).catchError((error) {
      print(error);
      emit(ErrorUploadCommentEditedImageState());
    });
  }

  String save = 'Save';
  Future savePost(
    String postId,
    bool save,
  ) async {
    if (save == true) {
      this.save = 'Unsave';
    } else {
      this.save = 'Save';
    }
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .update({'saved': save}).then((value) {
      // noPosts = true;
      // getPosts();
      emit(SuccessUpdatePostState());
    }).catchError((error) {
      print(error);
      emit(ErrorUpdatePostState());
    });
  }

  realTimeSavePost(int postIndex, bool save) {
    posts[postIndex].saved = save;
    emit(SuccessUpdatePostState());
  }

  Future getPostLikes(
    String postId,
  ) async {
    usersWhoLikePost = [];
    usersWhoLikeThePost = [];
    FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Likes')
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        usersWhoLikePost.add(value.docs[i].data().keys.first);
      }
      for (int i = 0; i < users.length; i++) {
        for (int j = 0; j < usersWhoLikePost.length; j++) {
          if (users[i].uId == usersWhoLikePost[j]) {
            usersWhoLikeThePost.add(users[i]);
            break;
          }
        }
      }
      for (int j = 0; j < usersWhoLikePost.length; j++) {
        if (user!.uId == usersWhoLikePost[j]) {
          usersWhoLikeThePost.add(user!);
          break;
        }
      }
      emit(SuccessGetUsersWhoLikePostState());
    }).catchError((error) {
      print(error);
      emit(ErrorGetUsersWhoLikePostState());
    });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/App/postModel.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';
import 'package:social_app/shared/network/cacheHelper.dart';
import 'package:social_app/shared/styles/colors.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  var postCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        if (state is SuccessGetPostsState) {
          print('before pop :::::::::::::::::');
          Navigator.pop(context);
          print('after pop :::::::::::::::::');
        }
      },
      builder: (context, state) {
        var cubit = SocialCubit.get(context);

        print('postScreen: postImage : ${cubit.postImage}');
        return Scaffold(
            backgroundColor: CacheHelper.getValue(key: 'lightMode') == true
                ? Colors.white
                : darkBackground,
            appBar: AppBar(
              title: Text(
                'Create Post',
                style: TextStyle(
                  fontSize: 16,
                  color: CacheHelper.getValue(key: 'lightMode') == true
                      ? lightTextColor
                      : darkTextcolor,
                ),
              ),
              titleSpacing: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: CacheHelper.getValue(key: 'lightMode') == true
                      ? lightTextColor
                      : darkTextcolor,
                ),
                onPressed: () {
                  cubit.postImage = null;
                  postCtrl.text = '';
                  Navigator.pop(context);
                },
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      cubit.createPost(text: postCtrl.text, context: context);
                    },
                    child: Text(
                      'Post',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16,
                          ),
                    )),
                const SizedBox(
                  width: 8,
                )
              ],
            ),
            body: Container(
              width: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state is LoadingCreatePostState)
                      Column(
                        children: [
                          Container(
                              height: 4,
                              width: double.infinity,
                              child: const LinearProgressIndicator()),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                                radius: 28,
                                backgroundImage:
                                    NetworkImage(cubit.user!.userImage)),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              cubit.user!.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontSize: 16,
                                    color: CacheHelper.getValue(
                                                key: 'lightMode') ==
                                            true
                                        ? lightTextColor
                                        : darkTextcolor,
                                  ),
                            ),
                          ]),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 20),
                            child: Container(
                              width: double.infinity,
                              height: 160,
                              child: TextFormField(
                                controller: postCtrl,
                                expands: true,
                                maxLines: null,
                                minLines: null,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'What\'s on your mind..',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .copyWith(
                                        fontSize: 14,
                                        color: CacheHelper.getValue(
                                                    key: 'lightMode') ==
                                                true
                                            ? lightTextColor
                                            : Colors.grey[400],
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          if (cubit.postImage != null)
                            Stack(
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Container(
                                  width: double.infinity,
                                  child: Image(
                                    height: 220,
                                    fit: BoxFit.fitWidth,
                                    image: FileImage(cubit.postImage!),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      cubit.removeImagePost();
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            child: InkWell(
                              onTap: () {
                                cubit.getPhotoFromGallary(image: 'post');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: defaultColor,
                                    size: 24,
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    'Add Photo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontSize: 14,
                                          color: CacheHelper.getValue(
                                                      key: 'lightMode') ==
                                                  true
                                              ? lightTextColor
                                              : darkTextcolor,
                                        ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                              onPressed: () {},
                              child: Text(
                                '# Tags',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      color: CacheHelper.getValue(
                                                  key: 'lightMode') ==
                                              true
                                          ? lightTextColor
                                          : darkTextcolor,
                                    ),
                              )),
                        )
                      ],
                    )
                  ]),
            ));
      },
    );
  }
}

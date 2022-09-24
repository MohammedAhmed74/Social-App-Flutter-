import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/models/App/postModel.dart';
import 'package:social_app/models/Users/userModel.dart';
import 'package:social_app/modules/UsersProfile/usersProfile.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';

class LikesScreen extends StatelessWidget {
  LikesScreen({Key? key, required this.userWhoLikeIds}) : super(key: key);
  List<String> userWhoLikeIds;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        if (state is SuccessGetUsersWhoLikePostState) {
          print(SocialCubit.get(context).usersWhoLikeThePost[0].name);
        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Likes',
                style: TextStyle(fontSize: 16),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: ConditionalBuilder(
              condition: userWhoLikeIds.isNotEmpty,
              builder: (context) => ListView.separated(
                  itemBuilder: (context, index) =>
                      buildUserItem(context, userWhoLikeIds[index]),
                  separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Container(
                          height: 0.5,
                          color: Colors.grey[300],
                        ),
                      ),
                  itemCount: userWhoLikeIds.length),
              fallback: (context) {
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
                        'No like for this post.',
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
              },
            ));
      },
    );
  }

  Widget buildUserItem(BuildContext context, String userId) {
    late UserModel user;
    if (SocialCubit.get(context).user!.uId == userId) {
      user = SocialCubit.get(context).user!;
    } else {
      for (int i = 0; i < SocialCubit.get(context).users.length; i++) {
        if (SocialCubit.get(context).users[i].uId == userId) {
          user = SocialCubit.get(context).users[i];
          break;
        }
      }
    }
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: InkWell(
          onTap: () {
            SocialCubit.get(context).getMyPosts(user.uId);
            SocialCubit.get(context).searchForPostsForMe(true);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersProfile(userUid: user.uId),
                ));
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(user.userImage),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                user.name,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

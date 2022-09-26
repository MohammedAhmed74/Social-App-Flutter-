import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/models/Users/userModel.dart';
import 'package:social_app/modules/Chats/chatingScreen.dart';
import 'package:social_app/shared/cubit/socialCubit.dart';
import 'package:social_app/shared/cubit/socialStates.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cubit = SocialCubit.get(context);
    return BlocConsumer<SocialCubit, SocialStates>(
        builder: (context, state) {
          return ConditionalBuilder(
              condition: cubit.users.isNotEmpty,
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
              builder: (context) {
                print('Users.length ==== ${cubit.users.length}');
                return ListView.separated(
                    itemBuilder: ((context, index) =>
                        buildUserItem(context, cubit.users[index])),
                    separatorBuilder: ((context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            height: 0.5,
                            color: Colors.grey[600],
                          ),
                        )),
                    itemCount: cubit.users.length);
              });
        },
        listener: (context, state) {});
  }

  Widget buildUserItem(BuildContext context, UserModel user) {
    return InkWell(
      onTap: () {
        SocialCubit.get(context).seaarchForMessages(true);
        SocialCubit.get(context).messages = [];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatingScreen(receiver: user)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
          ],
        ),
      ),
    );
  }
}

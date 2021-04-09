import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

//code-splitting
import '../models/user.dart';
import '../widgets/chips.dart';

class UserModal extends HookWidget {
  final String id;
  final void Function(String) showSnackbarFromParent;
  const UserModal(this.id, this.showSnackbarFromParent);

  @override
  Widget build(BuildContext context) {
    final user = useState(UserData());
    final loading = useState(true);
    final error = useState('');

    refresh() async {
      loading.value = true;
      final resp = await UserData.getInfoCard(id);
      if (resp.runtimeType == String) {
        error.value = resp;
      } else {
        user.value = resp;
      }
      loading.value = false;
    }

    useEffect(() {
      refresh();
      return;
    }, []);

    if (!loading.value) {
      if (error.value.isNotEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
          showSnackbarFromParent(error.value);
        });
        return Container();
      }
    }
    final body = user.value;
    return loading.value
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: body.color),
                height: 88,
                alignment: Alignment.topRight,
                child: FollowButton(user: body),
              ),
              Padding(
                padding: Pad(all: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: kElevationToShadow[2],
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      foregroundDecoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Image.network(body.imageUrl, height: 96),
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(body.name, style: Theme.of(context).textTheme.headline5),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class FollowButton extends HookWidget {
  final UserData user;
  const FollowButton({this.user});

  @override
  Widget build(BuildContext context) {
    return Badge(
      toAnimate: false,
      elevation: 0,
      shape: BadgeShape.square,
      badgeContent: InkWell(
          child: Padding(
            padding: Pad(all: 8),
            child: Text('follow'),
          ),
          onTap: () {}),
      padding: Pad.zero,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6)),
      badgeColor: Theme.of(context).scaffoldBackgroundColor,
    );
    /*return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5)),
      ),
      child: TextButton(
        child: Padding(
          padding: Pad(all: 8),
          child: Text('follow'),
        ),
        onPressed: () => showSnackbar(context, 'yee haw follow'),
      ),
    );*/
  }
}

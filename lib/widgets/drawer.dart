import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:manycooks/auth/blocs/sign_in_bloc.dart';
import 'package:manycooks/auth/models/config.dart';
import 'package:manycooks/auth/signIn.dart';
import 'package:manycooks/auth/utils/next_screen.dart';
import 'package:provider/provider.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({Key? key}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var textCtrl = TextEditingController();

  final List title = [
    'Categories',
    'Explore',
    'Saved Items',
    'About App',
    'Rate & Review'
  ];

  final List icons = [
    FontAwesomeIcons.dashcube,
    FontAwesomeIcons.solidCompass,
    FontAwesomeIcons.solidHeart,
    FontAwesomeIcons.info,
    FontAwesomeIcons.star
  ];

  Future openLogoutDialog(context1) async {
    showDialog(
        context: context1,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Logout?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Text('Do you really want to Logout?'),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  final sb = context.read<SignInBloc>();
                  Navigator.pop(context);
                  sb.userSignout().then(
                      (_) => nextScreenCloseOthers(context, SignInPage()));
                },
              ),
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  aboutAppDialog() {
    showDialog(
        context: context,
        builder: (BuildContext coontext) {
          return AboutDialog(
            applicationVersion: Config().appVersion,
            applicationName: Config().appName,
            applicationIcon: Image(
              height: 40,
              width: 40,
              image: AssetImage(Config().appIcon),
            ),
            applicationLegalese: 'Designed & Developed By\nNivlec Tech.',
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 20, left: 0),
                alignment: Alignment.center,
                height: 100,
                child: Text(
                  Config().appName.toUpperCase(),
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                // height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        LinearGradient(colors: [Colors.blueGrey, Colors.blue])),
                child: CircleAvatar(
                    radius: 44.5,
                    // ignore: unnecessary_null_comparison
                    backgroundImage: CachedNetworkImageProvider(
                        !context.watch<SignInBloc>().isSignedIn ||
                                context
                                        .watch<SignInBloc>()
                                        // ignore: unnecessary_null_comparison
                                        .imageUrl ==
                                    null
                            ? Config().guestUserImage
                            : context.watch<SignInBloc>().imageUrl)
                    //     .image),
                    ),
              ),
              Divider(
                thickness: 5,
                height: 50,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: title.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: Container(
                        height: 45,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                icons[index],
                                color: Colors.grey,
                                size: 22,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(title[index],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                        ),
                      ),
                      onTap: () {},
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
              ),
              Column(
                children: [
                  !context.watch<SignInBloc>().isSignedIn
                      ? Container()
                      : Column(
                          children: [
                            Divider(),
                            InkWell(
                              child: Container(
                                height: 45,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        FontAwesomeIcons.signOutAlt,
                                        color: Colors.grey,
                                        size: 22,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text('Logout',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                openLogoutDialog(context);
                              },
                            ),
                          ],
                        ),
                ],
              ),
            ],
          )),
    );
  }
}

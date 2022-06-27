import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manycooks/text/cook.dart';
// import 'package:manycooks/text/text_editor.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'blocs/internet_bloc.dart';
import 'blocs/sign_in_bloc.dart';
import 'models/config.dart';
import 'utils/next_screen.dart';
import 'utils/snacbar.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key? key, this.closeDialog}) : super(key: key);

  final closeDialog;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController _buttonController =
      RoundedLoadingButtonController();

  handleGuestUser() async {
    final sb = context.read<SignInBloc>();
    await sb.setGuestUser();
    // ignore: unnecessary_null_comparison
    if (widget.closeDialog == null || widget.closeDialog == false) {
      nextScreenCloseOthers(context, EditorPage(chapterName: 'Guest Chapter'));
    } else {
      Navigator.pop(context);
    }
  }

  Future handleGoogleSignIn() async {
    final sb = context.read<SignInBloc>();
    final ib = context.read<InternetBloc>();
    await ib.checkInternet();
    if (ib.hasInternet == false) {
      openSnacbar(_scaffoldKey, 'Check your internet connection!');
    } else {
      await sb.signInWithGoogle().then((_) {
        if (sb.hasError == true) {
          openSnacbar(_scaffoldKey, 'Something is wrong. Please try again.');
          _buttonController.reset();
        } else {
          sb.checkUserExists().then((isUserExisted) async {
            if (isUserExisted) {
              await sb
                  .getUserDataFromFirebase(sb.uid)
                  .then((value) => sb.guestSignout())
                  .then((value) => sb
                      .saveDataToSP()
                      .then((value) => sb.setSignIn().then((value) {
                            _buttonController.success();
                            handleAfterSignupGoogle();
                          })));
            } else {
              sb.getTimestamp().then((value) => sb
                  .saveToFirebase()
                  .then((value) => sb.increaseUserCount())
                  .then((value) => sb.guestSignout())
                  .then((value) => sb
                      .saveDataToSP()
                      .then((value) => sb.setSignIn().then((value) {
                            _buttonController.success();
                            handleAfterSignupGoogle();
                          }))));
            }
          });
        }
      });
    }
  }

  handleAfterSignupGoogle() {
    Future.delayed(Duration(milliseconds: 1000)).then((f) {
      if (widget.closeDialog == null || widget.closeDialog == false) {
        nextScreenCloseOthers(
            context, EditorPage(chapterName: 'Guest Chapter'));
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          // actions: [
          // widget.closeDialog == null || widget.closeDialog == false
          //     ? TextButton(
          //         onPressed: () {
          //           handleGuestUser();
          //         },
          //         child: Text('Skip'))
          //     : Container()
          // ],
        ),
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 90, left: 40, right: 40, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image(
                        image: AssetImage(Config().splashIcon),
                        height: 80,
                        width: 80,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        'Welcome to ${Config().appName}!',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Expanded(
                        child: Text(
                          'Be the genesis of a story and let many other cooks get to branch different versions of it!',
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.70,
                          child: RoundedLoadingButton(
                            child: Wrap(
                              children: [
                                Icon(
                                  FontAwesomeIcons.google,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  'Sign In with Google',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                )
                              ],
                            ),
                            controller: _buttonController,
                            onPressed: () => handleGoogleSignIn(),
                            width: MediaQuery.of(context).size.width * 0.80,
                            color: Colors.blueAccent,
                            elevation: 0,
                            borderRadius: 25,
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ));
  }
}

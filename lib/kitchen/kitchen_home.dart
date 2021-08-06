// ignore: import_of_legacy_library_into_null_safe
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manycooks/auth/blocs/data_bloc.dart';
import 'package:manycooks/auth/blocs/internet_bloc.dart';
import 'package:manycooks/auth/blocs/sign_in_bloc.dart';
import 'package:manycooks/auth/models/config.dart';
import 'package:manycooks/auth/utils/dialog.dart';
import 'package:manycooks/kitchen/allTags.dart';
import 'package:manycooks/kitchen/myTags.dart';
import 'package:manycooks/pages/internet.dart';
import 'package:manycooks/text/text_editor.dart';
import 'package:manycooks/widgets/drawer.dart';
import 'package:manycooks/widgets/loading_animation.dart';
import 'package:provider/provider.dart';

class KitchenHomePage extends StatefulWidget {
  KitchenHomePage({Key? key}) : super(key: key);

  @override
  _KitchenHomePageState createState() => _KitchenHomePageState();
}

class _KitchenHomePageState extends State<KitchenHomePage> {
  int listIndex = 0;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future getData() async {
    Future.delayed(Duration(milliseconds: 0)).then((f) {
      final sb = context.read<SignInBloc>();
      final db = context.read<DataBloc>();
      sb
          .getUserDatafromSP()
          .then((value) => db.getData())
          .then((value) => db.getCategories());
    });
  }

  @override
  void initState() {
    // OneSignal.shared.init(Config().onesignalAppId);
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final db = context.watch<DataBloc>();
    final ib = context.watch<InternetBloc>();
    final sb = context.watch<SignInBloc>();

    return ib.hasInternet == false
        ? NoInternetPage()
        : Scaffold(
            key: _scaffoldKey,
            drawer: DrawerWidget(),
            appBar: AppBar(
              actions: <Widget>[
                InkWell(
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(!context
                                        .watch<SignInBloc>()
                                        .isSignedIn ||
                                    context
                                            .watch<SignInBloc>()
                                            // ignore: unnecessary_null_comparison
                                            .imageUrl ==
                                        null
                                ? Config().guestUserImage
                                : context.watch<SignInBloc>().imageUrl))),
                  ),
                  onTap: () {
                    !sb.isSignedIn
                        ? showGuestUserInfo(context)
                        : showUserInfo(context, sb.name, sb.email, sb.imageUrl);
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                // IconButton(
                //   icon: Icon(
                //     Icons.more,
                //     size: 16,
                //     color: Colors.black,
                //   ),
                //   onPressed: () {},
                // )
              ],
              // leading: IconButton(
              //   icon: Icon(
              //     FontAwesomeIcons.stream,
              //     size: 16,
              //     color: Colors.black,
              //   ),
              //   onPressed: () {},
              // ),
              title: Text(
                'Kitchen',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      CarouselSlider(
                        options: CarouselOptions(
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                            initialPage: 0,
                            viewportFraction: 0.90,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            height: h * 0.70,
                            onPageChanged: (int index, reason) {
                              setState(() => listIndex = index);
                            }),
                        items: db.alldata.length == 0
                            ? [0, 1]
                                .take(1)
                                .map((f) => LoadingWidget())
                                .toList()
                            : db.alldata.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        child: InkWell(
                                          child: CachedNetworkImage(
                                            imageUrl: i['image url'],
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Hero(
                                              tag: i['timestamp'],
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 10,
                                                    bottom: 50),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    boxShadow: <BoxShadow>[
                                                      BoxShadow(
                                                          color: Colors.black45,
                                                          blurRadius: 20,
                                                          offset: Offset(5, 30))
                                                    ],
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30,
                                                            bottom: 40),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              Config().hashTag,
                                                              style: TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14),
                                                            ),
                                                            Text(
                                                              i['category'],
                                                              style: TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 25),
                                                            )
                                                          ],
                                                        ),
                                                        Spacer(),
                                                        Icon(
                                                          Icons.favorite,
                                                          size: 25,
                                                          color: Colors.white
                                                              .withOpacity(0.5),
                                                        ),
                                                        SizedBox(width: 2),
                                                        Text(
                                                          i['loves'].toString(),
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.7),
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        SizedBox(
                                                          width: 15,
                                                        )
                                                      ],
                                                    )),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                LoadingWidget(),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.error,
                                              size: 40,
                                            ),
                                          ),
                                          onTap: () {},
                                        ));
                                  },
                                );
                              }).toList(),
                      ),
                      Positioned(
                        top: 40,
                        left: w * 0.23,
                        child: Text(
                          'BROTH OF THE DAY',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: w * 0.34,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: DotsIndicator(
                            dotsCount: 5,
                            position: listIndex.toDouble(),
                            decorator: DotsDecorator(
                              activeColor: Colors.black,
                              color: Colors.black,
                              spacing: EdgeInsets.all(3),
                              size: const Size.square(8.0),
                              activeSize: const Size(40.0, 6.0),
                              activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  Container(
                    height: 50,
                    width: w * 0.80,
                    decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.black45,
                              blurRadius: 20,
                              offset: Offset(5, 30))
                        ],
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(FontAwesomeIcons.penFancy,
                              color: Colors.black87, size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TextEditor()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.link,
                              color: Colors.black87, size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyTags()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.cocktail,
                              color: Colors.black87, size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AllTags()));
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  )
                ],
              ),
            ),
          );
  }
}

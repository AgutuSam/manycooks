// ignore: import_of_legacy_library_into_null_safe
import 'dart:math';
import 'package:intl/intl.dart';

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
import 'package:manycooks/kitchen/nouvelle.dart';
import 'package:manycooks/pages/internet.dart';
import 'package:manycooks/widgets/drawer.dart';
import 'package:manycooks/widgets/loading_animation.dart';
import 'package:provider/provider.dart';

class KitchenHomePage extends StatefulWidget {
  KitchenHomePage({Key? key}) : super(key: key);

  @override
  _KitchenHomePageState createState() => _KitchenHomePageState();
}

class _KitchenHomePageState extends State<KitchenHomePage> {
  final rand = Random();
  int listIndex = 0;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var f = NumberFormat.compact(locale: "en_IN");

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
                            : db.alldata.map((res) {
                                var i = res.data();
                                var categories = i['categories']
                                    .entries
                                    .map((v) => v.value)
                                    .toList();
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        child: InkWell(
                                          child: Stack(
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: i['cover'],
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
                                                            BorderRadius
                                                                .circular(20),
                                                        boxShadow: <BoxShadow>[
                                                          BoxShadow(
                                                              color: Colors
                                                                  .black45,
                                                              blurRadius: 20,
                                                              offset:
                                                                  Offset(5, 30))
                                                        ],
                                                        image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover)),
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                bottom: 20),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            Expanded(
                                                              flex: 9,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    '#' +
                                                                        i['ownerName'],
                                                                    style: TextStyle(
                                                                        decoration: TextDecoration.none,
                                                                        background: Paint()
                                                                          ..strokeWidth =
                                                                              8.0
                                                                          ..color = Colors
                                                                              .black
                                                                              .withOpacity(0.5)
                                                                          ..style =
                                                                              PaintingStyle.fill
                                                                          ..strokeJoin = StrokeJoin.round,
                                                                        fontSize: 14),
                                                                  ),
                                                                  Container(
                                                                    constraints:
                                                                        BoxConstraints(
                                                                      maxHeight:
                                                                          95.0,
                                                                    ),
                                                                    child: Wrap(
                                                                      clipBehavior:
                                                                          Clip.antiAliasWithSaveLayer,
                                                                      children: List<
                                                                              Widget>.generate(
                                                                          categories
                                                                              .length,
                                                                          (int
                                                                              index) {
                                                                        return Transform(
                                                                          transform: new Matrix4
                                                                              .identity()
                                                                            ..scale(0.8),
                                                                          child:
                                                                              Chip(
                                                                            elevation:
                                                                                6.0,
                                                                            padding:
                                                                                EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                                            shape:
                                                                                StadiumBorder(
                                                                              side: BorderSide(
                                                                                  color: Color.fromARGB(
                                                                                    rand.nextInt(150),
                                                                                    rand.nextInt(255),
                                                                                    rand.nextInt(255),
                                                                                    rand.nextInt(255),
                                                                                  ),
                                                                                  style: BorderStyle.solid,
                                                                                  width: 1.2),
                                                                            ),
                                                                            backgroundColor:
                                                                                Colors.white,
                                                                            label:
                                                                                Text(
                                                                              categories[index],
                                                                              style: TextStyle(fontSize: 18.0, color: Colors.black45, letterSpacing: 2.0, fontWeight: FontWeight.w300),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    LoadingWidget(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.error,
                                                  size: 40,
                                                ),
                                              ),
                                              //  Container(
                                              //   height: h * 0.70,
                                              //   width: MediaQuery.of(context)
                                              //           .size
                                              //           .width *
                                              //       0.9,
                                              //   margin: EdgeInsets.symmetric(
                                              //       horizontal: 0),
                                              //   color: Colors.black
                                              //       .withOpacity(0.5),
                                              // ),
                                              Positioned(
                                                right: 30,
                                                top: 20,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.favorite,
                                                        color: Colors.white,
                                                        size: 25),
                                                    Text(
                                                      f
                                                          .format(i['loves'])
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.7),
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                right: 30,
                                                top: 20,
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.favorite,
                                                        color: Colors.white,
                                                        size: 25),
                                                    Text(
                                                      f
                                                          .format(i['loves'])
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.7),
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 50,
                                                left: w * 0.05,
                                                width: w * 0.8,
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: w,
                                                  ),
                                                  child: Text(
                                                    i['name'].toUpperCase(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {},
                                        ));
                                  },
                                );
                              }).toList(),
                      ),
                      // Positioned(
                      //   top: 40,
                      //   left: w * 0.23,
                      //   child: Text(
                      //     'BROTH OF THE DAY',
                      //     style: TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 25,
                      //         fontWeight: FontWeight.bold),
                      //   ),
                      // ),
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
                                    builder: (context) => Nouvelle()));
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

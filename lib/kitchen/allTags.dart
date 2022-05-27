import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:manycooks/auth/models/config.dart';
import 'package:manycooks/widgets/cached_image.dart';

class AllTags extends StatefulWidget {
  AllTags({Key? key}) : super(key: key);

  @override
  _AllTagsState createState() => _AllTagsState();
}

class _AllTagsState extends State<AllTags> with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var f = NumberFormat.compact(locale: "en_IN");

  late ScrollController controller;
  // late DocumentSnapshot _lastVisible;
  late bool _isLoading;
  // ignore: deprecated_member_use
  late List<DocumentSnapshot> _data = <DocumentSnapshot>[];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  Future<Null> _getData() async {
    QuerySnapshot data;
    // ignore: unnecessary_null_comparison
    // if (_lastVisible == null)
    //   data = await firestore
    //       .collection('food')
    //       .orderBy('loves', descending: true)
    //       .limit(10)
    //       .get();
    // else
    data = await firestore
        .collection('food')
        .orderBy('loves', descending: true)
        // .startAfter([_lastVisible['loves']])
        .limit(10)
        .get();

    // ignore: unnecessary_null_comparison
    if (data != null && data.docs.length > 0) {
      // _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _data.addAll(data.docs);
        });
      }
    } else {
      setState(() => _isLoading = false);
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('No more posts!'),
        ),
      );
    }
    return null;
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        // _getData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Public Directory',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StaggeredGridView.countBuilder(
              controller: controller,
              crossAxisCount: 4,
              itemCount: _data.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < _data.length) {
                  final DocumentSnapshot d = _data[index];
                  var categories =
                      d['categories'].entries.map((v) => v.value).toList();
                  return InkWell(
                    child: Stack(
                      children: <Widget>[
                        Hero(
                            tag: 'popular$index',
                            child: cachedImage(d['cover'])),
                        Positioned(
                          bottom: 30,
                          left: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '#' + d['ownerName'],
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    background: Paint()
                                      ..strokeWidth = 8.0
                                      ..color = Colors.black.withOpacity(0.5)
                                      ..style = PaintingStyle.fill
                                      ..strokeJoin = StrokeJoin.round,
                                    fontSize: 14),
                              ),
                              Text(
                                // d['category'],
                                categories.first,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 20,
                          child: Row(
                            children: [
                              Icon(Icons.favorite,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 25),
                              Text(
                                f.format(d['loves']).toString(),
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {},
                  );
                }

                return Center(
                  child: new Opacity(
                    opacity: _isLoading ? 1.0 : 0.0,
                    child: new SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: CupertinoActivityIndicator()),
                  ),
                );
              },
              staggeredTileBuilder: (int index) =>
                  new StaggeredTile.count(2, index.isEven ? 4 : 3),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: EdgeInsets.all(15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

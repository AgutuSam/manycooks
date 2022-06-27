import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manycooks/auth/blocs/sign_in_bloc.dart';
import 'package:manycooks/text/cook.dart';
import 'package:manycooks/widgets/drawer.dart';
import 'package:provider/provider.dart';

class Recipe extends StatefulWidget {
  Recipe({this.id, Key? key}) : super(key: key);
  final String? id;

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  final CollectionReference foodCol =
      FirebaseFirestore.instance.collection('food');

  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  TextEditingController chapterName = TextEditingController();

  String bookName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    final sb = context.watch<SignInBloc>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text(
          'Recipe',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: foodCol.doc(widget.id).get(),
          builder: (BuildContext context, snapshot) {
            Stream<QuerySnapshot<Map<String, dynamic>>> chapters =
                foodCol.doc(widget.id).collection('chapitres').snapshots();
            if (!snapshot.hasData) {
              return Container(
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            } else {
              Map data = snapshot.data?.data() as Map;
              setState(() {
                bookName = data['name'];
              });
              return Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Stack(
                      children: [
                        ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
                          },
                          blendMode: BlendMode.dstIn,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            width: w,
                            constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height * 0.45),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: data['cover'].isNotEmpty ||
                                            data.isNotEmpty
                                        ? Image.network(data['cover']).image
                                        : Image.asset('assets/defaultcover.jpg')
                                            .image,
                                    fit: BoxFit.cover)),
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black,
                                Colors.grey,
                                Colors.transparent
                              ],
                            ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
                          },
                          blendMode: BlendMode.dstIn,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            width: w,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                            ),
                            constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height * 0.35),
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
                              data['name'].toString().toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: data['titleColor'] != null ||
                                          data['titleColor'] < 1
                                      ? Color(data['titleColor']).withOpacity(1)
                                      : Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        sb.uid.toString() != data['owner'].toString()
                            ? Container()
                            : Positioned(
                                top: 150,
                                left: w * 0.05,
                                width: w * 0.8,
                                child: Center(
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    height: 45.0,
                                    child: RaisedButton.icon(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color: Color.fromRGBO(
                                                  147, 196, 125, .4))),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                content: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: <Widget>[
                                                    Form(
                                                      key: _formKey,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  chapterName,
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                        null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'Chapter Name cannot be empty';
                                                                }
                                                                return null;
                                                              },
                                                              style: TextStyle(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        147,
                                                                        196,
                                                                        125,
                                                                        1),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {});
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                focusColor:
                                                                    Colors
                                                                        .white,
                                                                //add prefix icon
                                                                prefixIcon:
                                                                    Icon(
                                                                  Icons.book,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          147,
                                                                          196,
                                                                          125,
                                                                          1),
                                                                ),

                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),

                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: const BorderSide(
                                                                      color: Color.fromRGBO(
                                                                          147,
                                                                          196,
                                                                          125,
                                                                          1),
                                                                      width:
                                                                          1.0),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                                fillColor: Color
                                                                    .fromRGBO(
                                                                        147,
                                                                        196,
                                                                        125,
                                                                        1),

                                                                hintText:
                                                                    "Chapter Name",

                                                                //make hint text
                                                                hintStyle:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          147,
                                                                          196,
                                                                          125,
                                                                          1),
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      "verdana_regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),

                                                                //create lable
                                                                labelText:
                                                                    'Chapter Name',
                                                                //lable style
                                                                labelStyle:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          147,
                                                                          196,
                                                                          125,
                                                                          1),
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      "verdana_regular",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: RaisedButton(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12.0),
                                                                  side: BorderSide(
                                                                      color: Color.fromRGBO(
                                                                          147,
                                                                          196,
                                                                          125,
                                                                          1))),
                                                              child: Text(
                                                                  "Submit"),
                                                              onPressed: () {
                                                                if (_formKey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  _formKey
                                                                      .currentState!
                                                                      .save();
                                                                  foodCol
                                                                      .doc(widget
                                                                          .id)
                                                                      .collection(
                                                                          'chapitres')
                                                                      .add({
                                                                    'title': chapterName
                                                                        .text
                                                                        .toString(),
                                                                    'editors': {
                                                                      '0': sb
                                                                          .uid
                                                                          .toString()
                                                                    }
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                      padding: EdgeInsets.all(10.0),
                                      color: Color.fromRGBO(147, 196, 125, .3),
                                      textColor: Colors.white,
                                      icon: Icon(Icons.add),
                                      label: Text("Add Chapter",
                                          style: TextStyle(fontSize: 15)),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.black45],
                        ).createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height));
                      },
                      blendMode: BlendMode.dstIn,
                      child: StreamBuilder<QuerySnapshot>(
                          stream: chapters,
                          builder: (context, querysnapshot) {
                            List<DocumentSnapshot> data =
                                querysnapshot.data?.docs ?? [];

                            return data.length < 1
                                ? Center(
                                    child: Text('No Chapters Yet'),
                                  )
                                : Container(
                                    width: double.infinity,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children:
                                            data.asMap().entries.map((item) {
                                          return Card(
                                            color: Colors.grey.shade900,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12))),
                                            elevation: 8,
                                            child: ListTile(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditorPage(
                                                              bookName:
                                                                  bookName,
                                                              chapterName:
                                                                  item.value[
                                                                      'title'],
                                                              mainEditor: item
                                                                          .value[
                                                                      'editors']
                                                                  ['0'],
                                                              readOnly: item
                                                                  .value[
                                                                      'editors']
                                                                  .entries
                                                                  .map((val) =>
                                                                      val.value)
                                                                  .toList()
                                                                  .contains(sb
                                                                      .uid
                                                                      .toString()),
                                                            )));
                                              },
                                              leading: CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.white,
                                                child: Text(
                                                  (item.key + 1).toString(),
                                                  style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        147, 196, 125, 1),
                                                  ),
                                                ),
                                              ),
                                              title: Transform.translate(
                                                offset: Offset(-8, 0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text('Chapter' +
                                                        (item.key + 1)
                                                            .toString()),
                                                    Text(' : '),
                                                    Text(item.value['title']
                                                        .toString()
                                                        .toUpperCase())
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                          }),
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}

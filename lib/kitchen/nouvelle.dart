import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manycooks/extras/genres.dart';
import 'package:manycooks/widgets/drawer.dart';
import 'package:manycooks/widgets/input.dart';
import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';

import '../auth/blocs/sign_in_bloc.dart';

class Nouvelle extends StatefulWidget {
  const Nouvelle({Key? key}) : super(key: key);

  @override
  State<Nouvelle> createState() => _NouvelleState();
}

class _NouvelleState extends State<Nouvelle> {
  CollectionReference cuisines = FirebaseFirestore.instance.collection('food');
  FirebaseStorage coverRef = FirebaseStorage.instance;

  final rand = Random();
  final TextEditingController title = TextEditingController();

  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var metaData;
  var categories;

  // Image Picker
  // List<File> _images = [];
  late File _image; // Used only if you need a single picture

  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  Color pickerButtonColor = Colors.white;
  Color pickerBrushColor = Colors.blueGrey;

// ValueChanged<Color> callback
  void changeColor(Color color) {
    getOppColor(color);
    setState(() => pickerButtonColor = color);
  }

  getOppColor(Color color) {
    int r = 0;
    int g = 0;
    int b = 0;

// Counting the perceptive luminance - human eye favors green color...
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    if (luminance > 0.5) {
      r = 96; // bright colors - black font
      g = 125; // bright colors - black font
      b = 139; // bright colors - black font
    } else {
      r = 255; // dark colors - white font
      g = 255; // dark colors - white font
      b = 255; // dark colors - white font
    }

    setState(() => pickerBrushColor = Color.fromARGB(color.alpha, r, g, b));
  }

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile;
    // Let user select photo from gallery
    if (gallery) {
      pickedFile = (await picker.pickImage(
        source: ImageSource.gallery,
      ));
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile = (await picker.pickImage(
        source: ImageSource.camera,
      ));
    }

    setState(() {
      if (pickedFile != null) {
        // _images.add(File(pickedFile.path));
        _image = File(pickedFile.path); // Use if you only need a single picture

      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> uploadFile(File _image) async {
    String returnURL = '';
    Reference ref =
        coverRef.ref().child('covers/${Path.basename(_image.path)}');
    TaskSnapshot uploadTask = await ref.putFile(_image);
    // uploadTask.whenComplete(() async {
    //   print('File Uploaded!');
    // });
    // await ref.getDownloadURL().then((fileURL) {
    //   returnURL = fileURL;
    // });

    returnURL = await uploadTask.ref.getDownloadURL();

    return returnURL;
  }

  Future<void> saveCuisine(File image, var user) async {
    String imageURL = await uploadFile(image);
    var categoriesMap = {};
    categories
        .asMap()
        .forEach((index, val) => categoriesMap[index.toString()] = val);
    var data = {
      'categories': categoriesMap,
      'name': metaData['title'],
      'titleColor': pickerButtonColor.value,
      'ownerName': user.name,
      'owner': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
      "cover": imageURL,
      'loves': 0
    };
    print('HHHHHHHHHHHHHH');
    print(data);
    print('HHHHHHHHHHHHHH');
    cuisines.add(data);
  }

  @override
  void initState() {
    metaData = {};
    categories = [];
    _image = File('');
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
          'New Cuisine',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    width: w * 0.9,
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.45),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                            image: _image.existsSync()
                                ? Image.file(_image).image
                                : Image.asset('assets/defaultcover.jpg').image,
                            fit: BoxFit.cover)),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    width: w * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.45),
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
                        metaData.containsKey('title')
                            ? metaData['title'].toUpperCase()
                            : 'TITLE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: h * 0.33,
                    left: w * 0.05,
                    width: w * 0.8,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 95.0,
                      ),
                      child: Wrap(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        children: List<Widget>.generate(categories.length,
                            (int index) {
                          return Transform(
                            transform: new Matrix4.identity()..scale(0.8),
                            child: Chip(
                              elevation: 6.0,
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 2),
                              shape: StadiumBorder(
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
                              backgroundColor: Colors.white,
                              label: Text(
                                categories[index],
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black45,
                                    letterSpacing: 2.0,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: w * 0.6,
                    child: InputCard(
                      'Title',
                      (val) {
                        setState(() {
                          metaData['title'] = title.text;
                        });
                        return val;
                      },
                      inputController: title,
                      isIcon: Icon(Icons.title).icon,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 20, top: 10),
                      width: w * 0.2,
                      child: IconButton(
                        onPressed: () {
                          // raise the [showDialog] widget
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Pick a color!'),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: pickerColor,
                                      onColorChanged: changeColor,
                                    ),
                                    // Use Material color picker:
                                    //
                                    // child: MaterialPicker(
                                    //   pickerColor: pickerColor,
                                    //   onColorChanged: changeColor,
                                    //   showLabel: true, // only on portrait mode
                                    // ),
                                    //
                                    // Use Block color picker:
                                    //
                                    // child: BlockPicker(
                                    //   pickerColor: currentColor,
                                    //   onColorChanged: changeColor,
                                    // ),
                                    //
                                    // child: MultipleChoiceBlockPicker(
                                    //   pickerColors: currentColors,
                                    //   onColorsChanged: changeColors,
                                    // ),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: const Text('Got it'),
                                      onPressed: () {
                                        setState(
                                            () => currentColor = pickerColor);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: Icon(Icons.brush, color: pickerBrushColor),
                        tooltip: 'Title Color',
                        color: pickerButtonColor,
                      ))
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Card(
                color: Colors.white,
                margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                elevation: 11,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton(
                        iconEnabledColor: Color(0xFF0000E2),
                        hint: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.category,
                                color: Color(0xFF0000E2),
                              ),
                            ),
                            Text('Categories',
                                style: TextStyle(color: Color(0xFF0000E2))),
                          ],
                        ),
                        items: Genres.genreList.asMap().entries.map((val) {
                          return DropdownMenuItem(
                              value: val.value.name,
                              onTap: () {
                                setState(() {
                                  val.value.name == 'FICTION' ||
                                          val.value.name == 'NON-FICTION'
                                      ? null
                                      : !categories.contains(val.value.name)
                                          ? categories.add(val.value.name)
                                          : categories.remove(val.value.name);
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(val.value.name),
                                  val.value.name == 'FICTION' ||
                                          val.value.name == 'NON-FICTION'
                                      ? Container()
                                      : Icon(
                                          !categories.contains(val.value.name)
                                              ? Icons.check_box_outline_blank
                                              : Icons.check_box,
                                          color: Colors.green[600],
                                        ),
                                ],
                              ));
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            metaData['categories'] = v;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Card(
                color: Colors.white,
                margin: EdgeInsets.only(left: 30, right: 30, top: 20),
                elevation: 11,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: ListTile(
                  dense: true,
                  onTap: () {
                    getImage(true);
                  },
                  leading: Icon(Icons.image, color: Color(0xFF0000E2)),
                  title: Transform.translate(
                    offset: Offset(-18, 0),
                    child: Text(
                      _image.existsSync() ? _image.path : 'Cover',
                      style: TextStyle(color: Color(0xFF0000E2)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.all(10),
                height: 45.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side:
                          BorderSide(color: Color.fromRGBO(147, 196, 125, .3))),
                  onPressed: () {
                    saveCuisine(_image, sb);
                  },
                  padding: EdgeInsets.all(10.0),
                  color: Color.fromRGBO(147, 196, 125, .7),
                  textColor: Colors.white,
                  child: Text("Save", style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

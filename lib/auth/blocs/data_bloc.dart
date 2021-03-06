import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DataBloc extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage coverRef = FirebaseStorage.instance;

  List _alldata = [];
  List get alldata => _alldata;

  List _categories = [];
  List get categories => _categories;

  getData() async {
    QuerySnapshot snap = await firestore
        .collection('food')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();
    //  QuerySnapshot snap = await Firestore.instance.collection('contents')
    //  .where("timestamp", isLessThanOrEqualTo: ['timestamp'])
    //  .orderBy('timestamp', descending: true)
    //  .limit(5).getDocuments();
    List x = snap.docs;
    x.shuffle();
    _alldata.clear();
    x.take(x.length > 5 ? 5 : x.length).forEach((f) async {
      _alldata.add(f);
    });
    notifyListeners();
  }

  Future getCategories() async {
    QuerySnapshot snap = await firestore.collection('categories').get();
    var x = snap.docs;

    _categories.clear();

    x.forEach((f) => _categories.add(f));
    notifyListeners();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // access to jsonEncode()
import 'dart:io'; // access to File and Directory classes
import 'package:path/path.dart' as Path;
import 'package:zefyrka/zefyrka.dart';
import 'package:quill_format/quill_format.dart';

import '../auth/blocs/sign_in_bloc.dart';

class EditorPage extends StatefulWidget {
  EditorPage(
      {this.bookName,
      this.chapterName,
      this.mainEditor,
      this.readOnly,
      Key? key})
      : super(key: key);
  final String? bookName;
  final String? chapterName;
  final String? mainEditor;
  final bool? readOnly;
  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  final User? auth = FirebaseAuth.instance.currentUser;
  FirebaseStorage chapitresRef = FirebaseStorage.instance;

  bool showToolbar = true;

  LineNode lines = LineNode();
  Key _zefKey = Key('zefKey');

  /// Allows to control the editor and the document.
  ZefyrController _controller = ZefyrController();

  /// Zefyr editor like any other input field requires a focus node.
  FocusNode _focusNode = FocusNode();

  _saveDocument(BuildContext context) async {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path +
        "/" +
        widget.bookName! +
        "/" +
        widget.chapterName! +
        ".json");
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    });

    String returnURL = '';
    Reference ref = chapitresRef
        .ref()
        .child('chapitres/${widget.mainEditor!}/${Path.basename(file.path)}');
    TaskSnapshot uploadTask = await ref.putFile(file);

    returnURL = await uploadTask.ref.getDownloadURL();

    return returnURL;
  }

  /// Loads the document asynchronously from a file if it exists, otherwise
  /// returns default document.
  Future<NotusDocument> _loadDocument() async {
    Reference chap = FirebaseStorage.instance.ref(
        'chapitres/${widget.mainEditor!}/${widget.bookName!}/${widget.chapterName!}.json');
    final download = File(
        Directory.systemTemp.path + "/" + widget.bookName! + "/" + chap.name);
    final file = File(Directory.systemTemp.path +
        "/" +
        widget.bookName! +
        "/" +
        widget.chapterName! +
        ".json");

    try {
      return chap.getDownloadURL().then((value) => chap
          .writeToFile(download)
          .then((task) => download.readAsString().then((contents) {
                print('ddddddddddddddddddddddddddddddddddddddd');
                print(widget.mainEditor!);
                print('ddddddddddddddddddddddddddddddddddddddd');
                return NotusDocument.fromJson(jsonDecode(contents));
              })));
    } catch (e) {
      if (await file.exists()) {
        final contents = await file.readAsString();
        print('gggggggggggggggggggggggggggggggggggggg');
        print(widget.mainEditor!);
        print('gggggggggggggggggggggggggggggggggggggg');
        return NotusDocument.fromJson(jsonDecode(contents));
      }
      final Delta delta = Delta()..insert("");
      print('ffffffffffffffffffffffffffffff');
      print(widget.mainEditor!);
      print('ffffffffffffffffffffffffffffff');
      return NotusDocument.fromDelta(delta);
    }
  }

  loadLen() {
    var tur = _controller.document;
    print('TTTTTTTTTTTTTTTTTTTTTTT');
    print(tur.root.length);
    print(tur.length);
    print(tur);
    print('TTTTTTTTTTTTTTTTTTTTTTT');
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadDocument().then((document) {
      setState(() {
        _controller = ZefyrController(document);
      });
    });
    KeyboardVisibilityNotification().addNewListener(
      onChange: (isVisible) {
        setState(() {
          showToolbar = isVisible;
        });
      },
    );
    loadLen();
  }

  @override
  void dispose() {
    KeyboardVisibilityNotification().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    // If _controller is null we show Material Design loader, otherwise
    // display Zefyr editor.
    final Widget body = (_controller == null)
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: <Widget>[
              Positioned(
                top: 2,
                left: 0,
                right: 0,
                bottom: 56,
                child: Container(
                  child: ZefyrEditor(
                    key: _zefKey,
                    readOnly: !widget.readOnly!,
                    showCursor: widget.readOnly!,
                    padding: EdgeInsets.all(12),
                    controller: _controller,
                    focusNode: _focusNode,
                  ),
                ),
              ),
              if (MediaQuery.of(context).viewInsets.bottom > 0)
                // if (showToolbar)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    child: ZefyrToolbar.basic(
                      controller: _controller,
                      hideHeadingStyle: false,
                      hideCodeBlock: true,
                      // leading: const [
                      //   Icon(
                      //     Icons.chevron_left_rounded,
                      //     color: Colors.white,
                      //   ),
                      //   VerticalDivider(
                      //     color: Colors.white,
                      //   ),
                      // ],
                      // trailing: const [
                      //   VerticalDivider(
                      //     color: Colors.white,
                      //   ),
                      //   Icon(
                      //     Icons.chevron_right_rounded,
                      //     color: Colors.white,
                      //   )
                      // ],
                    ),
                    decoration: BoxDecoration(color: Colors.grey.shade500),
                  ),
                ),
            ],
          );

    return RawKeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          // if (count_value / count_limit).truncate() > count_inc, count_inc = Quotient
          // _controller.document.toDelta().insert({
          //   {
          //     "insert": "p.1",
          //     "attributes": {"b": true, "i": true, "alignment": "right"}
          //   },
          //   {
          //     "insert": "\n",
          //     "attributes": {"block": "quote"}
          //   },
          //   {
          //     "insert": {"_type": "hr", "_inline": false}
          //   },
          // });
          print('EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');
          print('ENTER WAS PRESSED!');
          print('EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chapterName!),
          actions: <Widget>[
            Builder(
              builder: (context) => widget.readOnly!
                  ? IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () => _saveDocument(context),
                    )
                  : Container(),
            ),
            Builder(
                builder: (context) => IconButton(
                      icon: Icon(Icons.label),
                      onPressed: () => loadLen(),
                    )),
          ],
        ),
        body: body,
      ),
    );
  }
}

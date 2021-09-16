import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';

import '../state_manager.dart';
import 'text_field.dart';
import 'toolbar.dart';

class TextEditor extends StatefulWidget {
  TextEditor({Key? key}) : super(key: key);

  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  bool showToolbar = true;

  var initVals = [
    {
      'Key': 0,
      'Text': 'These Nights',
      'Style': '${SmartTextType.UNDERLINE}',
      'Node':
          'FocusNode#3e301(context: EditableText-[LabeledGlobalKey<EditableTextState>#eae28])'
    },
    {
      'Key': 1,
      'Text': 'Grey leaves',
      'Style': '${SmartTextType.BULLET}',
      'Node':
          'FocusNode#010d8(context:EditableText-[LabeledGlobalKey<EditableTextState>#9b442])'
    },
    {
      'Key': 2,
      'Text': '​Green skies',
      'Style': '${SmartTextType.BULLET}',
      'Node':
          'FocusNode#6666c(context:EditableText-[LabeledGlobalKey<EditableTextState>#a1bbf])'
    },
    {
      'Key': 3,
      'Text': '​Blue nights',
      'Style': '${SmartTextType.BULLET}',
      'Node':
          'FocusNode#38c79(context:EditableText-[LabeledGlobalKey<EditableTextState>#1a01a])'
    },
    {
      'Key': 4,
      'Text':
          'I have been here the whole time and I will be there at the same place as last week.',
      "Style": '${SmartTextType.QUOTE}',
      'Node':
          ' FocusNode#14e9d([PRIMARY FOCUS])(context: EditableText-[LabeledGlobalKey<EditableTextState>#267ce], PRIMARY FOCUS)'
    },
    {
      'Key': 5,
      'Text': 'Turn me right!',
      'Style': '${SmartTextType.T}',
      'Node':
          'FocusNode#b7c32(context:EditableText-[LabeledGlobalKey<EditableTextState>#2557a])'
    }
  ];

  void _getText() async {
    await Future.delayed(Duration(milliseconds: 200));
    EditorProvider editorProvider =
        Provider.of<EditorProvider>(context, listen: false);
    for (var val in initVals) {
      editorProvider.textAt(int.parse(val.values.first.toString())).text =
          val['Text'].toString();
      editorProvider.typeAt(int.parse(val.values.first.toString())).textStyle =
          val['Style'];
    }
  }

  @override
  void initState() {
    super.initState();
    _getText();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (isVisible) {
        setState(() {
          showToolbar = isVisible;
        });
      },
    );
  }

  @override
  void dispose() {
    KeyboardVisibilityNotification().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditorProvider>(
        create: (context) => EditorProvider(),
        builder: (context, child) {
          return SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Broth',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  centerTitle: true,
                ),
                body: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      bottom: 56,
                      child: Consumer<EditorProvider>(
                          builder: (context, state, _) {
                        return ListView.builder(
                            itemCount: state.length,
                            itemBuilder: (context, index) {
                              return Focus(
                                  onFocusChange: (hasFocus) {
                                    if (hasFocus)
                                      state.setFocus(state.typeAt(index));
                                  },
                                  child: SmartTextField(
                                    type: state.typeAt(index),
                                    controller: state.textAt(index),
                                    focusNode: state.nodeAt(index),
                                  ));
                            });
                      }),
                    ),
                    if (MediaQuery.of(context).viewInsets.bottom > 0)
                      // if (showToolbar)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Selector<EditorProvider, SmartTextType>(
                          selector: (buildContext, state) =>
                              state.selectedType!,
                          builder: (context, selectedType, _) {
                            return Toolbar(
                              selectedType: selectedType,
                              onSelected: Provider.of<EditorProvider>(context,
                                      listen: false)
                                  .setType,
                            );
                          },
                        ),
                      ),
                    Consumer<EditorProvider>(builder: (context, state, _) {
                      return Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 10.0, bottom: 10.0),
                          child: ClipOval(
                            child: Material(
                              color: Color.fromRGBO(
                                  147, 196, 125, .45), // button color
                              child: InkWell(
                                splashColor: Color.fromRGBO(
                                    147, 196, 125, .45), // inkwell color
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Icon(FontAwesomeIcons.share),
                                ),
                                onTap: () {
                                  var myText = List.generate(
                                      state.length, (index) => state);
                                  var myMap = myText
                                      .asMap()
                                      .entries
                                      .map((res) => {
                                            'Key': res.key,
                                            'Text':
                                                res.value.textAt(res.key).text,
                                            'Style': res.value.typeAt(res.key),
                                            'Node': res.value.nodeAt(res.key),
                                          })
                                      .toList();
                                  print(
                                      'DATADATADATDATADATADATADATADATADATADATADATADATADATADATADATA');
                                  print(state.length);
                                  print(state.toString());
                                  print(state.focus);
                                  print(state.selectedType);
                                  print(myMap.length);
                                  // print(myMap);
                                  print(
                                      'DATADATADATDATADATADATADATADATADATADATADATADATADATADATADATA');
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                )),
          );
        });
  }
}

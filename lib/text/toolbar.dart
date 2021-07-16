import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

import 'text_field.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({this.onSelected, this.selectedType, Key? key})
      : super(key: key);

  final selectedType;
  final onSelected;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(56),
      child: Material(
          elevation: 4.0,
          color: Colors.orange.shade50,
          shadowColor: Colors.orangeAccent,
          child: Row(children: <Widget>[
            IconButton(
                icon: Icon(CommunityMaterialIcons.format_size,
                    color: selectedType == SmartTextType.H1
                        ? Colors.teal
                        : Colors.black),
                onPressed: () => onSelected(SmartTextType.H1)),
            IconButton(
                icon: Icon(CommunityMaterialIcons.format_quote_open,
                    color: selectedType == SmartTextType.QUOTE
                        ? Colors.teal
                        : Colors.black),
                onPressed: () => onSelected(SmartTextType.QUOTE)),
            IconButton(
                icon: Icon(CommunityMaterialIcons.format_underline,
                    color: selectedType == SmartTextType.UNDERLINE
                        ? Colors.teal
                        : Colors.black),
                onPressed: () => onSelected(SmartTextType.UNDERLINE)),
            IconButton(
                icon: Icon(CommunityMaterialIcons.format_list_bulleted,
                    color: selectedType == SmartTextType.BULLET
                        ? Colors.teal
                        : Colors.black),
                onPressed: () => onSelected(SmartTextType.BULLET))
          ])),
    );
  }
}

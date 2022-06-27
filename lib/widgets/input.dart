import 'package:flutter/material.dart';

typedef StringValue = String Function(String);

// ignore: must_be_immutable
class InputCard extends StatefulWidget {
  InputCard(this.title, this.callback,
      {this.isPassword = false,
      this.isIcon = Icons.brightness_1_sharp,
      this.isDisabled = false,
      this.isDate = false,
      this.isDropDown = false,
      this.inpuType = TextInputType.text,
      var inputController,
      // var passedCallback,
      var passedList})
      : this.dropList = passedList ?? [],
        // this.callback = passedCallback ?? '',
        this.controller = inputController ?? TextEditingController();
  final String title;
  bool isDropDown;
  bool isPassword;
  var isIcon;
  bool isDisabled;
  bool isDate;
  TextInputType inpuType;
  TextEditingController controller;
  List dropList;
  StringValue callback;

  @override
  _InputCardState createState() => _InputCardState();
}

class _InputCardState extends State<InputCard> {
  Map dropDownMap = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 30, right: 30, top: 30),
      elevation: 11,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: widget.isDropDown
          ? Container(
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
                            widget.isIcon,
                            color: Color(0xFF0000E2),
                          ),
                        ),
                        Text(
                            dropDownMap[widget.title] == null
                                ? widget.title
                                : dropDownMap[widget.title],
                            style: TextStyle(color: Color(0xFF0000E2))),
                      ],
                    ),
                    items: widget.dropList.map((var value) {
                      return DropdownMenuItem(
                          value: value,
                          child: Text(value,
                              style: TextStyle(color: Colors.black)));
                    }).toList(),
                    onChanged: (val) {
                      print('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
                      print(dropDownMap);
                      print('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
                      setState(() {
                        dropDownMap[widget.title] = val;
                      });
                      widget.callback(val.toString());
                    },
                  ),
                ),
              ),
            )
          : TextFormField(
              style: TextStyle(color: Color(0xFF0000E2)),
              keyboardType: !widget.isDate ? widget.inpuType : null,
              readOnly: widget.isDate ? true : widget.isDisabled,
              obscureText: widget.isPassword,
              controller: widget.controller,
              onChanged: !widget.isDate
                  ? (val) {
                      widget.callback(val.toString());
                    }
                  : (_) {},
              validator: (value) {
                if (value!.isEmpty) {
                  return '${widget.title} cannot be empty!';
                }

                return null;
              },
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    widget.isIcon,
                    color: Color(0xFF0000E2),
                  ),
                  hintText: widget.title,
                  hintStyle: TextStyle(color: Color(0xFF0000E2)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0)),
            ),
    );
  }
}

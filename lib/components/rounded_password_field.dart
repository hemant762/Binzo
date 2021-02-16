
import 'package:app/components/text_field_container.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final String hint_text;

  const RoundedPasswordField({
    Key key,
    this.onChanged,
    this.controller,
    this.hint_text="Password"
  }) : super(key: key);


  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {

  bool dont_show = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: dont_show,
        onChanged: widget.onChanged,
        cursorColor: kPrimaryColor,
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hint_text,
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                dont_show = !dont_show;
              });
            },
            child: Icon(
              (dont_show ? Icons.visibility:Icons.visibility_off),
              color: kPrimaryColor,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants.dart';

class RoundIcon extends StatelessWidget {
  final IconData iconSrc;
  final Function press;
  const RoundIcon({
    Key key,
    this.iconSrc,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: kPrimaryLightColor,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconSrc,
          size: 24,
          color: kPrimaryColor,
        ),
      ),
    );
  }
}

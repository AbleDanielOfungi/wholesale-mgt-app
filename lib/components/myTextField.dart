import 'package:flutter/material.dart';

class myTextField extends StatelessWidget {
  final controller; //used to access what user typrd in the textfield
  final String  hintText;// hints to a user what to enter
  final bool obscureText;//hides x-ters when typing a password
  const myTextField({Key? key, this.controller, required this.hintText, required this.obscureText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(

          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.green,
          )

        ),
      ),
    );

  }
}

import 'package:flutter/material.dart';
import 'package:flutter_messenger/config/Palette.dart';
import 'package:flutter_messenger/config/Transitions.dart';
import 'package:flutter_messenger/models/Contact.dart';
import 'package:flutter_messenger/pages/ConversationPageSlide.dart';

class ContactRowWidget extends StatelessWidget {
  const ContactRowWidget({
    Key key,
    @required this.contact,
  }) : super(key: key);
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context,SlideLeftRoute(page: ConversationPageSlide(startContact: contact))),
      child: Container(
          color: Palette.primaryColor,
          child: Padding(
              padding: const EdgeInsets.only(left: 30, top: 10, bottom: 10),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: contact.getFirstName()),
                    TextSpan(
                        text: ' ' + contact.getLastName(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ))),
    );
  }
}

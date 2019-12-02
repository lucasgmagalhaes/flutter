import 'dart:io';

import 'package:contact_agenda/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    helper.getAllContacts().then((contacts) {
      setState(() {
        this.contacts = contacts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Contacts"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
          backgroundColor: Colors.red,
        ),
        body: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {},
          padding: EdgeInsets.all(10),
        ));
  }

  Widget _contactCard(BuildContext context, Contact contact) {
    return GestureDetector(
        child: Card(
      child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: getCardImage(contact)),
              )
            ],
          )),
    ));
  }

  getCardImage(Contact contact) {
    return DecorationImage(
                        image: contact.img != null
                            ? FileImage(File(contact.img))
                            : AssetImage("images/person.png"));
  }
}

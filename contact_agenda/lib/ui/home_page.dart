import 'dart:io';

import 'package:contact_agenda/helpers/contact_helper.dart';
import 'package:contact_agenda/ui/contact_page.dart';
import 'package:flutter/material.dart';
import "package:url_launcher/url_launcher.dart";

enum OrderOption { orderAZ, orderZA }

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
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Contacts"),
          backgroundColor: Colors.red,
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<OrderOption>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOption>>[
                const PopupMenuItem<OrderOption>(
                    child: Text('Ordernar A-Z'), value: OrderOption.orderAZ),
                const PopupMenuItem<OrderOption>(
                    child: Text('Ordernar Z-A'), value: OrderOption.orderZA)
              ],
              onSelected: (option) {
                setState(() {
                  this._orderList(option);
                });
              },
            )
          ],
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showContactPage();
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.red,
        ),
        body: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, contacts[index]);
          },
          padding: EdgeInsets.all(10),
        ));
  }

  Widget _contactCard(BuildContext context, Contact contact) {
    return GestureDetector(
        onTap: () {
          _showOptions(context, contact);
        },
        child: Card(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, image: getCardImage(contact)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _getContactName(contact),
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getContactEmail(contact),
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          _getContactPhone(contact),
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ));
  }

  DecorationImage getCardImage(Contact contact) {
    return DecorationImage(
        fit: BoxFit.cover,
        image: contact.img != null && contact.img.isNotEmpty
            ? FileImage(File(contact.img))
            : AssetImage("images/person.png"));
  }

  String _getContactName(Contact contact) {
    return contact.name ?? "";
  }

  String _getContactEmail(Contact contact) {
    return contact.email ?? "";
  }

  String _getContactPhone(Contact contact) {
    return contact.phone ?? "";
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      await _getAllContacts();
    }
  }

  _getAllContacts() async {
    final contacts = await helper.getAllContacts();
    setState(() {
      this.contacts = contacts;
      print(contacts);
    });
  }

  void _orderList(OrderOption option) {
    if (option == OrderOption.orderAZ) {
      this.contacts.sort((a, b) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    } else {
      this.contacts.sort((a, b) {
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      });
    }
  }

  void _showOptions(BuildContext context, Contact contact) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text("Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20)),
                        onPressed: () {
                          Navigator.pop(context);
                          launch("tel:${contact.phone}");
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text("Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20)),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: contact);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text("Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20)),
                        onPressed: () {
                          helper.deleteContact(contact.id);
                          setState(() {
                            contacts.remove(contact);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }
}

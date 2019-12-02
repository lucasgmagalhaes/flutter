import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String SEARCH = "";
  String _search;
  int _offSet;

  @override
  void initState() {
    super.initState();
    this._getGiphy().then((giffs) {
      print(giffs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<Map> _getGiphy() async {
    http.Response response;
    if (this._search == null) {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=6XAgMuIlwVVIGVCVHCWdbjRgSXEBRSMa&q=${this._search}&limit=20&offset=${this._offSet}&rating=G&lang=en");
    } else {
      response = await http.get(this.SEARCH);
    }

    return json.decode(response.body);
  }
}

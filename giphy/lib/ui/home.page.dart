import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:giphy/ui/git_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _search;
  static const int _LIST_SIZE = 19;
  int _offSet = 0;
  Future<Map> _getGifs() async {
    http.Response response;

    if (this._search != null) {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=6XAgMuIlwVVIGVCVHCWdbjRgSXEBRSMa&q=$_search&limit=$_LIST_SIZE&offset=$_offSet&rating=G&lang=en');
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/trending?api_key=6XAgMuIlwVVIGVCVHCWdbjRgSXEBRSMa&limit=$_LIST_SIZE&rating=G');
    }

    return json.decode(response.body);
  }

  int _getCount(List data) {
    if (this._search == null || this._search == "") {
      return data.length;
    }
    return data.length + 1;
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        padding: EdgeInsets.all(10),
        itemBuilder: (context, index) {
          if (this._search == null || index < snapshot.data["data"].length) {
            return GestureDetector(
                onLongPress: () {
                  Share.share(snapshot.data["data"][index]["images"]
                      ["fixed_height"]["url"]);
                },
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GifPage(snapshot.data["data"][index])));
                },
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]
                      ["url"],
                  height: 300,
                  fit: BoxFit.cover,
                ));
          }

          return Container(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  this._offSet += _LIST_SIZE;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    "Carregar mais...",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  )
                ],
              ),
            ),
          );
        },
        itemCount: this._getCount(snapshot.data["data"]));
  }

  @override
  void initState() {
    super.initState();

    this._getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif',
            width: 400.0),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              onSubmitted: (text) {
                setState(() {
                  this._search = text;
                  this._offSet = 0;
                });
              },
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                  labelText: "Pesquise aqui!",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.white,
                  )),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: this._getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );

                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return this._createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

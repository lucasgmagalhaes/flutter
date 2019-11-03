import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(title: "Contador de pessoas", home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _people = 0;
  String _infoText = "Pode entrar";

  void _changePeople(int delta) {
    setState(() {
      this._people += delta;

      if(_people < 0){
        this._infoText = "Mundo invertido ?!";
      } else if(_people <= 10){
        this._infoText = "Pode entrar";
      } else {
        this._infoText = "Lotado";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Image.asset("images/restaurant.jpg", fit: BoxFit.cover, height: 1000),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            "Pessoas: $_people",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: FlatButton(
                  child: Text("+1",
                      style: TextStyle(fontSize: 40, color: Colors.white)),
                  onPressed: () {
                    this._changePeople(1);
                  },
                )),
            Padding(
                padding: EdgeInsets.all(10),
                child: FlatButton(
                  child: Text("-1",
                      style: TextStyle(fontSize: 40, color: Colors.white)),
                  onPressed: () {
                    this._changePeople(-1);
                  },
                )),
          ]),
          Text(
            this._infoText,
            style: TextStyle(
                color: Colors.white, fontStyle: FontStyle.italic, fontSize: 30),
          )
        ],
      )
    ]);
  }
}

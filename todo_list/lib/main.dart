import 'dart:convert';
import 'dart:io';

import "package:flutter/material.dart";
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved = new Map();
  int _lastRemovedPos = 0;
  final _todoController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    this._readData().then((todoList) {
      setState(() {
        this._toDoList = json.decode(todoList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: this._todoController,
                  decoration: InputDecoration(
                      labelText: "Nova tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                )),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: this._addTodo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: this._refresh,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: this._toDoList.length,
                itemBuilder: this.buildItem,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      this._toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"]) return -1;
        return 0;
      });
      this._saveData();
    });
  }

  Widget buildItem(context, index) {
    return Dismissible(
      onDismissed: (direction) {
        setState(() {
          this._lastRemoved = Map.from(this._toDoList[index]);
          this._lastRemovedPos = index;
          this._toDoList.removeAt(index);
          this._saveData();

          final snack = SnackBar(
              content: Text("Tarefa ${this._lastRemoved["title"]} removida!"),
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                  label: "Desfazer",
                  onPressed: () {
                    setState(() {
                      this
                          ._toDoList
                          .insert(this._lastRemovedPos, this._lastRemoved);
                      this._saveData();
                    });
                  }));

          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-1.9, 0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          )),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        onChanged: (state) {
          this.updateTodoTaskState(state, this._toDoList[index]);
        },
        title: Text(this._toDoList[index]["title"]),
        value: this._toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(this._toDoList);
    final file = await this._getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newTodo = new Map();
      newTodo["title"] = this._todoController.text;
      newTodo["ok"] = false;
      this._toDoList.add(newTodo);
      this._todoController.clear();
      this._saveData();
    });
  }

  void updateTodoTaskState(bool state, dynamic todo) {
    setState(() {
      todo["ok"] = state;
    });
  }
}

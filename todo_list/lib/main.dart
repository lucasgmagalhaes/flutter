import 'dart:convert';
import 'dart:io';

import "package:flutter/material.dart";
import 'package:path_provider/path_provider.dart';
import 'package:todo_list/todo.model.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _toDoList = [];
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
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: this._toDoList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  onChanged: (state) {
                    this.updateTodoTaskState(state, this._toDoList[index]);
                  },
                  title: Text(this._toDoList[index].title),
                  value: this._toDoList[index].done,
                  secondary: CircleAvatar(
                    child:
                        Icon(_toDoList[index].done ? Icons.check : Icons.error),
                  ),
                );
              },
            ),
          )
        ],
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
    String todo = this._todoController.text;
    if (todo.isEmpty) {
      return;
    }
    setState(() {
      this._toDoList.add(new Todo(todo, false));
      this._todoController.clear();
      this._saveData();
    });
  }

  void updateTodoTaskState(bool state, Todo todo) {
    setState(() {
      todo.done = state;
    });
  }
}

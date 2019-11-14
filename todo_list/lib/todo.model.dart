class Todo {
  String title;
  bool done;

  Todo(this.title, this.done);

  Todo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    done = json['done'];
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'done': done,
      };
}

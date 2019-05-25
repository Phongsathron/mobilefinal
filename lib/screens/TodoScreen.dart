import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoScreen extends StatelessWidget{
  final int userId;
  final String name;

  const TodoScreen({Key key, this.userId, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo'),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: RaisedButton(
                  child: Text('Back'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ),
            ),
            FutureBuilder(
              future: this.fetchTodo(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        Todo todo = snapshot.data[index];
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                              child: ListTile(
                                title: Text('${todo.id}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('${todo.title}'),
                                    Text(
                                      todo.completed ? 'completed' : '',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold
                                      ),
                                    )
                                  ],
                                )
                              ),
                            )
                          )
                        );
                      },
                    )
                  );
                }
                else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Todo>> fetchTodo() async {
    final response = await http.get('https://jsonplaceholder.typicode.com/todos?userId=${userId}');
    if (response.statusCode == 200) {
      List<Todo> todos = json.decode(response.body).map<Todo>((todo) => Todo.fromJson(todo)).toList();
      return todos;
    } else {
      throw Exception('Failed to load todo');
    }
  }
}

class Todo {
  final int id;
  final String title;
  final bool completed;

  Todo({this.id, this.title, this.completed});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      completed: json['completed']
    );
  }
}
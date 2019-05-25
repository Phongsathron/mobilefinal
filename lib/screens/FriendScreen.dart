import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

import 'TodoScreen.dart';

class FriendsScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Friend'),
      ),
      body: Column(
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
          FutureBuilder <List<Friend>> (
            future: fetchPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Friend friend = snapshot.data[index];
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        child: Card(
                          child: InkWell(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    title: Text('${friend.id} : ${friend.name}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('${friend.email}'),
                                        Text('${friend.phone}'),
                                        Text('${friend.website}')
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (BuildContext context) {
                                  return TodoScreen(userId: friend.id, name: friend.name);
                                })
                              );
                            },
                          )
                        )
                      );
                    },
                  )
                );
              } else if (snapshot.hasError) {
                print(snapshot.data);
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner
              return CircularProgressIndicator();
            },
          ),
        ],
      )
    );
  }

  Future<List<Friend>> fetchPost() async {
    final response = await http.get('https://jsonplaceholder.typicode.com/users');
    if (response.statusCode == 200) {
      List<Friend> friends = json.decode(response.body).map<Friend>((friend) => Friend.fromJson(friend)).toList();
      return friends;
    } else {
      throw Exception('Failed to load friends');
    }
  }
}

class Friend{
  final int id;
  final String name;
  final String email;
  final String phone;
  final String website;

  Friend({this.id, this.name, this.email, this.phone, this.website});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      website: json['website']
    );
  }

  @override
  String toString() {
    return '[${this.id} ${this.name}, ${this.email}]\n';
  }
}
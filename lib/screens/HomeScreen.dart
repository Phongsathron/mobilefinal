import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilefinal2/model/User.dart';
import 'package:mobilefinal2/utils/Quote.dart';

class HomeScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen>{
  User user;
  String name;
  String quote;

  UserProvider userProvider = UserProvider();

  @override
  Widget build(BuildContext context) {
    this._getUser();

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Text(
                "Hello ${this.name}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            SizedBox(
              width: double.infinity,
              child: Text(
                'this is my quote "${this.quote}"',
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text("Profile Setup"),
                onPressed: () {
                  Navigator.of(context).pushNamed('/profile-setup');
                },
              )
            ),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text("My Friend"),
                onPressed: () {
                  
                },
              )
            ),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text("Logout"),
                onPressed: () {
                  this.logout();
                },
              )
            )
          ],
        ),
      ),
    );
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('name');
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await this.userProvider.open('user.db');
    if(prefs.containsKey('userId')){
      User user = await this.userProvider.getUser(prefs.getInt('userId'));
      String quote = await QuoteUtils.readQuote(user.id);

      setState(() {
        this.name = prefs.getString('name');
        this.user = user;
        this.quote = quote;
      });
    }
  }
}
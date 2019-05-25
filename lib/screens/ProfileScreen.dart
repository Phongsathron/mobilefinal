import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilefinal2/model/User.dart';
import 'package:mobilefinal2/utils/Quote.dart';
import 'package:sqflite/sqflite.dart';


class ProfileScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen>{
  final _formKey = GlobalKey<FormState>();
  User user;
  UserProvider userProvider = UserProvider();

  String userId;
  String name;
  int age;
  String password;
  String quote;

  var userIdTextController = new TextEditingController();
  var nameTextController = new TextEditingController();
  var ageTextController = new TextEditingController();
  var passwordTextController = new TextEditingController();
  var quoteTextController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    this._getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Setup'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          children: <Widget>[
            TextFormField(
              controller: userIdTextController,
              decoration: InputDecoration(
                labelText: 'User Id',
              ),
              validator: (value) {
                if (value.length < 6 || value.length > 12){
                  return 'ต้องมีความยาวอยู่ในช่วง 6 - 12 ตัวอักษร';
                }
              },
              onSaved: (value) {
                this.userId = value;
              },
            ),
            TextFormField(
              controller: nameTextController,
              decoration: InputDecoration(
                labelText: 'Name'
              ),
              validator: (value) {
                if (!value.trim().contains(' ') || ' '.allMatches(value).length != 1){
                  return 'ต้องมีท้ัง ชื่อและนามสกุล\nโดยคั่นด้วย space 1 space เท่านั้น';
                }
              },
              onSaved: (value) {
                this.name = value;
              },
            ),
            TextFormField(
              controller: ageTextController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age'
              ),
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly
              ],
              validator: (value) {
                if (value.isEmpty){
                  return 'กรุณากรอกอายุ';
                }
                int age = int.parse(value);
                if (age < 10 || age > 80){
                  return 'ต้องเป็นตัวเลขเท่าน้ันและอยู่ในช่วง 10 - 80';
                }
              },
              onSaved: (value) {
                this.age = int.parse(value);
              },
            ),
            TextFormField(
              controller: passwordTextController,
              decoration: InputDecoration(
                labelText: 'Password'
              ),
              validator: (value) {
                if (value.length <= 6){
                  return 'ต้องมีความยาวมากกว่า 6';
                }
              },
              obscureText: true,
              onSaved: (value) {
                this.password = value;
              },
            ),
            TextFormField(
              controller: quoteTextController,
              decoration: InputDecoration(
                labelText: 'Quote'
              ),
              maxLines: 3,
              onSaved: (value) {
                this.quote = value;
              },
            ),
            RaisedButton(
              child: Text("Save"),
              onPressed: () async {
                if(_formKey.currentState.validate()){
                  _formKey.currentState.save();
                  print(this.user);

                  this.user.userId = this.userId;
                  this.user.name = this.name;
                  this.user.age = this.age;
                  this.user.password = this.password;
                  print(this.user);
                  
                  try {
                    await userProvider.open('user.db');
                    await userProvider.update(this.user);
                    QuoteUtils.writeQuote(this.user.id, this.quote);

                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString('name', user.name);

                    Navigator.of(context).pop();
                  }
                  on DatabaseException catch(e) {
                    if(e.isUniqueConstraintError()){
                      this._showNotUniqueDialog();
                    }
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await this.userProvider.open('user.db');
    User user = await this.userProvider.getUser(prefs.getInt('userId'));
    String quote = await QuoteUtils.readQuote(user.id);
    setState(() {
      this.user = user;
      this.userId = user.userId;
      // this.name = user.name;
      // this.password = user.password;
      // this.age = user.age;
      this.userIdTextController.text = user.userId;
      this.nameTextController.text = user.name;
      this.ageTextController.text = '${user.age}';
      this.passwordTextController.text = user.password;
      this.quoteTextController.text = quote;
    });
    print(user.password);
  }

  void _showNotUniqueDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Error"),
          content: new Text("This user Id is already registered"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Done"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobilefinal2/model/User.dart';
import 'package:sqflite/sqflite.dart';

class RegisterScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return RegisterScreenState();
  }
}

class RegisterScreenState extends State<RegisterScreen>{
  final _formKey = GlobalKey<FormState>();
  String userId;
  String name;
  int age;
  String password;

  UserProvider userProvider = UserProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'User Id',
                    icon: Icon(Icons.person)
                  ),
                  validator: (value) {
                    if (value.length < 6 || value.length > 12){
                      return 'ต้องมีความยาวอยู่ในช่วง 6 - 12 ตัวอักษร';
                    }
                  },
                  onSaved: (value){
                    this.userId = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    icon: Icon(Icons.account_circle)
                  ),
                  validator: (value) {
                    if (!value.trim().contains(' ')){
                      return 'ต้องมีทั้งชื่อและนามสกุล โดยคั่นด้วย space 1 space เท่านั้น';
                    }
                  },
                  onSaved: (value){
                    this.name = value;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    icon: Icon(Icons.date_range)
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
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    icon: Icon(Icons.lock)
                  ),
                  validator: (value) {
                    if (value.length <= 6){
                      return 'ต้องมีความยาวมากกว่า 6';
                    }
                  },
                  onSaved: (value){
                    this.password = value;
                  },
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10),),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text("REGISTER NEW ACCOUNT"),
                    onPressed: () async {
                      if(_formKey.currentState.validate()){
                        _formKey.currentState.save();
                        User user = User(this.userId, this.name, this.age, this.password);
                        print(user);
                        try {
                          await userProvider.open('user.db');
                          User userack = await userProvider.insert(user);
                          print(await userProvider.getAllUser());
                          await userProvider.close();
                          print(userack);
                          this._showSuccessDialog();
                        }
                        on DatabaseException catch(e) {
                          if(e.isUniqueConstraintError()){
                            this._showNotUniqueDialog();
                          }
                        }
                      }
                    },
                  )
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Success!"),
          content: new Text("Register success. Go to login"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Login"),
              onPressed: () {
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
              },
            ),
          ],
        );
      },
    );
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
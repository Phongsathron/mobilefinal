import 'package:flutter/material.dart';
import 'package:mobilefinal2/model/User.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = new GlobalKey<FormState>();
  String userId;
  String password;

  UserProvider userProvider = UserProvider();

  @override
  initState() {
    super.initState();
    this._checkIsAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child:
          Container(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/lock.jpg',
                  width: 200,
                  height: 200,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'User Id',
                  ),
                  validator: (value) {
                    if (value.isEmpty){
                      return 'Please fill out this form';
                    }
                  },
                  onSaved: (value){
                    this.userId = value;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value.isEmpty){
                      return 'Please fill out this form';
                    }
                  },
                  onSaved: (value){
                    this.password = value;
                  },
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text("LOGIN"),
                    onPressed: () async {
                      if(_formKey.currentState.validate()){
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _formKey.currentState.save();
                        await userProvider.open('user.db');
                        print(await userProvider.getAllUser());

                        User user = await userProvider.auth(this.userId, this.password);
                        
                        print(user);
                        if (user == null){
                          Toast.show("Invalid user or password", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                        }
                        else{
                          this._storeUser(user);
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      }
                    },
                  ),
                ),
                FlatButton(
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Register New Account", 
                      textAlign: TextAlign.right
                    )
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                )
              ],
            )
          ),
        )
      )
    );
  }

  void _storeUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id);
    await prefs.setString('name', user.name);
    print('from prefs: ${prefs.getInt('userId')} ${prefs.getString('name')}');
  }

  void _checkIsAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('userId') != null){
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}

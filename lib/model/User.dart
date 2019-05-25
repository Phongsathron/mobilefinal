import 'package:sqflite/sqflite.dart';

final String tableUser = 'user';
final String columnId = '_id';
final String columnUserId = 'user_id';
final String columnName = 'name';
final String columnAge = 'age';
final String columnPassword = 'password';

class User {
  int id;
  String userId;
  String name;
  int age;
  String password;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnUserId: userId,
      columnName: name,
      columnAge: age,
      columnPassword: password
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  User(this.userId, this.name, this.age, this.password);

  User.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    userId = map[columnUserId];
    name = map[columnName];
    age = map[columnAge];
    password = map[columnPassword];
  }

  String toString(){
    return '$userId, $name, $age, $password';
  }
}

class CurrentUser{
  static User user;
}

class UserProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        create table $tableUser ( 
          $columnId integer primary key autoincrement, 
          $columnUserId text unique not null,
          $columnName text not null,
          $columnAge integer not null,
          $columnPassword text not null)
        ''');
      }
    );
  }

  Future<User> insert(User user) async {
    user.id = await db.insert(tableUser, user.toMap());
    return user;
  }

  Future<User> getUser(int id) async {
    List<Map> maps = await db.query(tableUser,
        columns: [columnId, columnUserId, columnName, columnAge],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUser() async {
    List<Map> maps = await db.query(tableUser);
    List<User> users = List<User>();
    for(int i = 0; i < maps.length; i++){
      users.add(User.fromMap(maps[i]));
    }
    return users;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableUser, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(User user) async {
    return await db.update(tableUser, user.toMap(),
        where: '$columnId = ?', whereArgs: [user.id]);
  }

  Future<User> auth(String userId, String password) async {
    List<Map> maps = await db.query(tableUser, where: '$columnUserId = ? and $columnPassword = ?', whereArgs: [userId, password]);
    if (maps.length > 0){
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future close() async => db.close();
}

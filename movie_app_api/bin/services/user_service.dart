import '../models/mysql_connection.dart';
import 'security_service.dart';

class UserService {
  MySQL database = MySQL();
  SecurityService securityService = SecurityService();

  UserService();

  Future<Map<String, dynamic>> getUsersByEmail(String email) async {
    var connection = await database.getConnection();
    await connection.connect();
    var result = await connection
        .execute("SELECT * FROM users WHERE email=:email", {"email": email});
    var users = <String, dynamic>{};
    for (final row in result.rows) {
      users.addAll(row.assoc());
    }
    connection.close();
    return users;
  }

  Future<Map<String, String?>> getUsersByEmailAndPassword(
      String email, String password) async {
    var connection = await database.getConnection();
    await connection.connect();
    email = securityService.encryptInformation(email);
    password = securityService.encryptInformation(password);
    var result = await connection.execute(
        "SELECT * FROM users WHERE email=:email AND password=:password",
        {"email": email, "password": password});
    var users = <String, String?>{};
    for (final row in result.rows) {
      users.addAll(row.assoc());
    }
    connection.close();
    return users;
  }

  Future<BigInt> registerUser(String email, dynamic body) async {
    var connection = await database.getConnection();
    await connection.connect();
    String fullName = securityService.encryptInformation(body['fullName']);
    String password = securityService.encryptInformation(body['password']);
    email = securityService.encryptInformation(email);
    var result = await connection.execute(
      "INSERT INTO users (fullName, email, password) VALUES (:fullName, :email, :password)",
      {
        "fullName": fullName,
        "email": email,
        "password": password,
      },
    );
    connection.close();
    return result.affectedRows;
  }
}

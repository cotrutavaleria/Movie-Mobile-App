import 'package:mysql_client/mysql_client.dart';

class MySQL {
  MySQL() {}

  Future<MySQLConnection> getConnection() async {
    final databaseDetails = await MySQLConnection.createConnection(
      host: "127.0.0.1",
      port: 3306,
      userName: "root",
      password: "valeriacotruta",
      databaseName: "movie_app",
    );

    return databaseDetails;
  }
}

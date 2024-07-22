import "dart:convert";
import 'package:shelf/shelf.dart';
import '../models/mysql_connection.dart';
import '../services/user_service.dart';
import 'security_service.dart';

class FavoriteActorsService {
  MySQL database = MySQL();
  SecurityService securityService = SecurityService();

  FavoriteActorsService();

  Future<BigInt> addToFavorites(dynamic userId, dynamic body) async {
    var connection = await database.getConnection();
    await connection.connect();

    List<Map<String, dynamic>> actors = await getFavoriteActorsQuery(userId);
    for (Map<String, dynamic> actor in actors) {
      if (body['actor_name'] == actor['actor_name']) {
        return BigInt.zero;
      }
    }
    final String actorName =
        securityService.encryptInformation(body['actor_name']);
    final String profilePath =
        securityService.encryptInformation(body['profile_path']);

    var result = await connection.execute(
      "INSERT INTO favorite_actors (actor_name, profile_path, user_id) VALUES (:actor_name, :profile_path, :user_id)",
      {
        "actor_name": actorName,
        "profile_path": profilePath,
        "user_id": userId,
      },
    );
    connection.close();
    return result.affectedRows;
  }

  Future<BigInt> deleteFromFavorites(dynamic userId, String actorName) async {
    var connection = await database.getConnection();
    await connection.connect();

    actorName = Uri.decodeComponent(actorName);
    List<Map<String, dynamic>> actors = await getFavoriteActorsQuery(userId);

    for (Map<String, dynamic> actor in actors) {
      if (actor['actor_name'] == actorName) {
        actorName = securityService.encryptInformation(actorName);
        var result = await connection.execute(
          "DELETE FROM favorite_actors WHERE actor_name=:actor_name",
          {
            "actor_name": actorName,
          },
        );
        connection.close();
        return result.affectedRows;
      }
    }
    return BigInt.zero;
  }

  Future<Response> getFavoriteActors(String email) async {
    var json = JsonEncoder.withIndent(" ");
    UserService userService = UserService();
    Map<String, dynamic> users = await userService.getUsersByEmail(email);
    if (users.isNotEmpty) {
      var userId = users['id'];
      List<Map<String, dynamic>> actors = await getFavoriteActorsQuery(userId);
      return Response.ok(json.convert(actors));
    }
    return Response.notFound(json.convert({'message': 'User not found'}));
  }

  Future<List<Map<String, dynamic>>> getFavoriteActorsQuery(
      dynamic userId) async {
    var connection = await database.getConnection();
    await connection.connect();
    var actors = <Map<String, String?>>[];
    var result = await connection.execute(
        "SELECT * FROM favorite_actors WHERE user_id=:user_id",
        {"user_id": userId});
    for (final row in result.rows) {
      var id = row.assoc()['id']!;
      var actorName =
          securityService.decryptInformation(row.assoc()['actor_name']!);
      var profilePath =
          securityService.decryptInformation(row.assoc()['profile_path']!);
      Map<String, String?> response = {
        'id': id,
        'actor_name': actorName,
        'profile_path': profilePath,
        'user_id': userId
      };
      actors.add(response);
    }
    connection.close();
    return actors;
  }
}

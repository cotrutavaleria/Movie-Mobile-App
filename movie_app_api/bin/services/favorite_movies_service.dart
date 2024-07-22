import "dart:convert";
import 'package:shelf/shelf.dart';
import '../models/mysql_connection.dart';
import '../services/user_service.dart';
import 'security_service.dart';

class FavoriteMoviesService {
  MySQL database = MySQL();
  SecurityService securityService = SecurityService();

  FavoriteMoviesService();

  Future<BigInt> addToFavorites(dynamic userId, dynamic body) async {
    var connection = await database.getConnection();
    await connection.connect();

    List<Map<String, dynamic>> movies = await getFavoriteMoviesQuery(userId);
    print(movies);
    print(body['movie_name']);
    for (Map<String, dynamic> movie in movies) {
      if (movie['movie_name'] == body['movie_name']) {
        return BigInt.zero;
      }
    }
    final String movieName =
        securityService.encryptInformation(body['movie_name']);
    final String posterPath =
        securityService.encryptInformation(body['poster_path']);
    var result = await connection.execute(
      "INSERT INTO favorite_movies (movie_name, poster_path, user_id) VALUES (:movie_name, :poster_path, :user_id)",
      {
        "movie_name": movieName,
        "poster_path": posterPath,
        "user_id": userId,
      },
    );
    connection.close();
    return result.affectedRows;
  }

  Future<BigInt> deleteFromFavorites(dynamic userId, String movieName) async {
    var connection = await database.getConnection();
    await connection.connect();

    List<Map<String, dynamic>> movies = await getFavoriteMoviesQuery(userId);
    movieName = Uri.decodeComponent(movieName);

    for (Map<String, dynamic> movie in movies) {
      if (movie['movie_name'] == movieName) {
        movieName = securityService.encryptInformation(movieName);
        var result = await connection.execute(
          "DELETE FROM favorite_movies WHERE movie_name=:movie_name",
          {
            "movie_name": movieName,
          },
        );
        connection.close();
        return result.affectedRows;
      }
    }
    return BigInt.zero;
  }

  Future<Response> getFavoriteMovies(String email) async {
    var json = JsonEncoder.withIndent(" ");
    UserService userService = UserService();
    Map<String, dynamic> users = await userService.getUsersByEmail(email);
    if (users.isNotEmpty) {
      var userId = users['id'];
      List<Map<String, dynamic>> movies = await getFavoriteMoviesQuery(userId);
      return Response.ok(json.convert(movies));
    }
    return Response.notFound(json.convert({'message': 'User not found'}));
  }

  Future<List<Map<String, dynamic>>> getFavoriteMoviesQuery(
      dynamic userId) async {
    var connection = await database.getConnection();
    await connection.connect();
    var movies = <Map<String, String?>>[];
    var result = await connection.execute(
        "SELECT * FROM favorite_movies WHERE user_id=:user_id",
        {"user_id": userId});
    for (final row in result.rows) {
      var id = row.assoc()['id']!;
      var movieName =
          securityService.decryptInformation(row.assoc()['movie_name']!);
      var posterPath =
          securityService.decryptInformation(row.assoc()['poster_path'] ?? "");
      Map<String, String> response = {
        'id': id,
        'movie_name': movieName,
        'poster_path': posterPath,
        'user_id': userId
      };
      movies.add(response);
    }
    print(movies);
    connection.close();
    return movies;
  }
}

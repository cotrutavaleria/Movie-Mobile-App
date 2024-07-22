import 'dart:io';
import "dart:convert";
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/favorite_actors_service.dart';
import '../services/favorite_movies_service.dart';
import '../services/movie_service.dart';
import '../services/security_service.dart';
import '../services/user_service.dart';

final _router = Router()
//movie routes
  ..get('/api/v1/movies/<id>', _getMovieById)
  ..get('/api/v1/genres/movies', _getMoviesByGenre)
  ..get('/api/v1/genres', _getGenresList)
//user routes
  ..post('/api/v1/login', _login)
  ..post('/api/v1/register', _register)
//favorite actors list routes
  ..post('/api/v1/favorites/actors/<email>', _addToFavoriteActors)
  ..get('/api/v1/favorites/actors/<email>', _getFavoriteActors)
  ..delete('/api/v1/<email>/favorites/actors/<actor-name>',
      _deleteFromFavoriteActors)
//favorite movies list routes
  ..post('/api/v1/favorites/movies/<email>', _addToFavoriteMovies)
  ..get('/api/v1/favorites/movies/<email>', _getFavoriteMovies)
  ..delete('/api/v1/<email>/favorites/movies/<movie-name>',
      _deleteFromFavoriteMovies);

SecurityService securityService = SecurityService();

Future<Response> _login(Request request) async {
  final requestBody = await request.readAsString();
  final body = jsonDecode(requestBody);
  final String email = body['email'];
  final String password = body['password'];

  UserService userServices = UserService();
  Map<String, String?> users =
      await userServices.getUsersByEmailAndPassword(email, password);
  var json = JsonEncoder.withIndent(" ");

  if (users.isNotEmpty) {
    return Response.ok(json.convert(users));
  }
  return Response.notFound(json.convert({'message': 'User not found'}));
}

Future<Response> _register(Request request) async {
  final requestBody = await request.readAsString();
  final body = jsonDecode(requestBody);
  final String email = body['email'];

  UserService userServices = UserService();
  Map<String, dynamic> users = await userServices.getUsersByEmail(email);
  var json = JsonEncoder.withIndent(" ");

  if (users.isEmpty) {
    var affectedRows = await userServices.registerUser(email, body);
    if (affectedRows.toInt() == 1) {
      return Response.ok(json
          .convert({'message': 'Registration has been successfully made.'}));
    }
    return Response.internalServerError(
        body: json.convert(
            {'message': 'Internal server error. No insertion was done.'}));
  }
  return Response(409,
      body: json.convert({'message': 'E-mail already exists.'}));
}

Future<Response> _getGenresList(Request request) async {
  MovieService movieServices = MovieService();
  Map<String, dynamic> genreList = await movieServices.getGenres();
  final jsonEncoder = JsonEncoder();
  return Response.ok(jsonEncoder.convert(genreList['genres']));
}

Future<Response> _getMoviesByGenre(Request request) async {
  final Map<String, dynamic> queryParams = request.url.queryParameters;

  final int genreId = int.tryParse(queryParams['genreId'] ?? '') ?? 0;
  final int page = int.tryParse(queryParams['page'] ?? '') ?? 1;
  MovieService movieServices = MovieService();
  List<Map<String, dynamic>> movieList =
      await movieServices.getMoviesByGenre(genreId, page);
  final jsonEncoder = JsonEncoder();
  return Response.ok(jsonEncoder.convert(movieList));
}

Future<Response> _getMovieById(Request request) async {
  String id = request.params['id'].toString();
  MovieService movieService = MovieService();
  Map<String, dynamic> movieDetails = await movieService.getMovieById(id);
  final jsonEncoder = JsonEncoder();
  return Response.ok(jsonEncoder.convert(movieDetails));
}

Future<Response> _addToFavoriteActors(Request request) async {
  var json = JsonEncoder.withIndent(" ");

  final requestBody = await request.readAsString();
  final body = jsonDecode(requestBody);
  String email = request.params['email'].toString();
  email = securityService.encryptInformation(email);

  UserService userService = UserService();
  Map<String, dynamic> users = await userService.getUsersByEmail(email);

  if (users.isNotEmpty) {
    dynamic userId = users['id'];
    FavoriteActorsService favoriteActorsService = FavoriteActorsService();
    var affectedRows = await favoriteActorsService.addToFavorites(userId, body);
    if (affectedRows.toInt() == 1) {
      return Response.ok(
          json.convert({'message': 'The actor was added to the list.'}));
    }
    return Response(404,
        body: json.convert({'message': 'Actor already exists in the list.'}));
  }
  return Response(404,
      body: json.convert({'message': 'E-mail does not exist.'}));
}

Future<Response> _deleteFromFavoriteActors(Request request) async {
  String email = request.params['email'].toString();
  String actorName = request.params['actor-name'].toString();

  email = securityService.encryptInformation(email);

  UserService userService = UserService();
  Map<String, dynamic> users = await userService.getUsersByEmail(email);
  var json = JsonEncoder.withIndent(" ");

  if (users.isNotEmpty) {
    dynamic userId = users['id'];
    FavoriteActorsService favoriteActorsService = FavoriteActorsService();
    var affectedRows =
        await favoriteActorsService.deleteFromFavorites(userId, actorName);
    if (affectedRows.toInt() == 1) {
      return Response.ok(
          json.convert({'message': 'The actor was deleted from the list.'}));
    }
    return Response(404,
        body: json.convert({'message': "No such favorite actor."}));
  }
  return Response(404,
      body: json.convert({'message': 'E-mail does not exist.'}));
}

Future<Response> _getFavoriteActors(Request request) async {
  FavoriteActorsService favoriteActorsService = FavoriteActorsService();
  String email = request.params['email'].toString();
  email = securityService.encryptInformation(email);
  Response response = await favoriteActorsService.getFavoriteActors(email);
  return response;
}

Future<Response> _addToFavoriteMovies(Request request) async {
  var json = JsonEncoder.withIndent(" ");

  final requestBody = await request.readAsString();
  final body = jsonDecode(requestBody);
  String email = request.params['email'].toString();
  email = securityService.encryptInformation(email);

  UserService userService = UserService();
  Map<String, dynamic> users = await userService.getUsersByEmail(email);

  if (users.isNotEmpty) {
    dynamic userId = users['id'];
    FavoriteMoviesService favoriteMoviesService = FavoriteMoviesService();
    var affectedRows = await favoriteMoviesService.addToFavorites(userId, body);
    if (affectedRows.toInt() == 1) {
      return Response.ok(
          json.convert({'message': 'The movie was added to the list.'}));
    }
    return Response(409,
        body: json.convert({'message': 'Movie is already in the list.'}));
  }
  return Response(404,
      body: json.convert({'message': 'E-mail does not exist.'}));
}

Future<Response> _deleteFromFavoriteMovies(Request request) async {
  String email = request.params['email'].toString();
  String movieName = request.params['movie-name'].toString();

  UserService userService = UserService();
  email = securityService.encryptInformation(email);
  Map<String, dynamic> users = await userService.getUsersByEmail(email);
  var json = JsonEncoder.withIndent(" ");

  if (users.isNotEmpty) {
    dynamic userId = users['id'];
    FavoriteMoviesService favoriteMoviesService = FavoriteMoviesService();
    var affectedRows =
        await favoriteMoviesService.deleteFromFavorites(userId, movieName);
    if (affectedRows.toInt() == 1) {
      return Response.ok(
          json.convert({'message': 'The movie was deleted from the list.'}));
    }
    return Response(409,
        body: json.convert({'message': 'No such favorite movie.'}));
  }
  return Response(404,
      body: json.convert({'message': 'E-mail does not exist.'}));
}

Future<Response> _getFavoriteMovies(Request request) async {
  FavoriteMoviesService favoriteMoviesService = FavoriteMoviesService();
  String email = request.params['email'].toString();
  email = securityService.encryptInformation(email);
  Response response = await favoriteMoviesService.getFavoriteMovies(email);
  return response;
}

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router.call);
  final port = int.parse(Platform.environment['PORT'] ?? '8082');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}

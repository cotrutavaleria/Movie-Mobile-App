import 'dart:convert';

import '../models/mysql_connection.dart';
import 'package:http/http.dart' as http;

class MovieService {
  MySQL database = MySQL();
  String API_KEY = "5a1433c223e5e051d016c358393ca777";

  MovieService();

  Future<Map<String, dynamic>> getGenres() async {
    var jsonDecoder = JsonDecoder();
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/genre/movie/list?language=en&api_key=$API_KEY'),
      headers: <String, String>{
        'accept': 'application/json',
      },
    );
    Map<String, dynamic> genreList = jsonDecoder.convert(response.body);
    return genreList;
  }

  Future<List<Map<String, dynamic>>> getMoviesByGenre(
      num genreId, num pageNumber) async {
    var jsonDecoder = JsonDecoder();
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/discover/movie?api_key=$API_KEY&with_genres=$genreId&page=$pageNumber'),
      headers: <String, String>{
        'accept': 'application/json',
      },
    );
    Map<String, dynamic> movieList = jsonDecoder.convert(response.body);
    var processedMovieList = <Map<String, dynamic>>[];
    for (var movie in movieList['results']) {
      var movieDetails = <String, dynamic>{};
      movieDetails.putIfAbsent("id", () => movie['id']);
      movieDetails.putIfAbsent("original_title", () => movie['original_title']);
      movieDetails.putIfAbsent("poster_path", () => movie['poster_path']);
      processedMovieList.add(movieDetails);
    }
    return processedMovieList;
  }

  Future<Map<String, dynamic>> getMovieById(String id) async {
    var jsonDecoder = JsonDecoder();
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/$id?api_key=$API_KEY&language=en-US&append_to_response=credits'),
      headers: <String, String>{
        'accept': 'application/json',
      },
    );
    Map<String, dynamic> movieList = jsonDecoder.convert(response.body);

    var processedMovieDetails = <String, dynamic>{};
    processedMovieDetails.putIfAbsent("id", () => movieList['id']);
    processedMovieDetails.putIfAbsent(
        "original_title", () => movieList['original_title']);
    processedMovieDetails.putIfAbsent(
        "poster_path", () => movieList['poster_path']);
    processedMovieDetails.putIfAbsent("overview", () => movieList['overview']);
    processedMovieDetails.putIfAbsent(
        "release_date", () => movieList['release_date']);

    var cast = <Map<String, dynamic>>[];
    for (var person in movieList['credits']['cast']) {
      var personDetails = <String, dynamic>{};
      personDetails.putIfAbsent("name", () => person['name']);
      personDetails.putIfAbsent("character", () => person['character']);
      personDetails.putIfAbsent("profile_path", () => person['profile_path']);
      cast.add(personDetails);
    }

    var production = <Map<String, dynamic>>[];
    for (var person in movieList['credits']['crew']) {
      var personDetails = <String, dynamic>{};
      personDetails.putIfAbsent("name", () => person['name']);
      personDetails.putIfAbsent("profile_path", () => person['profile_path']);
      personDetails.putIfAbsent(
          "known_for_department", () => person['known_for_department']);
      production.add(personDetails);
    }
    processedMovieDetails.putIfAbsent("cast", () => cast);
    processedMovieDetails.putIfAbsent("production", () => production);
    return processedMovieDetails;
  }
}

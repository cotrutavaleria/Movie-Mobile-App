import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MovieDetailsPage extends StatefulWidget {
  final dynamic movie, email;
  const MovieDetailsPage({super.key, required this.movie, required this.email});

  @override
  MovieDetailsPageState createState() => MovieDetailsPageState();
}

class MovieDetailsPageState extends State<MovieDetailsPage> {
  Map<String, dynamic> movieDetails = {};
  int castListLength = 0;
  int productionListLength = 0;
  late String email;
  late dynamic movie;
  bool _isMovieLoaded = false;
  @override
  void initState() {
    super.initState();
    getMovieDetails();
  }

  getMovieDetails() async {
    email = widget.email;
    movie = widget.movie;
    final response = await http.get(
      Uri.parse('http://192.168.1.136:8082/api/v1/movies/${movie['id']}'),
      headers: <String, String>{
        'accept': 'application/json',
      },
    );
    const jsonDecoder = JsonDecoder();
    setState(() {
      movieDetails = jsonDecoder.convert(response.body);
      castListLength = movieDetails['cast'].length;
      productionListLength = movieDetails['production'].length;
    });
  }

  @override
  void dispose() {
    castListLength = 0;
    movieDetails = {};
    super.dispose();
  }

  addToFavoriteActors(dynamic actor) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.136:8082/api/v1/favorites/actors/$email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String?>{
        'actor_name': actor['name'],
        'profile_path':
            actor['profile_path'] ?? 'https://via.placeholder.com/100'
      }),
    );
    if (response.statusCode == 200) {
      setState(() => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Added to favorite actors.'),
              action: SnackBarAction(
                label: 'Close',
                onPressed: () {},
              ),
            ),
          ));
    } else {
      var message = jsonDecode(response.body);
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message['message']),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {},
          ),
        ));
      });
    }
  }

  addToFavoriteMovies() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.136:8082/api/v1/favorites/movies/$email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String?>{
        'movie_name': movie['original_title'],
        'poster_path': movie['poster_path'] ?? 'https://via.placeholder.com/100'
      }),
    );
    if (response.statusCode == 200) {
      setState(() => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Added to favorite movies.'),
              action: SnackBarAction(
                label: 'Close',
                onPressed: () {},
              ),
            ),
          ));
    } else {
      var message = jsonDecode(response.body);
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message['message']),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {},
          ),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMovieLoaded) {
      getMovieDetails();
      _isMovieLoaded = true;
    }
    email = widget.email;
    return Scaffold(
        appBar: AppBar(
          title: Text(movieDetails['original_title'] ?? 'Loading...'),
          backgroundColor: const Color.fromARGB(255, 187, 134, 115),
        ),
        body: Stack(children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 187, 134, 115),
                  Colors.white,
                  Color.fromARGB(255, 229, 141, 109)
                ],
                stops: [0.1, 0.7, 0.9],
              ),
            ),
          ),
          SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      movieDetails['poster_path'] != null
                          ? 'http://image.tmdb.org/t/p/w500${movieDetails['poster_path']}'
                          : 'https://raw.githubusercontent.com/Codelessly/FlutterLoadingGIFs/master/packages/cupertino_activity_indicator.gif',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - 300,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      onPressed: () {
                        addToFavoriteMovies();
                      },
                      icon: const Icon(
                        Icons.favorite,
                        color: Color.fromARGB(255, 187, 134, 115),
                      ), // Add your desired icon here
                      label: const Text('Add to favorite',
                          style: TextStyle(
                            color: Color.fromARGB(255, 187, 134, 115),
                          )),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                            fontSize: 16.0,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Overview: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: movieDetails['overview'] ?? 'Loading...',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                            fontSize: 16.0,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Release Date: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  movieDetails['release_date'] ?? 'Loading...',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      height: 30,
                      thickness: 3,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.black,
                    ),
                    const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "Cast",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        )),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: castListLength,
                      itemBuilder: (context, castIndex) {
                        if (castIndex < castListLength) {
                          final cast = movieDetails['cast'][castIndex];
                          if (cast['profile_path'] == null) {
                            return ListTile(
                              leading: Image.network(
                                'https://via.placeholder.com/100',
                                fit: BoxFit.cover,
                              ),
                              title: Text(cast['name']),
                              subtitle: Text('(${cast['character']})'),
                              trailing: IconButton(
                                icon: const Icon(Icons.theater_comedy),
                                onPressed: () {
                                  addToFavoriteActors(cast);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            leading: Image.network(
                              'http://image.tmdb.org/t/p/w500${cast['profile_path']}',
                              width: 60,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                            title: Text(cast['name']),
                            subtitle: Text('(${cast['character']})'),
                            trailing: IconButton(
                              icon: const Icon(Icons.theater_comedy),
                              onPressed: () {
                                addToFavoriteActors(cast);
                              },
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    const Divider(
                      height: 30,
                      thickness: 3,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.black,
                    ),
                    const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "Production",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        )),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: productionListLength,
                      itemBuilder: (context, productionIndex) {
                        if (productionIndex < productionListLength) {
                          final production =
                              movieDetails['production'][productionIndex];
                          if (production['profile_path'] == null) {
                            return ListTile(
                              leading: Image.network(
                                'https://via.placeholder.com/100',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(production['name']),
                              subtitle: Text(
                                  '(${production['known_for_department']})'),
                            );
                          }
                          return ListTile(
                            leading: Image.network(
                              'http://image.tmdb.org/t/p/w500${production['profile_path']}',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(production['name']),
                            subtitle:
                                Text('(${production['known_for_department']})'),
                          );
                        }
                        return null;
                      },
                    ),
                  ]))
        ]));
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app_client/movie_pages/movie_details_page.dart';

class PagesNavigation extends StatefulWidget {
  final dynamic email;
  const PagesNavigation({super.key, required this.email});
  @override
  PagesNavigationState createState() => PagesNavigationState();
}

class PagesNavigationState extends State<PagesNavigation> {
  int currentTabIndex = 0;
  int currentPageIndex = 0;
  late String email;

  List<Map<String, dynamic>> moviesByGenre = [];

  List<dynamic> favoriteActors = [];
  int favoriteActorsListLength = 0;
  bool _isFavoriteActorsLoaded = false;

  List<dynamic> favoriteMovies = [];
  int favoriteMovieListLength = 0;
  bool _isFavoriteMoviesLoaded = false;

  @override
  void initState() {
    super.initState();
    getGenreList();
  }

  getGenreList() async {
    moviesByGenre.clear();
    final response = await http.get(
      Uri.parse('http://192.168.1.136:8082/api/v1/genres'),
      headers: <String, String>{
        'accept': 'application/json',
      },
    );
    const jsonDecoder = JsonDecoder();
    final genreList = jsonDecoder.convert(response.body) as List<dynamic>;
    for (var genre in genreList) {
      var genreDetails = <String, dynamic>{};
      genreDetails['genre'] = genre['name'];
      List<dynamic> movieList =
          await getMovieListByGenre(genre['id'], currentPageIndex);
      genreDetails['movies'] = movieList;
      setState(() {
        moviesByGenre.add(genreDetails);
      });
    }
  }

  Future<List<dynamic>> getMovieListByGenre(int genreId, int pageNumber) async {
    final exactPageNumber = pageNumber + 1;
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.136:8082/api/v1/genres/movies?genreId=$genreId&page=$exactPageNumber'),
      headers: <String, String>{
        'accept': 'application/json',
      },
    );
    const jsonDecoder = JsonDecoder();
    final movieList = jsonDecoder.convert(response.body) as List<dynamic>;
    return movieList;
  }

  Future<List<dynamic>> getFavoriteActors() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.136:8082/api/v1/favorites/actors/$email'),
      headers: <String, String>{
        'accept': 'application/json',
      },
    );
    const jsonDecoder = JsonDecoder();
    setState(() {
      favoriteActors = jsonDecoder.convert(response.body) as List<dynamic>;
      favoriteActorsListLength = favoriteActors.length;
    });
    return favoriteActors;
  }

  deleteActorFromList(dynamic actor) async {
    if (actor != null && actor.containsKey('actor_name')) {
      var actorName = actor['actor_name'];
      final response = await http.delete(
        Uri.parse(
            'http://192.168.1.136:8082/api/v1/$email/favorites/actors/$actorName'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Actor deleted.'),
              action: SnackBarAction(
                label: 'Close',
                onPressed: () {},
              ),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (favoriteActors.contains(actor)) {
              favoriteActors.clear;
              getFavoriteActors();
            }
          });
        });
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
  }

  Future<List<dynamic>> getFavoriteMovies() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.136:8082/api/v1/favorites/movies/$email'),
      headers: <String, String>{
        'accept': 'application/json',
      },
    );
    const jsonDecoder = JsonDecoder();
    setState(() {
      favoriteMovies = jsonDecoder.convert(response.body) as List<dynamic>;
      favoriteMovieListLength = favoriteMovies.length;
    });
    return favoriteMovies;
  }

  deleteMovieFromList(dynamic movie) async {
    if (movie != null && movie.containsKey('movie_name')) {
      var movieName = movie['movie_name'];
      final response = await http.delete(
        Uri.parse(
            'http://192.168.1.136:8082/api/v1/$email/favorites/movies/$movieName'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Movie deleted.'),
              action: SnackBarAction(
                label: 'Close',
                onPressed: () {},
              ),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (favoriteMovies.contains(movie)) {
              favoriteMovies.clear;
              getFavoriteMovies();
            }
          });
        });
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
  }

  Widget _buildDashboard(theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20.0),
          for (var genreDetails in moviesByGenre)
            ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  genreDetails['genre'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'OpenSans',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: genreDetails['movies'].length,
                  itemBuilder: (context, movieIndex) {
                    if (movieIndex < genreDetails['movies'].length) {
                      final movie = genreDetails['movies'][movieIndex];
                      return Container(
                        margin: const EdgeInsets.all(8),
                        child: ClipRect(
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MovieDetailsPage(
                                          movie: movie,
                                          email: email,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    'http://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                    width: double.infinity,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    movie['original_title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return BottomAppBar(
      child: Column(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(
                      () => currentPageIndex == 0 ? 0 : currentPageIndex--);
                  getGenreList();
                }),
            Text('Page ${currentPageIndex + 1}'),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                setState(() => currentPageIndex++);
                getGenreList();
              },
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildFavoriteActors(theme) {
    if (currentTabIndex != 1) {
      _isFavoriteActorsLoaded = false;
    } else {
      if (!_isFavoriteActorsLoaded) {
        getFavoriteActors();
        _isFavoriteActorsLoaded = true;
      }
    }
    return Stack(children: <Widget>[
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: favoriteActorsListLength,
            itemBuilder: (context, castIndex) {
              if (castIndex < favoriteActorsListLength) {
                dynamic cast = favoriteActors[castIndex];
                if (cast['profile_path'] == "https://via.placeholder.com/100") {
                  return Card(
                    color: const Color.fromARGB(255, 187, 134, 115),
                    child: ListTile(
                        leading: Image.network(
                          cast['profile_path'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        title: Text(cast['actor_name']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteActorFromList(cast);
                          },
                        )),
                  );
                } else {
                  return Card(
                    color: const Color.fromARGB(255, 187, 134, 115),
                    child: ListTile(
                        leading: Image.network(
                          'http://image.tmdb.org/t/p/w500/${cast['profile_path']}',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        title: Text(cast['actor_name']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteActorFromList(cast);
                          },
                        )),
                  );
                }
              }
              return null;
            })
      ]))
    ]);
  }

  Widget _buildFavoriteMovies(theme) {
    if (currentTabIndex != 2) {
      _isFavoriteMoviesLoaded = false;
    } else {
      if (!_isFavoriteMoviesLoaded) {
        getFavoriteMovies();
        _isFavoriteMoviesLoaded = true;
      }
    }
    return Stack(children: <Widget>[
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: favoriteMovieListLength,
            itemBuilder: (context, castIndex) {
              if (castIndex < favoriteMovieListLength) {
                dynamic currentMovie = favoriteMovies[castIndex];
                if (currentMovie['poster_path'] == "") {
                  return Card(
                    color: const Color.fromARGB(255, 187, 134, 115),
                    child: ListTile(
                        leading: Image.network(
                          'https://via.placeholder.com/100',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        title: Text(currentMovie['movie_name']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteMovieFromList(currentMovie);
                          },
                        )),
                  );
                } else {
                  return Card(
                    color: const Color.fromARGB(255, 187, 134, 115),
                    child: ListTile(
                        leading: Image.network(
                          'http://image.tmdb.org/t/p/w500/${currentMovie['poster_path']}',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        title: Text(currentMovie['movie_name']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteMovieFromList(currentMovie);
                          },
                        )),
                  );
                }
              }
              return null;
            })
      ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    email = widget.email;
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.theater_comedy),
            label: 'Favorite actors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter_rounded),
            label: 'Favorite movies',
          ),
        ],
      ),
      body: <Widget>[
        _buildDashboard(theme),
        _buildFavoriteActors(theme),
        _buildFavoriteMovies(theme)
      ][currentTabIndex],
      bottomSheet: currentTabIndex == 0 ? _buildPagination() : null,
    );
  }
}

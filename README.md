# Movie App

## Description
This is a mobile app that gives users the possibility to browse through movies and see information on the actors, producers and a summary of the plot of each movie. Every user may pin their favorite actors and films. The movies are also viewable sorted by genres.

## Demo

## Code explanation
I developed in Dart an API using Android Studio - an IDE for Android app development.
The client application is implemented in Flutter - an open source framework by Google for building multi-platform applications from a single codebase.
I used a MySQL database to store information about the users of the application. The connection to the database was implemented using mysql_client library.

### API
The structure of the folders and files is defined by MVC framework.

Mainly, the API manages the registration and authentication processes, stores users' favorite lists of movies and actors and gets the information about the movies.
I used the API of The Movie Database (TMDB) based on which I brought details about every movie, the genres and the lists of movies for each genre.

In the main function of server.dart file, I started server and created all the necessary routes for the application.

#### Get Movies By Id Request
When a request to /api/v1/movies/<id> route is made up, a JSON response is built up in the following way:
1. Firstly, all the information available is brought from TMDB API.
    ```
    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/$id?api_key=$API_KEY&language=en-US&append_to_response=credits'),
        headers: <String, String>{
        'accept': 'application/json',
        },
    );
    Map<String, dynamic> movieList = jsonDecoder.convert(response.body);
   ```
2. Then, general movie details are obtained, such as: id, original title, poster, plot and release date:
   ```
   var processedMovieDetails = <String, dynamic>{};
   processedMovieDetails.putIfAbsent("id", () => movieList['id']);
   processedMovieDetails.putIfAbsent(
   "original_title", () => movieList['original_title']);
   processedMovieDetails.putIfAbsent(
   "poster_path", () => movieList['poster_path']);
   processedMovieDetails.putIfAbsent("overview", () => movieList['overview']);
   processedMovieDetails.putIfAbsent(
   "release_date", () => movieList['release_date']);
   ```
3. For each actor, the name, an image and the name of the character they played are gathered into a Map collection. The information about the crew of the movie is similarly processed.
    ```
    var cast = <Map<String, dynamic>>[];
        for (var person in movieList['credits']['cast']) {
          var personDetails = <String, dynamic>{};
          personDetails.putIfAbsent("name", () => person['name']);
          personDetails.putIfAbsent("character", () => person['character']);
          personDetails.putIfAbsent("profile_path", () => person['profile_path']);
          cast.add(personDetails);
        }
    ```
4. In return to the request, a JSON containing the general information, the cast and the production will be sent to the client application.
#### Encryption 
The information before being stored in the database is encrypted into SecurityService class, using AES encryption algorithm.
```
String encryptInformation(String data) {
    final key = utf8.encode(_key);
    final iv = utf8.encode(_key.substring(0, 16)); 
    final encrypter = Encrypter(AES(Key(key), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(data, iv: IV(iv));
    return encrypted.base64;
  }
```
### Client application
The navbar consists of three items: the movies sorted by genres, the list of the favorite actors and the list of the favorite movies.
```
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
```
Movies are displayed using pagination in the movies tab.
```
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
```

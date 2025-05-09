import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Movie {
  final int id;
  final String imageUrl;

  Movie(this.id, this.imageUrl);
}

class TMDBApi {
  static Future<List<Movie>> get_movies_ids(int page) async {
    await dotenv.load(fileName: ".env");
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/discover/'
        'movie?'
        'include_adult=false&'
        'include_video=false&'
        'language=en-US&'
        'page=$page&'
        'sort_by=popularity.desc',
      ),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    List<Movie> result = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int results = data['results'].length;
      for (int i = 0; i < results; i++) {
        result.add(
          Movie(
            data['results'][i]['id'],
            'https://image.tmdb.org/t/p/w200${data['results'][i]['poster_path']};',
          ),
        );
      }
      return result;
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }

  static Future<List<String>> get_movie_images(int movie_id) async {
    List<String> result = [];
    await dotenv.load(fileName: ".env");
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/'
        'movie/$movie_id/images',
      ),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print backdrops

      // int results = data['results'].length;
      // print('Results: $results');
      // for (int i = 0; i < results; i++) {
      //   result.add(data['results'][i]['id']);
      // print(
      //   'https://image.tmdb.org/t/p/w500/${data['results'][i]['poster_path']}',
      // );
      // }
      return result;
    } else {
      throw Exception(
        'Failed to load image data on id $movie_id error ${response.statusCode}',
      );
    }
  }

  static Future<List<String>> get_movie_images_dumb(int movie_id) async {
    List<String> result = [];
    return result;
  }
}

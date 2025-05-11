import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum SortBy { title, popularity, releaseDate }

enum SortByDirection { ascending, descending }

class Movie {
  final int id;
  final String imageUrl;
  final String title;

  Movie(this.id, this.imageUrl, this.title);
}

class MovieFilters {
  final Certification? _certification;
  final bool? _includeAdult;
  final List<Genres>? _genres;
  final SortBy? _sortBy;
  final SortByDirection? _sortByDirection;
  final DateTime? _lteReleaseDate;

  MovieFilters({
    Certification? certification,
    bool includeAdult = false,
    List<Genres>? genres,
    SortBy sortBy = SortBy.popularity,
    SortByDirection sortByDirection = SortByDirection.ascending,
    DateTime? lteReleaseDate,
  }) : _certification = certification,
       _includeAdult = includeAdult,
       _genres = genres,
       _sortBy = sortBy,
       _sortByDirection = sortByDirection,
       _lteReleaseDate = lteReleaseDate;

  get includeAdult {
    if (_includeAdult != null) {
      return 'include_adult=$_includeAdult&';
    }
    return '';
  }

  get certification {
    if (_certification != null) {
      return 'certification_country=${_certification.region}&'
          'certification=${_certification.certification}&'
          'region=${_certification.region}&';
    }
    return '';
  }

  get genres {
    if (_genres != null) {
      String genresString = '';
      for (int i = 0; i < _genres.length; i++) {
        genresString += '${_genres[i].id}';
        if (i != _genres.length - 1) {
          genresString += ',';
          // genresString += '|';
        }
      }
      return 'with_genres=$genresString&';
    }
    return '';
  }

  String get sortByQuery {
    if (_sortBy == null) {
      return 'sort_by=popularity.desc&'; // Default if nothing selected
    }

    String sortByValue;
    switch (_sortBy) {
      case SortBy.title:
        sortByValue = 'title';
        break;
      case SortBy.releaseDate:
        sortByValue = 'primary_release_date';
        break;
      // case SortBy.popularity:
      default:
        sortByValue = 'popularity';
        break;
    }
    // Default to descending if sortByDirection is null
    String direction =
        (_sortByDirection == null ||
                _sortByDirection == SortByDirection.descending)
            ? '.desc'
            : '.asc';
    return 'sort_by=$sortByValue$direction&';
  }

  String get lteReleaseDate {
    if (_lteReleaseDate != null) {
      int year = _lteReleaseDate.year;
      int month = _lteReleaseDate.month;
      int day = _lteReleaseDate.day;

      String monthString = month.toString();
      String dayString = day.toString();
      if (monthString.length == 1) {
        monthString = '0$monthString';
      }
      if (dayString.length == 1) {
        dayString = '0$dayString';
      }
      return 'primary_release_date.lte=$year-$monthString-$dayString&';
    }
    return '';
  }
}

class TV {
  final int id;
  final String imageUrl;
  final String title;

  TV(this.id, this.imageUrl, this.title);
}

class TvFilters {
  final bool? _includeAdult;
  final List<Genres>? _genres;
  final SortBy? _sortBy;
  final SortByDirection? _sortByDirection;
  final DateTime? _lteReleaseDate;

  TvFilters({
    bool includeAdult = false,
    List<Genres>? genres,
    SortBy sortBy = SortBy.popularity,
    SortByDirection sortByDirection = SortByDirection.ascending,
    DateTime? lteReleaseDate,
  }) : _includeAdult = includeAdult,
       _genres = genres,
       _sortBy = sortBy,
       _sortByDirection = sortByDirection,
       _lteReleaseDate = lteReleaseDate;

  get includeAdult {
    if (_includeAdult != null) {
      return 'include_adult=$_includeAdult&';
    }
    return '';
  }

  get genres {
    if (_genres != null) {
      String genresString = '';
      for (int i = 0; i < _genres.length; i++) {
        genresString += '${_genres[i].id}';
        if (i != _genres.length - 1) {
          genresString += ',';
          // genresString += '|';
        }
      }
      return 'with_genres=$genresString&';
    }
    return '';
  }

  String get sortByQuery {
    if (_sortBy == null) {
      return 'sort_by=popularity.desc&'; // Default if nothing selected
    }

    String sortByValue;
    switch (_sortBy) {
      case SortBy.title:
        sortByValue = 'title';
        break;
      case SortBy.releaseDate:
        sortByValue = 'first_air_date';
        break;
      // case SortBy.popularity:
      default:
        sortByValue = 'popularity';
        break;
    }
    // Default to descending if sortByDirection is null
    String direction =
        (_sortByDirection == null ||
                _sortByDirection == SortByDirection.descending)
            ? '.desc'
            : '.asc';
    return 'sort_by=$sortByValue$direction&';
  }

  String get lteReleaseDate {
    if (_lteReleaseDate != null) {
      int year = _lteReleaseDate.year;
      int month = _lteReleaseDate.month;
      int day = _lteReleaseDate.day;

      String monthString = month.toString();
      String dayString = day.toString();
      if (monthString.length == 1) {
        monthString = '0$monthString';
      }
      if (dayString.length == 1) {
        dayString = '0$dayString';
      }
      return 'first_air_date.lte=$year-$monthString-$dayString&';
    }
    return '';
  }
}

class Genres {
  final int id;
  final String name;

  Genres(this.id, this.name);
}

class Certification {
  final String certification;
  final String region;
  final int order;

  Certification(this.certification, this.region, this.order);
}

class TMDBApi {
  static Future<List<Movie>> getMovies(int page, MovieFilters filters) async {
    String uri =
        'https://api.themoviedb.org/3/discover/'
        'movie?'
        'include_video=false&'
        'language=en-US&'
        '${filters.includeAdult}'
        '${filters.certification}'
        '${filters.genres}'
        '${filters.lteReleaseDate}'
        '${filters.sortByQuery}'
        'page=$page&';
    // 'sort_by=popularity.desc';
    print(uri);
    print(filters.includeAdult);
    print(filters.certification);
    print(filters.genres);
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse(uri),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    List<Movie> result = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int results = data['results'].length;
      for (int i = 0; i < results; i++) {
        String imageUrl =
            'https://image.tmdb.org/t/p/w200${data['results'][i]['poster_path']}';
        if (data['results'][i]['poster_path'] == null) {
          imageUrl = 'null';
        }
        result.add(
          Movie(
            data['results'][i]['id'],
            imageUrl,
            data['results'][i]['title'] ?? 'No Title',
          ),
        );
      }
      return result;
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }

  static Future<List<Movie>> findMovie(
    int page,
    MovieFilters filters,
    String query,
  ) async {
    String uri =
        'https://api.themoviedb.org/3/search/'
        'movie?'
        'include_adult=false&'
        'language=en-US&'
        '${filters.includeAdult}'
        '${filters.certification}'
        '${filters.genres}'
        '${filters.lteReleaseDate}'
        '${filters.sortByQuery}'
        'page=$page&'
        'query=$query';
    print(uri);
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse(uri),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    List<Movie> result = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int results = data['results'].length;
      for (int i = 0; i < results; i++) {
        String imageUrl =
            'https://image.tmdb.org/t/p/w200${data['results'][i]['poster_path']}';
        if (data['results'][i]['poster_path'] == null) {
          imageUrl = 'null';
        }
        result.add(
          Movie(
            data['results'][i]['id'],
            imageUrl,
            data['results'][i]['title'] ?? 'No Title',
          ),
        );
      }
      return result;
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }

  static Future<List<TV>> getTVs(int page, TvFilters filters) async {
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final uri =
        'https://api.themoviedb.org/3/discover/'
        'tv?'
        'include_video=false&'
        'language=en-US&'
        '${filters.includeAdult}'
        '${filters.genres}'
        '${filters.lteReleaseDate}'
        '${filters.sortByQuery}'
        'page=$page&';
    print(uri);
    final response = await http.get(
      Uri.parse(uri),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    List<TV> result = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int results = data['results'].length;
      for (int i = 0; i < results; i++) {
        String imageUrl =
            'https://image.tmdb.org/t/p/w200${data['results'][i]['poster_path']}';
        if (data['results'][i]['poster_path'] == null) {
          imageUrl = 'null';
        }
        result.add(
          TV(
            data['results'][i]['id'],
            imageUrl,
            data['results'][i]['name'] ?? 'No Title',
          ),
        );
      }
      return result;
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }

  static Future<List<TV>> findTV(
    int page,
    TvFilters filters,
    String query,
  ) async {
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final uri =
        'https://api.themoviedb.org/3/search/'
        'tv?'
        'include_video=false&'
        'language=en-US&'
        '${filters.includeAdult}'
        '${filters.genres}'
        '${filters.lteReleaseDate}'
        '${filters.sortByQuery}'
        'page=$page&'
        'query=$query';
    print(uri);
    final response = await http.get(
      Uri.parse(uri),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    List<TV> result = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int results = data['results'].length;
      for (int i = 0; i < results; i++) {
        String imageUrl =
            'https://image.tmdb.org/t/p/w200${data['results'][i]['poster_path']}';
        if (data['results'][i]['poster_path'] == null) {
          imageUrl = 'null';
        }
        result.add(
          TV(
            data['results'][i]['id'],
            imageUrl,
            data['results'][i]['name'] ?? 'No Title',
          ),
        );
      }
      return result;
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }

  static Future<List<Genres>> getMovieGenres() async {
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/genre/movie/list?'
        'language=en',
      ),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    List<Genres> result = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int results = data['genres'].length;
      for (int i = 0; i < results; i++) {
        result.add(Genres(data['genres'][i]['id'], data['genres'][i]['name']));
      }
      return result;
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }

  static Future<List<Genres>> getTVGenres() async {
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/genre/tv/list?'
        'language=en',
      ),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    List<Genres> result = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int results = data['genres'].length;
      for (int i = 0; i < results; i++) {
        result.add(Genres(data['genres'][i]['id'], data['genres'][i]['name']));
      }
      return result;
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }

  static Future<List<Certification>> getMovieCertifications() async {
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/certification/movie/list?'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    List<Certification> result = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int results = data['certifications']['US'].length;
      for (int i = 0; i < results; i++) {
        result.add(
          Certification(
            data['certifications']['US'][i]['certification'],
            'US',
            data['certifications']['US'][i]['order'],
          ),
        );
      }
      return result;
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }

  static Future<List<Certification>> getTVCertifications() async {
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/certification/tv/list?'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    List<Certification> result = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int results = data['certifications']['US'].length;
      for (int i = 0; i < results; i++) {
        result.add(
          Certification(
            data['certifications']['US'][i]['certification'],
            'US',
            data['certifications']['US'][i]['order'],
          ),
        );
      }
      return result;
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }
}

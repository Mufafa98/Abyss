import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum SortBy { title, popularity, releaseDate }

enum SortByDirection { ascending, descending }

enum ProductionType { movie, tv }

class Production {
  final ProductionType type;
  final int id;
  final String _posterUrl;
  final String _backdropUrl;
  final String title;
  final String description;
  final List<int> genres;
  final DateTime releaseDate;
  final double rating;
  final String language;

  Production(
    this.type,
    this.id,
    String posterUrl,
    String backdropUrl,
    this.title,
    this.description,
    this.genres,
    this.releaseDate,
    this.rating,
    this.language,
  ) : _posterUrl = posterUrl,
      _backdropUrl = backdropUrl;
  static empty() {
    return Production(
      ProductionType.movie,
      0,
      '',
      '',
      '',
      '',
      [],
      DateTime.now(),
      0,
      '',
    );
  }

  String get posterW200 {
    if (_posterUrl != 'null') {
      return 'https://image.tmdb.org/t/p/w200$_posterUrl';
    }
    return _posterUrl;
  }

  String get backdropW500 {
    if (_backdropUrl != 'null') {
      return 'https://image.tmdb.org/t/p/w500$_backdropUrl';
    }
    return _backdropUrl;
  }
}

class CastMember {
  final int id;
  final String name;
  final String character;
  final String _pictureUrl;

  CastMember(this.id, this.name, this.character, String pictureUrl)
    : _pictureUrl = pictureUrl;

  String get profileW200 {
    if (_pictureUrl != 'null') {
      return 'https://image.tmdb.org/t/p/w200$_pictureUrl';
    }
    return _pictureUrl;
  }
}

class Movie extends Production {
  Movie(
    int id,
    String posterUrl,
    String backdropUrl,
    String title,
    String description,
    List<int> genres,
    DateTime releaseDate,
    double rating,
    String language,
  ) : super(
        ProductionType.movie,
        id,
        posterUrl,
        backdropUrl,
        title,
        description,
        genres,
        releaseDate,
        rating,
        language,
      );
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

class AditionalInfo {
  final int runtime;
  final List<CastMember> cast;

  AditionalInfo(this.runtime, this.cast);
  AditionalInfo.empty() : runtime = 0, cast = [];

  bool isEmpty() {
    return runtime == 0 && cast.isEmpty;
  }
}

class TV extends Production {
  TV(
    int id,
    String posterUrl,
    String backdropUrl,
    String title,
    String description,
    List<int> genres,
    DateTime releaseDate,
    double rating,
    String language,
  ) : super(
        ProductionType.tv,
        id,
        posterUrl,
        backdropUrl,
        title,
        description,
        genres,
        releaseDate,
        rating,
        language,
      );
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
  static List<Movie> _parseMovies(String responseBody) {
    List<Movie> result = [];
    final data = jsonDecode(responseBody);
    int resultsCount = data['results'].length;

    for (int i = 0; i < resultsCount; i++) {
      dynamic current = data['results'][i];
      List<int> genres = [];
      for (int j = 0; j < current['genre_ids'].length; j++) {
        genres.add(current['genre_ids'][j]);
      }
      DateTime releaseDate;
      if (current['release_date'] != null) {
        releaseDate = DateTime.parse(current['release_date']);
      } else {
        releaseDate = DateTime.now();
      }
      double rating = 0;
      if (current['vote_average'] != null) {
        rating = current['vote_average'].toDouble();
      }
      result.add(
        Movie(
          current['id'],
          current['poster_path'] ?? 'null',
          current['backdrop_path'] ?? 'null',
          current['title'] ?? 'No Title',
          current['overview'] ?? 'No Description',
          genres,
          releaseDate,
          rating,
          current['original_language'] ?? 'en',
        ),
      );
    }
    return result;
  }

  static List<TV> _parseTVs(String responseBody) {
    List<TV> result = [];
    final data = jsonDecode(responseBody);
    int resultsCount = data['results'].length;
    for (int i = 0; i < resultsCount; i++) {
      dynamic current = data['results'][i];
      List<int> genres = [];
      for (int j = 0; j < current['genre_ids'].length; j++) {
        genres.add(current['genre_ids'][j]);
      }
      DateTime releaseDate;
      if (current['first_air_date'] != null &&
          current['first_air_date'] != '') {
        releaseDate = DateTime.parse(current['first_air_date']);
      } else {
        releaseDate = DateTime.now();
      }
      double rating = 0;
      if (current['vote_average'] != null) {
        rating = current['vote_average'].toDouble();
      }
      result.add(
        TV(
          current['id'],
          current['poster_path'] ?? 'null',
          current['backdrop_path'] ?? 'null',
          current['name'] ?? 'No Title',
          current['overview'] ?? 'No Description',
          genres,
          releaseDate,
          rating,
          current['original_language'] ?? 'en',
        ),
      );
    }
    return result;
  }

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
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse(uri),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (response.statusCode == 200) {
      return _parseMovies(response.body);
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
    // print(uri);
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse(uri),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (response.statusCode == 200) {
      return _parseMovies(response.body);
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }

  static Future<AditionalInfo> getMovieInfo(int id) async {
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/$id?'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    int runtime = 0;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      runtime = data['runtime'];
    } else {
      throw Exception('Failed to load data on Movies info for id: $id');
    }
    List<CastMember> cast = [];
    final response2 = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/$id/credits?'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (response2.statusCode == 200) {
      final data = jsonDecode(response2.body);
      int resultsCount = data['cast'].length;
      for (int i = 0; i < resultsCount; i++) {
        dynamic current = data['cast'][i];
        cast.add(
          CastMember(
            current['id'],
            current['name'] ?? 'No Name',
            current['character'] ?? 'No Character',
            current['profile_path'] ?? 'null',
          ),
        );
      }
    } else {
      throw Exception('Failed to load data on Movies credits for id: $id');
    }
    return AditionalInfo(runtime, cast);
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
    // print(uri);
    final response = await http.get(
      Uri.parse(uri),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (response.statusCode == 200) {
      return _parseTVs(response.body);
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
    if (response.statusCode == 200) {
      return _parseTVs(response.body);
    } else {
      throw Exception('Failed to load data on Movies Ids');
    }
  }

  static Future<AditionalInfo> getTVInfo(int id) async {
    String apiKey = dotenv.env['TMDB_KEY'] ?? '';
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/tv/$id?'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    int runtime = 0;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      num sum = 0;
      if (data['episode_run_time'] == null ||
          data['episode_run_time'].length == 0) {
        runtime = 0;
      } else {
        for (int i = 0; i < data['episode_run_time'].length; i++) {
          sum += data['episode_run_time'][i];
        }
        runtime = sum ~/ data['episode_run_time'].length;
      }
    } else {
      throw Exception('Failed to load data on tv info for id: $id');
    }
    List<CastMember> cast = [];
    final response2 = await http.get(
      Uri.parse('https://api.themoviedb.org/3/tv/$id/credits?'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (response2.statusCode == 200) {
      final data = jsonDecode(response2.body);
      int resultsCount = data['cast'].length;
      for (int i = 0; i < resultsCount; i++) {
        dynamic current = data['cast'][i];
        cast.add(
          CastMember(
            current['id'],
            current['name'] ?? 'No Name',
            current['character'] ?? 'No Character',
            current['profile_path'] ?? 'null',
          ),
        );
      }
    } else {
      throw Exception('Failed to load data on tv credits for id: $id');
    }
    return AditionalInfo(runtime, cast);
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

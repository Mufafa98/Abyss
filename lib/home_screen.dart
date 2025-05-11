import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mutex/mutex.dart';
import 'navigation_bar.dart';
import 'tmdb_api.dart';

enum ProductionType { movie, tv }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<String> filters = ["Movies", "Popularity"];
  ProductionType productionType = ProductionType.movie;

  final List<Genres> _movieGenres = [];
  final List<Genres> _selectedMovieGenres = [];
  final List<Certification> _movieAgeRatings = [];
  final List<Certification> _selectedMovieAgeRatings = [];

  final List<Genres> _tvGenres = [];
  final List<Genres> _selectedTVGenres = [];
  bool includeAdult = false;

  SortBy _sortBy = SortBy.popularity;
  SortByDirection _sortByDirection = SortByDirection.descending;
  final Map<String, SortBy> _sortOptionsMap = {
    'Popularity': SortBy.popularity,
    'Release Date': SortBy.releaseDate,
    'Title': SortBy.title,
  };

  final ScrollController _scrollController = ScrollController();
  final Map<int, List<Movie>> _movieMap = {};
  final Mutex _movieMutex = Mutex();
  final Map<int, List<TV>> _tvMap = {};
  final Mutex _tvMutex = Mutex();
  int _currentPage = 1;
  int _lastPage = 5;
  bool _isLoading = false;

  bool _inSearch = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _loadContent();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.offset < (_currentPage - 5) * 1000 - 500) {
      return;
    }
    _updateContent();
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await TMDBApi.getMovieGenres();
      setState(() {
        _movieGenres.addAll(genres);
      });
    } catch (e) {
      print('Error loading movie genres: $e');
    }
    try {
      final genres = await TMDBApi.getTVGenres();
      setState(() {
        _tvGenres.addAll(genres);
      });
    } catch (e) {
      print('Error loading tv genres: $e');
    }
    try {
      final certifications = await TMDBApi.getMovieCertifications();
      setState(() {
        _movieAgeRatings.addAll(certifications);
      });
    } catch (e) {
      print('Error loading movie age ratings: $e');
    }
  }

  MovieFilters _getMovieFilters() {
    return MovieFilters(
      includeAdult: includeAdult,
      genres: _selectedMovieGenres.isEmpty ? null : _selectedMovieGenres,
      certification:
          _selectedMovieAgeRatings.isEmpty ? null : _selectedMovieAgeRatings[0],
      sortBy: _sortBy,
      sortByDirection: _sortByDirection,
      lteReleaseDate: DateTime.now(),
    );
  }

  TvFilters _getTvFilters() {
    return TvFilters(
      includeAdult: includeAdult,
      genres: _selectedTVGenres.isEmpty ? null : _selectedTVGenres,
      sortBy: _sortBy,
      sortByDirection: _sortByDirection,
      lteReleaseDate: DateTime.now(),
    );
  }

  Future<void> _loadContent() async {
    setState(() {
      _lastPage = 5;
      _movieMap.clear();
      _tvMap.clear();
    });
    if (productionType != ProductionType.tv) {
      for (int i = 1; i <= _lastPage; i++) {
        await _movieMutex.acquire();
        try {
          if (_movieMap.containsKey(i)) {
            continue;
          }
          List<Movie> newMovies;
          if (!_inSearch) {
            newMovies = await TMDBApi.getMovies(i, _getMovieFilters());
          } else {
            newMovies = await TMDBApi.findMovie(
              i,
              _getMovieFilters(),
              _searchQuery,
            );
          }
          setState(() {
            _movieMap[i] = newMovies;
          });
        } catch (e) {
          print('Error loading movies: $e');
        } finally {
          _movieMutex.release();
        }
      }
    } else {
      for (int i = 1; i <= _lastPage; i++) {
        await _tvMutex.acquire();
        try {
          if (!_tvMap.containsKey(i)) {
            List<TV> newTV;
            if (!_inSearch) {
              newTV = await TMDBApi.getTVs(i, _getTvFilters());
            } else {
              newTV = await TMDBApi.findTV(i, _getTvFilters(), _searchQuery);
            }
            setState(() {
              _tvMap[i] = newTV;
            });
          }
        } catch (e) {
          print('Error loading tvs: $e');
        } finally {
          _tvMutex.release();
        }
      }
    }
  }

  Future<void> _updateContent() async {
    if (_isLoading) {
      return;
    }
    try {
      if (productionType == ProductionType.tv) {
        await _tvMutex.acquire();
        setState(() => _isLoading = true);
        if (!_tvMap.containsKey(_lastPage)) {
          List<TV> newTV;
          if (!_inSearch) {
            newTV = await TMDBApi.getTVs(_lastPage, _getTvFilters());
          } else {
            newTV = await TMDBApi.findTV(
              _lastPage,
              _getTvFilters(),
              _searchQuery,
            );
          }
          setState(() {
            _tvMap[_lastPage] = newTV;
          });
        }
        setState(() => _isLoading = false);
        _tvMutex.release();
      } else {
        await _movieMutex.acquire();
        setState(() => _isLoading = true);
        if (!_movieMap.containsKey(_lastPage)) {
          List<Movie> newMovies;
          if (!_inSearch) {
            newMovies = await TMDBApi.getMovies(_lastPage, _getMovieFilters());
          } else {
            newMovies = await TMDBApi.findMovie(
              _lastPage,
              _getMovieFilters(),
              _searchQuery,
            );
          }
          setState(() {
            _movieMap[_lastPage] = newMovies;
          });
        }
        setState(() => _isLoading = false);
        _movieMutex.release();
      }
      setState(() {
        _lastPage += 1;
        _currentPage += 1;
      });
    } catch (e) {
      print('Error updating movies: $e');
      setState(() => _isLoading = false);
    } finally {}
  }

  Widget _buildSearchBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: TextField(
        cursorColor: theme.colorScheme.onPrimary,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(fontWeight: FontWeight.bold),
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide.none, // No border
            borderRadius: BorderRadius.circular(30.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none, // No border when enabled
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none, // No border when focused
            borderRadius: BorderRadius.circular(30.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none, // No border when disabled
            borderRadius: BorderRadius.circular(30.0),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          filled: true,
          fillColor: theme.colorScheme.primary,
        ),
        onSubmitted: (value) {
          if (value.isEmpty) {
            setState(() {
              _inSearch = false;
              _searchQuery = '';
            });
          } else {
            setState(() {
              _searchQuery = value;
              _inSearch = true;
            });
          }
          _loadContent();
        },
      ),
    );
  }

  // -----------------> Filter Bar <-----------------

  Widget _getChipIcon(
    String filter,
    Color selectedColor,
    Color unselectedColor,
  ) {
    Color color;
    IconData icon;
    double size = 20.0;
    if (!filters.contains(filter)) {
      icon = Icons.circle;
      color = unselectedColor;
    } else {
      color = selectedColor;
      if (_sortOptionsMap.keys.contains(filter)) {
        if (_sortByDirection == SortByDirection.ascending) {
          icon = Icons.arrow_circle_up_rounded;
        } else {
          icon = Icons.arrow_circle_down_rounded;
        }
      } else {
        icon = Icons.remove_circle;
      }
    }
    return Icon(icon, color: color, size: size);
  }

  Widget _buildFilterBar(List<String> filters, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [_buildFilterButton(), _buildFilterChips(filters, context)],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: SizedBox(
        height: 40,
        child: FloatingActionButton.extended(
          onPressed: () {
            _showFilterPopup(context);
          },
          icon: Icon(Icons.filter_list),
          label: Text("Filter", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<String> filters, BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Widget> filterCips =
        filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: ActionChip(
                  label: Row(
                    children: [
                      Text(filter),
                      Padding(padding: EdgeInsets.only(right: 10)),
                      _getChipIcon(
                        filter,
                        theme.colorScheme.tertiary,
                        theme.colorScheme.onPrimary,
                      ),
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      if (filter == 'Movies') {
                        productionType = ProductionType.tv;
                        _selectedMovieGenres.clear();
                        filters.clear();
                        filters.add("TVs");
                        filters.add("Popularity");
                      } else if (filter == 'TVs') {
                        productionType = ProductionType.movie;
                        _selectedTVGenres.clear();
                        filters.clear();
                        filters.add("Movies");
                        filters.add("Popularity");
                      } else if (_movieAgeRatings
                          .map((rating) => rating.certification)
                          .contains(filter)) {
                        _selectedMovieAgeRatings.removeWhere(
                          (rating) => rating.certification == filter,
                        );
                        filters.remove(filter);
                      } else if (_sortOptionsMap.keys.contains(filter)) {
                        if (_sortByDirection == SortByDirection.ascending) {
                          _sortByDirection = SortByDirection.descending;
                        } else {
                          _sortByDirection = SortByDirection.ascending;
                        }
                      } else {
                        if (productionType == ProductionType.movie) {
                          _selectedMovieGenres.removeWhere(
                            (genre) => genre.name == filter,
                          );
                          filters.remove(filter);
                        } else {
                          _selectedTVGenres.removeWhere(
                            (genre) => genre.name == filter,
                          );
                          filters.remove(filter);
                        }
                      }
                    });
                    _loadContent();
                  },
                  backgroundColor: theme.colorScheme.secondary,
                  shape: StadiumBorder(
                    side: BorderSide(
                      width: 0.0, // Border thickness
                    ),
                  ),
                ),
              ),
            )
            .toList();
    filterCips.insert(0, Padding(padding: EdgeInsets.only(left: 15)));
    filterCips.add(Padding(padding: EdgeInsets.only(right: 15)));

    Widget buildCips(List filters) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: filterCips),
      );
    }

    return Expanded(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.1, 0.9, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: buildCips(filters),
      ),
    );
  }

  // -----------------> Filter Bar <-----------------
  // ------------------------------------------------
  // ----------------> Filter Popup <----------------

  void _showFilterPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildFilterContent(setModalState)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterContent(StateSetter setModalState) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(
              title: 'Production Type',
              options: ['Movies', 'TVs'],
              setModalState: setModalState,
            ),
            _buildFilterSection(
              title: 'Genre',
              options:
                  productionType == ProductionType.movie
                      ? _movieGenres.map((genre) => genre.name).toList()
                      : _tvGenres.map((genre) => genre.name).toList(),
              setModalState: setModalState,
            ),
            if (productionType == ProductionType.movie)
              _buildFilterSection(
                title: 'Age Rating',
                options:
                    _movieAgeRatings
                        .map((raiting) => raiting.certification)
                        .toList(),
                setModalState: setModalState,
              ),
            _buildFilterSection(
              title: 'Sort By',
              options: _sortOptionsMap.keys.toList(), // Use keys from your map
              setModalState: setModalState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required StateSetter setModalState,
  }) {
    ThemeData theme = Theme.of(context);
    List<Widget> filterChips =
        options.map((option) {
          final bool isSelected = filters.contains(option);
          return Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: IntrinsicWidth(
              child: Builder(
                builder: (context) {
                  return ActionChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(option),
                        SizedBox(width: 4),
                        _getChipIcon(
                          option,
                          theme.colorScheme.tertiary,
                          theme.colorScheme.onPrimary,
                        ),
                      ],
                    ),
                    onPressed: () {
                      print('Selected: $option');
                      setModalState(() {
                        if (title == 'Production Type') {
                          if (option == 'Movies') {
                            productionType = ProductionType.movie;
                          } else {
                            productionType = ProductionType.tv;
                          }
                          filters.clear();
                          filters.add(option);
                        } else if (title == 'Genre') {
                          if (productionType == ProductionType.movie) {
                            if (isSelected) {
                              _selectedMovieGenres.removeWhere(
                                (genre) => genre.name == option,
                              );
                              filters.remove(option);
                            } else {
                              _selectedMovieGenres.add(
                                _movieGenres.firstWhere(
                                  (genre) => genre.name == option,
                                ),
                              );
                              filters.add(option);
                            }
                          } else {
                            if (isSelected) {
                              _selectedTVGenres.removeWhere(
                                (genre) => genre.name == option,
                              );
                              filters.remove(option);
                            } else {
                              _selectedTVGenres.add(
                                _tvGenres.firstWhere(
                                  (genre) => genre.name == option,
                                ),
                              );
                              filters.add(option);
                            }
                          }
                        } else if (title == 'Age Rating') {
                          if (isSelected) {
                            _selectedMovieAgeRatings.removeWhere(
                              (rating) => rating.certification == option,
                            );
                            filters.remove(option);
                          } else {
                            _selectedMovieAgeRatings.clear();
                            filters.removeWhere(
                              (filterElement) => _movieAgeRatings
                                  .map((rating) => rating.certification)
                                  .contains(filterElement),
                            );

                            _selectedMovieAgeRatings.add(
                              _movieAgeRatings.firstWhere(
                                (rating) => rating.certification == option,
                              ),
                            );
                            filters.add(option);
                          }
                        } else if (title == 'Sort By') {
                          if (isSelected) {
                            if (_sortByDirection == SortByDirection.ascending) {
                              _sortByDirection = SortByDirection.descending;
                            } else {
                              _sortByDirection = SortByDirection.ascending;
                            }
                          } else {
                            _sortBy = _sortOptionsMap[option]!;
                            _sortByDirection = SortByDirection.descending;
                            filters.removeWhere(
                              (filterElement) =>
                                  _sortOptionsMap.keys.contains(filterElement),
                            );
                            filters.add(option);
                          }
                        } else {
                          if (isSelected) {
                            filters.remove(option);
                          } else {
                            filters.add(option);
                          }
                        }
                      });
                      setState(() {});
                    },
                    backgroundColor: theme.colorScheme.secondary,
                    labelStyle: TextStyle(color: theme.colorScheme.onSecondary),
                    shape: StadiumBorder(side: BorderSide(width: 0)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                },
              ),
            ),
          );
        }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: filterChips),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  _movieMap.clear();
                  _tvMap.clear();
                  // _updateContent();

                  _loadContent();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------> Filter Popup <----------------

  Widget _buildContentSection() {
    return Expanded(
      child: AlignedGridView.count(
        shrinkWrap: false,
        controller: _scrollController,
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        itemBuilder: (context, index) {
          int page = index ~/ 20 + 1;
          if (productionType == ProductionType.movie) {
            List<Movie>? moviePage = _movieMap[page];

            if (moviePage == null) {
              return _buildLoader();
            }
            if (index >= _movieMap.length * moviePage.length) {
              return _buildEmpty();
            }
            if (moviePage.isEmpty) {
              return _buildNoResults();
            }

            Movie movie = moviePage[index % moviePage.length];
            return _buildMovieWidget(movie.imageUrl, movie.title);
          } else {
            List<TV>? tvPage = _tvMap[page];

            if (tvPage == null) {
              return _buildLoader();
            }
            if (index >= _tvMap.length * tvPage.length) {
              return _buildEmpty();
            }
            if (tvPage.isEmpty) {
              return _buildNoResults();
            }

            TV tv = tvPage[index % tvPage.length];
            return _buildMovieWidget(tv.imageUrl, tv.title);
          }
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'No results found',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          '',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMovieWidget(String moviePoster, String title) {
    Widget noImage(String title) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red),
              Text(
                'No image for\n$title',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (moviePoster == 'null') {
      return noImage(title);
    }
    try {
      return ActionChip(
        label: Image.network(
          moviePoster,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          errorBuilder: (context, error, stackTrace) {
            return noImage(title);
          },
        ),
        padding: EdgeInsets.all(0),
        labelPadding: EdgeInsets.all(0),
        onPressed: () {
          print('Clicked on $title');
        },
        backgroundColor: Colors.transparent,
        shape: BeveledRectangleBorder(side: BorderSide(width: 0)),
      );
    } catch (e) {
      return noImage(title);
    }
  }

  Widget _buildNavBar() {
    return AbyssNavigationBar(initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;

    return MaterialApp(
      title: 'HomeScreen',
      theme: Theme.of(context),
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context),
              _buildFilterBar(filters, context),
              _buildContentSection(),
              _buildNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}

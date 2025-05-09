import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'navigation_bar.dart';
import 'tmdb_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List filters = [];

  final ScrollController _scrollController = ScrollController();
  final Map<int, List<Movie>> _movieMap = {};
  int _currentPage = 1;
  int _lastPage = 5;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMoviesInit();
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
    if (!_isLoading) {
      _loadMovies();
    }
  }

  Future<void> _loadMoviesInit() async {
    for (int i = 1; i <= _lastPage; i++) {
      if (_isLoading) return;

      setState(() => _isLoading = true);

      try {
        if (!_movieMap.containsKey(i)) {
          final newMovies = await TMDBApi.get_movies_ids(i);
          setState(() {
            _movieMap[i] = newMovies;
          });
        }
      } catch (e) {
        print('Error loading movies: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMovies() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (!_movieMap.containsKey(_lastPage)) {
        final newMovies = await TMDBApi.get_movies_ids(_lastPage);
        setState(() {
          _movieMap[_lastPage] = newMovies;
        });
      }
      setState(() {
        _lastPage += 1;
        _currentPage += 1;
      });
    } catch (e) {
      print('Error loading movies: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSearchBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: TextField(
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
      ),
    );
  }

  Widget _buildFilterBar(List filters, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
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

  // ----------------->

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
              // Pass setModalState
              setModalState: setModalState,
            ),
            _buildFilterSection(
              title: 'Genre',
              options: [
                'Action',
                'SF',
                'Adventure',
                'Comedy',
                'Mystery',
                'History',
                'Horror',
                'Romance',
                'Thriller',
              ],
              // Pass setModalState
              setModalState: setModalState,
            ),
            _buildFilterSection(
              title: 'Age Rating',
              options: [
                'TV-Y',
                'TV-Y7',
                'TV-Y7 FV',
                'TV-G',
                'TV-PG',
                'TV-14',
                'TV-MA',
                'PG',
                'PG-13',
                'R',
                'NC-17',
              ],
              // Pass setModalState
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
                        isSelected
                            ? Icon(
                              Icons.remove_circle,
                              size: 18,
                              color: theme.colorScheme.tertiary,
                            )
                            : Icon(
                              Icons.circle,
                              size: 18,
                              color: theme.colorScheme.onPrimary,
                            ),
                      ],
                    ),
                    onPressed: () {
                      setModalState(() {
                        if (isSelected) {
                          filters.remove(option);
                        } else {
                          filters.add(option);
                        }
                        print(filters);
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

  // ...rest of your HomeScreenState code...
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
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------->

  Widget _buildFilterChips(List filters, BuildContext context) {
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
                      Icon(
                        Icons.remove_circle,
                        color: theme.colorScheme.tertiary,
                      ),
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      filters.remove(filter);
                      if (filters.isEmpty) {
                        filters = [];
                      }
                    });
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
          if (index >= _movieMap.length * 20) {
            return _buildLoader();
          }
          return _buildMovieWidget(_movieMap[page]![index % 20].imageUrl);
        },
      ),
    );
  }

  Widget _buildLoader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMovieWidget(String moviePoster) {
    return Image.network(
      moviePoster,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
    );
  }

  Widget _buildNavBar() {
    return AbyssNavigationBar(initialIndex: 0);
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

import 'package:abyss/tmdb_api.dart';
import 'package:flutter/material.dart';

class WatchListProvider extends ChangeNotifier {
  List<ProdBase> _watchList = [];

  WatchListProvider();

  // List<ProdBase> get watchList => _watchList;
  // set watchList(List<ProdBase> list) {
  //   _watchList = list;
  //   notifyListeners();
  // }

  void addToWatchList(ProdBase production) {
    _watchList.add(production);
    notifyListeners();
  }

  void removeFromWatchList(ProdBase production) {
    _watchList.removeWhere((currentProd) => currentProd.id == production.id);
    notifyListeners();
  }

  void updateWatchList(TV production) {
    int index = _watchList.indexWhere((prod) => prod.id == production.id);
    if (index != -1) {
      _watchList[index] = production;
      notifyListeners();
      return;
    }
  }

  bool isInWatchList(int prodId) {
    return _watchList.any((production) => production.id == prodId);
  }

  int listLength() {
    int len = 0;
    for (var production in _watchList) {
      if (production is Movie) {
        len++;
      } else if (production is TV) {
        if (production.episodes != []) {
          len += 1;
        }
      }
    }
    return len;
  }

  bool isEmpty() {
    return listLength() == 0;
  }

  @override
  String toString() {
    return 'WatchListProvider{_watchList: $_watchList}';
  }

  ProdBase operator [](int index) {
    int start = 0;
    for (int i = 0; i < _watchList.length; i++) {
      ProdBase production = _watchList[i];
      if (production is Movie) {
        if (start == index) {
          return production;
        }
        start++;
      } else if (production is TV) {
        if (production.episodes != []) {
          for (int i = production.progress; i < 1 + production.progress; i++) {
            if (start == index) {
              String image =
                  production.episodes[i].stillW200 != 'null'
                      ? production.episodes[i].stillW200
                      : production.backdropW200;
              ProdBase temp = ProdBase(
                production.episodes[i].name,
                image,
                image,
                production.id,
                production.type,
              );
              return temp;
            }
            start++;
          }
        }
      }
    }
    throw Exception('Index $index out of bounds');
  }

  ProdBase getParent(int index) {
    int start = 0;
    for (var production in _watchList) {
      if (production is Movie) {
        if (start == index) {
          return production;
        }
        start++;
      } else if (production is TV) {
        if (production.episodes != []) {
          if (start == index) {
            return production;
          }
          start++;
        }
      }
    }
    throw Exception('Index out of bounds');
  }
}

class WatchedListProvider extends ChangeNotifier {
  List<ProdBase> _watchedList = [];

  WatchedListProvider();

  int get movieCount {
    int count = 0;
    for (var production in _watchedList) {
      if (production is Movie) {
        count++;
      }
    }
    return count;
  }

  int get tvCount {
    int count = 0;
    for (var production in _watchedList) {
      if (production is TV) {
        count++;
      }
    }
    return count;
  }

  int get episodeCount {
    int count = 0;
    for (var production in _watchedList) {
      if (production is TV) {
        count += production.progress;
      }
    }
    return count;
  }

  void clearWatchedList() {
    _watchedList.clear();
    notifyListeners();
  }

  void addToWatchedList(ProdBase production) {
    _watchedList.add(production);
    notifyListeners();
  }

  void addSingleToWatchedList(ProdBase production) {
    if (_watchedList.any((prod) => prod.id == production.id)) {
      return;
    }
    _watchedList.add(production);
    notifyListeners();
  }

  void removeFromWatchedList(ProdBase production) {
    _watchedList.removeWhere((currentProd) => currentProd.id == production.id);
    notifyListeners();
  }

  void updateWatchList(TV production) {
    int index = _watchedList.indexWhere((prod) => prod.id == production.id);
    if (index != -1) {
      _watchedList[index] = production;
      notifyListeners();
      return;
    }
  }

  bool isInWatchedList(int prodId) {
    return _watchedList.any((production) => production.id == prodId);
  }

  int listLength() {
    int len = 0;
    for (var production in _watchedList) {
      if (production is Movie) {
        len++;
      } else if (production is TV) {
        if (production.episodes != []) {
          len += production.progress;
        }
      }
    }
    return len;
  }

  bool isEmpty() {
    return listLength() == 0;
  }

  @override
  String toString() {
    return 'WatchedListProvider{_watchedList: $_watchedList}';
  }

  ProdBase operator [](int index) {
    int start = 0;
    for (var production in _watchedList) {
      if (production is Movie) {
        if (start == index) {
          return production;
        }
        start++;
      } else if (production is TV) {
        if (production.episodes != []) {
          for (int i = 0; i < production.progress; i++) {
            if (start == index) {
              String image =
                  production.episodes[i].stillW200 != 'null'
                      ? production.episodes[i].stillW200
                      : production.backdropW200;
              ProdBase temp = ProdBase(
                production.episodes[i].name,
                image,
                image,
                production.id,
                production.type,
              );
              return temp;
            }
            start++;
          }
        }
      }
    }
    throw Exception('Index $index out of bounds');
  }

  int getIndexInTV(int index) {
    int auxIdx = 0;
    for (var production in _watchedList) {
      int start = 0;
      if (production is Movie) {
        if (auxIdx == index) {
          return start;
        }
        start++;
        auxIdx++;
      } else if (production is TV) {
        if (production.episodes != []) {
          for (int i = 0; i < production.progress; i++) {
            if (auxIdx == index) {
              return start;
            }
            start++;
            auxIdx++;
          }
        }
      }
    }
    throw Exception('Index $index out of bounds');
  }

  ProdBase getParent(int index) {
    int start = 0;
    for (var production in _watchedList) {
      if (production is Movie) {
        if (start == index) {
          return production;
        }
        start++;
      } else if (production is TV) {
        if (production.episodes != []) {
          for (int i = 0; i < production.progress; i++) {
            if (start == index) {
              return production;
            }
            start++;
          }
        }
      }
    }
    throw Exception('Index out of bounds');
  }
}

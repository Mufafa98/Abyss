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
          len += production.progress + 1;
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
    for (var production in _watchList) {
      if (production is Movie) {
        if (start == index) {
          return production;
        }
        start++;
      } else if (production is TV) {
        if (production.episodes != []) {
          for (
            int i = 0;
            i < production.episodes.length - production.progress;
            i++
          ) {
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
    throw Exception('Index out of bounds');
  }

  void notify() {
    notifyListeners();
  }
}

class WatchedListProvider extends ChangeNotifier {
  List<ProdBase> _watchedList = [];

  WatchedListProvider();

  // List<ProdBase> get watchedList => _watchedList;
  // set watchedList(List<ProdBase> list) {
  //   _watchedList = list;
  //   notifyListeners();
  // }

  void addToWatchedList(ProdBase production) {
    _watchedList.add(production);
    notifyListeners();
  }

  void removeFromWatchedList(ProdBase production) {
    _watchedList.removeWhere((currentProd) => currentProd.id == production.id);
    notifyListeners();
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
          len += production.progress + production.episodes.length;
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
    throw Exception('Index out of bounds');
  }
}

import 'package:abyss/navigation_bar.dart';
import 'package:abyss/tmdb_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'prod_list_provider.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  late ScrollController _scrollController;
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildProdChip(
    BuildContext context,
    ProdBase prod,
    bool isWatched,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Image.network(
            prod.backdropW200,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                width: 100,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Image not available',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    prod.title,
                    style: const TextStyle(fontSize: 20),
                    softWrap: true,
                  ),
                ),
                IconButton(
                  icon:
                      isWatched
                          ? Icon(
                            Icons.check_circle,
                            size: 35,
                            color: Theme.of(context).colorScheme.tertiary,
                          )
                          : Icon(Icons.check_circle, size: 35),
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final watchedListProvider = Provider.of<WatchedListProvider>(context);
    final watchListProvider = Provider.of<WatchListProvider>(context);
    final totalElements =
        watchedListProvider.listLength() + watchListProvider.listLength() + 1;
    if (!_initialScrollDone &&
        (!watchedListProvider.isEmpty() || !watchListProvider.isEmpty())) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          final watchedItemsCount = watchedListProvider.listLength();

          const double estimatedItemHeight = 116.0;

          double scrollToOffset = watchedItemsCount * estimatedItemHeight;

          if (scrollToOffset > _scrollController.position.maxScrollExtent) {
            scrollToOffset = _scrollController.position.maxScrollExtent;
          }
          if (scrollToOffset < 0) {
            scrollToOffset = 0;
          }

          _scrollController.jumpTo(scrollToOffset);

          if (mounted) {
            setState(() {
              _initialScrollDone = true;
            });
          }
        }
      });
    }
    if (totalElements == 0 ||
        (totalElements == 1 &&
            !(!watchedListProvider.isEmpty() ||
                !watchListProvider.isEmpty()))) {
      return Expanded(child: Center(child: Text("No items to display.")));
    }
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: totalElements,
        itemBuilder: (context, index) {
          if (index <= watchedListProvider.listLength()) {
            if (index == watchedListProvider.listLength()) {
              return const Divider(indent: 10, endIndent: 10);
            }
            return _buildProdChip(
              context,
              watchedListProvider[index],
              true,
              () {
                watchListProvider.addToWatchList(watchedListProvider[index]);
                watchedListProvider.removeFromWatchedList(
                  watchedListProvider[index],
                );
              },
            );
          } else {
            final newIndex = index - watchedListProvider.listLength() - 1;
            ProdBase prod = watchListProvider[newIndex];
            return _buildProdChip(context, prod, false, () {
              if (watchListProvider[newIndex].type == ProductionType.tv) {
                print("TV prod");
                (watchListProvider[newIndex] as TV).progress += 1;
                watchListProvider.notify();
                // TODO update state
              } else {
                watchedListProvider.addToWatchedList(prod);
                watchListProvider.removeFromWatchList(prod);
              }
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track')),
      body: Column(
        children: [_buildContent(context), AbyssNavigationBar(initialIndex: 0)],
      ),
    );
  }
}

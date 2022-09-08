part of '../widgets.dart';

class SearchShopStoreDelegate extends SearchDelegate {
  HistoryBloc historyBloc = HistoryBloc();
  @override
  final String searchFieldLabel;

  SearchShopStoreDelegate() : searchFieldLabel = 'Buscar por nombre';
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    /* TODO return something */
    return IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_ios));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('buildResults');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    historyBloc.getAllHistory();

    if (query.isEmpty) {
      return StreamBuilder(
        stream: historyBloc.scansStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<HistoryModel>> snapshot) {
          if (snapshot.hasData) {
            return listViewBlocHistory(snapshot.data!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      final suggestionList = shopData
          .where((element) =>
              element.shopName.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
      return listViewItems(suggestionList);
    }
  }

  ListView listViewItems(List<ShopModel> suggestionList) {
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, i) {
        return renderItemList(context, suggestionList[i], true);
      },
    );
  }

  ListView listViewBlocHistory(List<HistoryModel> suggestionList) {
    final pinterHistory = suggestionList
        .map((e) => shopData
            .firstWhere(((shopData) => shopData.shopName == (e.querySearched))))
        .toList();
    return ListView.builder(
      itemCount: pinterHistory.length,
      itemBuilder: (context, i) {
        return renderItemList(context, pinterHistory[i], false);
      },
    );
  }

  Widget renderItemList(
      BuildContext context, ShopModel suggestionItem, bool registerHistory) {
    final double sizeImage = 40;
    if (!registerHistory) {
      return ListTile(
        leading: const Icon(Icons.history),
        trailing: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset(suggestionItem.imageAsset,
              width: sizeImage, height: sizeImage),
        ),
        title: Text(suggestionItem.shopName.toTitleCase()),
        onLongPress: () => showAlertDialog(context),
        onTap: () {
          launchURL(suggestionItem.goToUrl);
          historyBloc
              .newHistory(HistoryModel(querySearched: suggestionItem.shopName));
        },
      );
    }
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(suggestionItem.imageAsset,
            width: sizeImage, height: sizeImage),
      ),
      title: Text(suggestionItem.shopName.toTitleCase()),
      onTap: () {
        launchURL(suggestionItem.goToUrl);
        if (registerHistory) {
          historyBloc
              .newHistory(HistoryModel(querySearched: suggestionItem.shopName));
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../logic/lottery_logic.dart'; // Importante para obtener los textos

class FavoritesScreen extends StatelessWidget {
  final TextEditingController filterController;
  final String Function(String) getLabel;
  final VoidCallback onShowOracle;
  final Function(int, Map) onToggleWinner;
  final Function(int) onDeleteFav;

  const FavoritesScreen({
    super.key,
    required this.filterController,
    required this.getLabel,
    required this.onShowOracle,
    required this.onToggleWinner,
    required this.onDeleteFav,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          bottom: TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: getLabel('tab_favs')),
              Tab(text: getLabel('tab_historial')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFavoritesTab(),
            _buildOracleHistoryList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amber,
          onPressed: onShowOracle,
          child: const Icon(Icons.visibility, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    var box = Hive.box('favorites');
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        List favs = box.values.toList();
        if (filterController.text.isNotEmpty) {
          favs = favs.where((f) => f['title'].toString().toLowerCase().contains(filterController.text.toLowerCase())).toList();
        }

        int winnersCount = box.values.where((f) => f['isWinner'] == true).length;

        return Column(
          children: [
            const SizedBox(height: 20),
            if (winnersCount > 0)
              Chip(
                backgroundColor: Colors.amber.withOpacity(0.2),
                label: Text("${getLabel('ganados')}: $winnersCount ✨", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: filterController,
                decoration: InputDecoration(
                  hintText: getLabel('buscar'),
                  prefixIcon: const Icon(Icons.search, color: Colors.amber),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            Expanded(
              child: favs.isEmpty ? const Center(child: Text("Sin favoritos")) : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: favs.length,
                itemBuilder: (context, index) {
                  final fav = favs[index];
                  int realIndex = box.values.toList().indexOf(fav);
                  bool isWinner = fav['isWinner'] ?? false;

                  return Card(
                    color: isWinner ? const Color(0xFF2D2600) : const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isWinner ? Colors.amber : Colors.transparent, width: 1.5),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                                fav['title'] ?? "",
                                style: TextStyle(
                                    color: isWinner ? Colors.amber : Colors.white,
                                    fontWeight: isWinner ? FontWeight.bold : FontWeight.normal
                                )
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1A1A1A),
                                  shape: RoundedRectangleBorder(
                                      side: const BorderSide(color: Colors.amber),
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  title: const Text("Detalle Místico", style: TextStyle(color: Colors.amber)),
                                  content: Text(LotteryLogic.getInfoText("favorito", "", "es")),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("ENTENDIDO", style: TextStyle(color: Colors.amber))
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      subtitle: Text("${fav['content']}\n${fav['date']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(isWinner ? Icons.emoji_events : Icons.emoji_events_outlined, color: isWinner ? Colors.amber : Colors.grey),
                            onPressed: () => onToggleWinner(realIndex, fav),
                          ),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => onDeleteFav(realIndex)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOracleHistoryList() {
    var historyBox = Hive.box('resultsHistory');
    return ValueListenableBuilder(
      valueListenable: historyBox.listenable(),
      builder: (context, Box box, _) {
        List results = box.values.toList().reversed.toList();
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey.withOpacity(0.5)),
                const SizedBox(height: 10),
                const Text("No has verificado sorteos aún", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final res = results[index];
            bool esAcierto = res['match'] ?? false;

            return Card(
              color: esAcierto ? Colors.green.withOpacity(0.1) : const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: esAcierto ? Colors.green : Colors.white12,
                  width: esAcierto ? 1.5 : 1.0,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: esAcierto ? Colors.green : Colors.amber.withOpacity(0.1),
                  child: Icon(
                    esAcierto ? Icons.star : Icons.history_toggle_off,
                    color: esAcierto ? Colors.white : Colors.amber,
                  ),
                ),
                title: Text(
                  res['lottery'] ?? "Sorteo",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Text(
                  "Número: ${res['number']}",
                  style: TextStyle(color: esAcierto ? Colors.greenAccent : Colors.grey),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(res['date'] ?? "", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    if (esAcierto)
                      const Text("¡ACIERTO!", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
import 'package:chess_repertoire/models/chess_tree_node.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class ChessTreeNodeNotifier extends StateNotifier<Map<String, ChessTreeNode>> {
  ChessTreeNodeNotifier()
      : super({
          Chess.initial.fen: ChessTreeNode(
              fen: Chess.initial.fen,
              playedMove: 'Starting Position',
              fromNodes: {},
              nodePosition: Chess.initial)
        });

  void addNodeToRegsitry(String fen, ChessTreeNode newChessTreeNode) {
    state = {
      ...state,
      fen: newChessTreeNode,
    };
  }

  Future<Database> createDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, 'repertoirePositions.db'),
      onCreate: (db, version) async {
        return db.execute(
            'CREATE TABLE IF NOT EXISTS repertoire_positions(fen TEXT PRIMARY KEY, playedMove TEXT)');
      },
      version: 1,
    );

    await db.execute(
        'CREATE TABLE IF NOT EXISTS node_relationships(id INTEGER PRIMARY KEY AUTOINCREMENT, from_fen TEXT NOT NULL, to_fen TEXT NOT NULL, move TEXT NOT NULL, FOREIGN KEY (from_fen) REFERENCES repertoire_positions(fen), FOREIGN KEY (to_fen) REFERENCES repertoire_positions(fen))');

    return db;
  }

  void loadNodesFromDatabase() async {
    Database db = await createDatabase();

    final data = await db.query('repertoire_positions');
    print('TESTESTEST');
    print(data);
  }

  void saveNodesToDatabase() async {
    Database db = await createDatabase();

    for (var node in state.entries) {
      db.insert('repertoire_positions', {
        'fen': node.value.fen,
        'playedMove': node.value.playedMove,
      });
    }
  }

  Map<String, ChessTreeNode> getNodeRegistry() {
    return state;
  }

  ChessTreeNode? getNodeFromRegistry(String fen) {
    return state[fen];
  }
}

final chessTreeNodeProvider =
    StateNotifierProvider<ChessTreeNodeNotifier, Map<String, ChessTreeNode>>(
  (ref) => ChessTreeNodeNotifier(),
);

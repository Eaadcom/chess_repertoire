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
              playedMove: '',
              fromNodes: {},
              nodePosition: Chess.initial)
        });

  void addNodeToRegsitry(String fen, ChessTreeNode newChessTreeNode) {
    state = {
      ...state,
      fen: newChessTreeNode,
    };
  }

  void saveNodesToDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, 'repertoirePositions.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE repertoire_positions(fen TEXT PRIMARY KEY, playedMove TEXT, )',
          // Requirements: saving the FEN, saving the references to FENS, saving the moves
        );
      },
      version: 1,
    );
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

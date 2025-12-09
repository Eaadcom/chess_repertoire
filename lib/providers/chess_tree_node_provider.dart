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
              toNodes: {},
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

  Future<ChessTreeNode> loadNodesFromDatabase() async {
    Database db = await createDatabase();

    final nodeData = await db.query('repertoire_positions');
    // Tradeoff made here to query the whole relationships table at once to avoid the overhead of doing multiple queries
    final relationsData = await db.query('node_relationships');

    // Map repertoire_positions to node objects
    for (var node in nodeData) {
      String newChessNodeFen = node['fen'] as String;
      ChessTreeNode newChessTreeNode = ChessTreeNode(
        fen: newChessNodeFen,
        playedMove: node['playedMove'] as String,
        savedToRepertoire: true,
        fromNodes: {},
        toNodes: {},
        nodePosition: Position.setupPosition(
          Rule.chess,
          Setup.parseFen(
            newChessNodeFen,
          ),
        ),
      );

      for (var relation in relationsData) {
        // Map fromNode relationships
        if (relation['to_fen'] as String == newChessNodeFen) {
          newChessTreeNode.fromNodes[relation['move'] as String] =
              Position.setupPosition(
            Rule.chess,
            Setup.parseFen(relation['from_fen'] as String),
          );
        }
        // Map toNode relationships
        if (relation['from_fen'] as String == newChessNodeFen) {
          newChessTreeNode.toNodes[relation['move'] as String] =
              Position.setupPosition(
            Rule.chess,
            Setup.parseFen(relation['to_fen'] as String),
          );
        }
      }

      addNodeToRegsitry(newChessNodeFen, newChessTreeNode);
    }

    return state[Chess.initial.fen]!;
  }

  void markLineToBeSavedRecursive(ChessTreeNode nodeToBeSaved) {
    if (nodeToBeSaved.savedToRepertoire == true) {
      return;
    }
    nodeToBeSaved.savedToRepertoire = true;
    String nextNodeFen = nodeToBeSaved.fromNodes[nodeToBeSaved.playedMove]!.fen;
    markLineToBeSavedRecursive(getNodeFromRegistry(nextNodeFen)!);
  }

  void saveNodesToDatabase() async {
    Database db = await createDatabase();

    for (var node in state.entries) {
      if (!node.value.savedToRepertoire) {
        continue;
      }
      // INSERT into repertoire_positions table
      db.insert(
          'repertoire_positions',
          {
            'fen': node.value.fen,
            'playedMove': node.value.playedMove,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);

      // INSERT fromNodes values into node_relationships table
      for (var fromNode in node.value.fromNodes.entries) {
        db.insert(
          'node_relationships',
          {
            'from_fen': fromNode.value.fen,
            'to_fen': node.value.fen,
            'move': fromNode.key,
          },
        );
      }

      // INSERT toNodes values into node_relationships table
      for (var toNode in node.value.toNodes.entries) {
        if (isSavedInRegistry(toNode.key)) {
          db.insert(
            'node_relationships',
            {
              'from_fen': node.value.fen,
              'to_fen': toNode.value.fen,
              'move': toNode.key,
            },
          );
        }
      }
    }
  }

  Map<String, ChessTreeNode> getNodeRegistry() {
    return state;
  }

  bool isSavedInRegistry(String fen) {
    final node = getNodeFromRegistry(fen);

    if (node == null) {
      return false;
    }
    if (node.savedToRepertoire) {
      return true;
    }
    return false;
  }

  ChessTreeNode? getNodeFromRegistry(String fen) {
    return state[fen];
  }
}

final chessTreeNodeProvider =
    StateNotifierProvider<ChessTreeNodeNotifier, Map<String, ChessTreeNode>>(
  (ref) => ChessTreeNodeNotifier(),
);

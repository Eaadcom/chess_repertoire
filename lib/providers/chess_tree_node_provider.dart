import 'package:chess_repertoire/models/chess_tree_node.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChessTreeNodeNotifier extends StateNotifier<Map<String, ChessTreeNode>> {
  ChessTreeNodeNotifier()
      : super({
          kInitialBoardFEN: ChessTreeNode(
              fen: kInitialBoardFEN, playedMove: '', fromNodes: {})
        });

  void addNodeToRegsitry(String fen, ChessTreeNode newChessTreeNode) {
    state = {
      ...state,
      fen: newChessTreeNode,
    };
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

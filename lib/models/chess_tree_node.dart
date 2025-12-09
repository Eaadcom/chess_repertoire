import 'package:dartchess/dartchess.dart';

class ChessTreeNode {
  ChessTreeNode({
    required this.fen,
    required this.playedMove,
    required this.fromNodes,
    required this.nodePosition,
    this.savedToRepertoire = false,
    required this.toNodes,
  });

  final String fen;
  final String playedMove;
  final Position nodePosition;
  bool savedToRepertoire;
  // Chess move String, Position object
  Map<String, Position> fromNodes;
  Map<String, Position> toNodes;
}

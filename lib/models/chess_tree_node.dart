import 'package:dartchess/dartchess.dart';

class ChessTreeNode {
  ChessTreeNode({required this.fen, required this.playedMove, required this.fromNodes, required this.nodePosition});

  final String fen;
  final String playedMove;
  final Position nodePosition;
  bool savedToRepertoire = false;
  Map<String, Position> fromNodes;
  Map<String, Position> toNodes = {};
}
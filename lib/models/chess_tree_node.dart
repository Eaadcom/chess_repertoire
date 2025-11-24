import 'package:dartchess/dartchess.dart';

class ChessTreeNode {
  ChessTreeNode({required this.fen, required this.playedMove, required this.fromNodes});

  final String fen;
  final String playedMove;
  Map<String, Position> fromNodes;
  Map<String, Position> toNodes = {};
}
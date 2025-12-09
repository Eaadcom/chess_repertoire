import 'package:chess_repertoire/models/chess_tree_node.dart';
import 'package:chess_repertoire/providers/chess_tree_node_provider.dart';
import 'package:chess_repertoire/widgets/move_tree.dart';
import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppChessboard extends ConsumerStatefulWidget {
  const AppChessboard({super.key});

  @override
  ConsumerState<AppChessboard> createState() => _AppChessboardState();
}

class _AppChessboardState extends ConsumerState<AppChessboard> {
  var fen = Chess.initial.fen;
  var oldFen = '';
  Position position = Chess.initial;
  late var validMoves;
  ChessTreeNode? currentChessTreeNode;

  @override
  void initState() {
    super.initState();
    _loadNodesFromDatabase();
  }

  void _loadNodesFromDatabase() async {
    ChessTreeNode newChessTreeNode =
        await ref.read(chessTreeNodeProvider.notifier).loadNodesFromDatabase();
    setState(() {
      currentChessTreeNode = newChessTreeNode;
    });
  }

  void _onMove(NormalMove move, {bool? isDrop}) {
    // Update board position
    if (position.isLegal(move)) {
      oldFen = fen;
      var oldPosition = position;
      setState(
        () {
          position = position.playUnchecked(move);
          fen = position.fen;
          validMoves = makeLegalMoves(position);
        },
      );

      ChessTreeNode? newChessTreeNode =
          ref.read(chessTreeNodeProvider.notifier).getNodeFromRegistry(fen);
      // If node does not exist yet
      if (newChessTreeNode == null) {
        // Save new position node in the registry & update update toNode in previous node
        newChessTreeNode = ChessTreeNode(
            fen: fen,
            playedMove: move.uci,
            fromNodes: {move.uci: oldPosition},
            toNodes: {},
            nodePosition: position);
        final chessTreeNotifier = ref.read(chessTreeNodeProvider.notifier);
        chessTreeNotifier.addNodeToRegsitry(fen, newChessTreeNode);
        Map<String, ChessTreeNode> nodeRegistry =
            chessTreeNotifier.getNodeRegistry();
        if (nodeRegistry[oldFen] != null) {
          nodeRegistry[oldFen]!.toNodes[move.uci] = position;
        }
      }

      setState(() {
        currentChessTreeNode = newChessTreeNode;
      });
    }
  }

  PlayerSide _getPlayerSide() {
    if (position.turn == Side.white) {
      return PlayerSide.white;
    }
    return PlayerSide.black;
  }

  void _swapCurrentNode(String newNodeFen) {
    ChessTreeNode newChessTreeNode = ref
        .read(chessTreeNodeProvider.notifier)
        .getNodeFromRegistry(newNodeFen)!;
    setState(() {
      fen = newChessTreeNode.fen;
      position = newChessTreeNode.nodePosition;
      currentChessTreeNode = newChessTreeNode;
    });
  }

  @override
  Widget build(BuildContext context) {
    validMoves = makeLegalMoves(position);
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Chessboard(
          size: screenWidth,
          orientation: Side.white,
          fen: fen,
          game: GameData(
            playerSide: _getPlayerSide(),
            sideToMove: position.turn,
            validMoves: validMoves,
            promotionMove: null,
            onMove: _onMove,
            onPromotionSelection: (Role? role) {},
          ),
        ),
        Movetree(
          currentChessTreeNode: currentChessTreeNode,
          swapCurrentNode: _swapCurrentNode,
        ),
      ],
    );
  }
}

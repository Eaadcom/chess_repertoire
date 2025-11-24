import 'package:chess_repertoire/models/chess_tree_node.dart';
import 'package:chess_repertoire/providers/chess_tree_node_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Movetree extends ConsumerWidget {
  const Movetree({super.key, required this.currentChessTreeNode});

  final ChessTreeNode currentChessTreeNode;

   ChessTreeNode? _getPreviousNode(WidgetRef ref, String fen){
    return ref.read(chessTreeNodeProvider.notifier).getNodeFromRegistry(fen);
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous move
        Column(
          children: [
            for (var entry in currentChessTreeNode.fromNodes.entries)
             Text(_getPreviousNode(ref, entry.value.fen)!.playedMove)
          ],
        ),
        SizedBox(width: 16),
        // Last move
        Column(
          children: [
            for (var entry in currentChessTreeNode.fromNodes.entries)
             Text(entry.key)
          ],
        ),
        SizedBox(width: 16),
        // Next move
        Column(
          children: [
            for (var entry in currentChessTreeNode.toNodes.entries)
             Text(entry.key)
          ],
        ),
      ],
    );
  }
}

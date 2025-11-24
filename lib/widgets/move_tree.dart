import 'package:chess_repertoire/models/chess_tree_node.dart';
import 'package:chess_repertoire/providers/chess_tree_node_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Movetree extends ConsumerWidget {
  const Movetree(
      {super.key,
      required this.currentChessTreeNode,
      required this.swapCurrentNode});

  final ChessTreeNode currentChessTreeNode;
  final Function swapCurrentNode;

  ChessTreeNode? _getPreviousNode(WidgetRef ref, String fen) {
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
              ActionChip(
                label: Text(_getPreviousNode(ref, entry.value.fen)!.playedMove),
                onPressed: swapCurrentNode(),
              )
          ],
        ),
        SizedBox(width: 16),
        // Last move
        Column(
          children: [
            for (var entry in currentChessTreeNode.fromNodes.entries)
              Chip(label: Text(entry.key))
          ],
        ),
        SizedBox(width: 16),
        // Next move
        Column(
          children: [
            for (var entry in currentChessTreeNode.toNodes.entries)
              Chip(
                label: Text(entry.key),
              )
          ],
        ),
      ],
    );
  }
}

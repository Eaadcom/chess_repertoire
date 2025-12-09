import 'package:chess_repertoire/models/chess_tree_node.dart';
import 'package:chess_repertoire/providers/chess_tree_node_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Movetree extends ConsumerWidget {
  const Movetree(
      {super.key,
      required this.currentChessTreeNode,
      required this.swapCurrentNode});

  final ChessTreeNode? currentChessTreeNode;
  final Function(String) swapCurrentNode;

  ChessTreeNode? _getPreviousNode(WidgetRef ref, String fen) {
    return ref.read(chessTreeNodeProvider.notifier).getNodeFromRegistry(fen);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget content = Center(child: CircularProgressIndicator());
    ref.watch(chessTreeNodeProvider);

    if (currentChessTreeNode != null) {
      content = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous move
              Column(
                children: [
                  if (currentChessTreeNode!.fromNodes.isNotEmpty)
                    for (var entry in currentChessTreeNode!.fromNodes.entries)
                      ActionChip(
                        label: Text(
                          _getPreviousNode(ref, entry.value.fen)!.playedMove,
                          style: TextStyle(
                            color: ref
                                    .read(chessTreeNodeProvider.notifier)
                                    .isSavedInRegistry(entry.value.fen)
                                ? Colors.green
                                : Colors.amber,
                          ),
                        ),
                        onPressed: () {
                          swapCurrentNode(entry.value.fen);
                        },
                      )
                ],
              ),
              SizedBox(width: 16),
              // Last move
              Column(
                children: [
                  for (var entry in currentChessTreeNode!.fromNodes.entries)
                  // TODO BUG HERE
                    ActionChip(
                      label: Text(
                        entry.key,
                        style: TextStyle(
                          color: currentChessTreeNode!.savedToRepertoire
                              ? Colors.green
                              : Colors.amber,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16),
              // Next move
              Column(
                children: [
                  for (var entry in currentChessTreeNode!.toNodes.entries)
                    ActionChip(
                      label: Text(
                        entry.key,
                        style: TextStyle(
                          color: ref
                                  .read(chessTreeNodeProvider.notifier)
                                  .isSavedInRegistry(entry.value.fen)
                              ? Colors.green
                              : Colors.amber,
                        ),
                      ),
                      onPressed: () {
                        swapCurrentNode(entry.value.fen);
                      },
                    )
                ],
              ),
            ],
          ),
          ElevatedButton(
              onPressed: currentChessTreeNode!.savedToRepertoire
                  ? null
                  : () {
                      ref
                          .read(chessTreeNodeProvider.notifier)
                          .markLineToBeSavedRecursive(currentChessTreeNode!);
                      ref
                          .read(chessTreeNodeProvider.notifier)
                          .saveNodesToDatabase();
                      swapCurrentNode(currentChessTreeNode!.fen);
                    },
              child: Text('Save this line')),
        ],
      );
    }
    return content;
  }
}

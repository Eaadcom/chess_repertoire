import 'package:chess_repertoire/widgets/app_chessboard.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chess Repertoire'),
      ),
      body: AppChessboard(),
    );
  }
}

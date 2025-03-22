import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnist_presentation_app/widgets/drawing_board.dart';
import 'package:mnist_presentation_app/widgets/predictions_display.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<int, double> predictions = {
    0: 0.1,
    1: 0.2,
    2: 0.0,
    3: 0.5,
    4: 0.0,
    5: 0.1,
    6: 0.02,
    7: 0.03,
    8: 0.04,
    9: 0.01,
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('WhiteMind Demo', style: TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
      ),),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/images/whitemind_icon.png',),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.upload),
          color: Theme.of(context).colorScheme.onSecondary,
          onPressed: () {},
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: PredictionsDisplay(predictions: predictions)
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 128, top: 64),
          child: DrawingBoard(
            size: MediaQuery.of(context).size.width - 16,
          ),
        )
      ],
    )
  );
  }
}

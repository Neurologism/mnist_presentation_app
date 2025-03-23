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
  ImageProvider? drawing;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  int bestPrediction() {
    int best = 0;
    double bestValue = 0;
    predictions.forEach((key, value) {
      if (value > bestValue) {
        best = key;
        bestValue = value;
      }
    });
    return best;
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
        SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (drawing != null) Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2)
                ),
                child: Image(image: drawing!, fit: BoxFit.contain, height: 100, width: 100, filterQuality: FilterQuality.none,),
              ),
              Icon(Icons.arrow_forward_ios, size: 50, color: Colors.black,),
              Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Text(bestPrediction().toString(),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: PredictionsDisplay(predictions: predictions)
        ),
        Container(
          height: 5,
          color: Colors.blue[900],
          width: MediaQuery.of(context).size.width,
        ),
        Expanded(
          flex: 3,
          child: MNISTDrawingBoard(
            size: MediaQuery.of(context).size.width,
            onChange: (newImage) {
              setState(() {
                drawing = newImage;
              });
            },
          ),
        ),
      ],
    )
  );
  }
}

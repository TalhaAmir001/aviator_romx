import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(home: MyHome()));
}

class MyHome extends StatefulWidget {
  @override
  State<MyHome> createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  double pointPeakX = 50 + Random().nextDouble() * (150 - 50);
  double pointPeakY = 100 + Random().nextDouble() * (260 - 100);
  static Offset _end = Offset(150, 100);
  bool _isAnimating = false;
  List<Offset> trailPointsBezier = [];
  List<Offset> trailPointsFalling = [];
  List<Offset> trailPointsBezierEnd = [];
  Offset currentOffsetVariable = Offset(150, 100);
  late AnimationController _animationController;
  static double totalAmount = 500;
  double bettingAmount = 0;
  double multiplier = 1.0;
  double newMultiplier = 1.0;
  static bool shouldStopped = false;



  @override
  void initState() {
    super.initState();
    setState(() {
      _end = Offset(pointPeakX, pointPeakY);
    });
  }

  void resetAnimations() {
    setState(() {

      // _animationController.reset();

      trailPointsBezier.clear();
      trailPointsFalling.clear();

      // pointPeakY = (pointPeakX*2);
      pointPeakY = 100 + Random().nextDouble() * (260 - 100);



      if(pointPeakY>220)
        {
          pointPeakX = 20 ;
        }
      else
        {
          pointPeakX = 50 + Random().nextDouble() * (150 - 50);
        }

      if(pointPeakX<100 || pointPeakY>200){
        setState(() {
          FallingPlaneAnimationState.dropTime = Random().nextInt(1500);
        });
      }

      print("?***?*?*?*?*?*?*?*?"+pointPeakY.toString()+"x:"+pointPeakX.toString());
      _end = Offset(pointPeakX, pointPeakY); // Reset the Bezier animation
      _isAnimating = false; // Reset the falling animation
    });
  }

  void startNewAnimation(Offset currentOffsetVariable) {
    // Create a new animation controller for the new TweenAnimation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    // Set up a new TweenAnimation with the beginning value as currentOffsetVariable
    // final animation = BezierTween(
    //   begin: currentOffsetVariable,
    //   control: Offset(0, currentOffsetVariable.dy),
    //   end: Offset(300, 40),
    // ).animate(_animationController);
    final animation = TweenAnimationBuilder(
        tween: BezierTween(
          begin: currentOffsetVariable,
          control: currentOffsetVariable,
          end: Offset(300,40)
        ),
        duration: Duration(microseconds: 1000),
        builder: (BuildContext context, Offset value, Widget? child) {

          return Positioned(
            left: value.dx,
            top: value.dy,
            child: Container(
              width: 50,
              child: Image.asset(
                  "images/airplane.png"),
            ),
          );
        });

    // Add a listener to update the trail points
    // animation.addListener(() {
    //   setState(() {
    //     trailPointsBezier.add(animation.value);
    //   });
    // });

    // Start the new animation
    _animationController.forward();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text('Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            children: [
              Container(height: 100,
              color: Colors.red,
              child: Center(child: Text(""+totalAmount.toString())),),
              Container(
                height: 300.0,

                child: Stack(
                  children: [

                    SizedBox(height: 100),
                    AnimatedContainer(
                      curve: Curves.decelerate,
                      duration: Duration(seconds: 2),
                      child: Container(
                        decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage("https://img.freepik.com/free-vector/cartoon-white-clouds-icon-set-isolated-blue_90220-262.jpg?w=740&t=st=1695737032~exp=1695737632~hmac=a877f7a41d1d58804c6241666c6b99801030419995b0e2c4c8cf2d084fdaf4b8"),
                          fit: BoxFit.cover, // You can choose how the image should fit the container
                        ),
                      ), height: 300,),
                    ),


                    Stack(
                      children: [
                        if (!_isAnimating)
                          TweenAnimationBuilder(
                            tween: BezierTween(
                              begin: Offset(0, 300),
                              control: Offset(0, 320),
                              end: _end,
                            ),
                            duration: Duration(milliseconds: 1500),

                            builder: (BuildContext context, Offset value, Widget? child) {

                              trailPointsBezier.add(value);
                              currentOffsetVariable = currentOffset(value);

                              return Positioned(
                                left: value.dx,
                                top: value.dy,
                                child: Container(
                                  width: 50,
                                  child: Image.asset(
                                      "images/airplane.png"),
                                ),
                              );
                            },
                            onEnd: () {
                              setState(() {
                                _isAnimating = true; // Start falling animation
                              });
                            },
                          ),
                        if (_isAnimating)
                          FallingPlaneAnimation(
                            onEnd: () {
                              resetAnimations();// Reset both animations
                            },
                            leftPosition: pointPeakX,
                            topPosition: pointPeakY,
                            trailPointsFalling: trailPointsFalling,
                          ),
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 49.0, top: 10.0),
                    //   child: TrailLine(points: trailPointsBezier),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 49.0, top: 10.0),
                    //   child: TrailLine(points: trailPointsFalling),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 60.0, top: 0.0),
                    //   child:
                    // ),

                    Center(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 8.0), // Adjust the bottom padding as needed
                        child: Text(
                          newMultiplier.toStringAsFixed(1)+"x",
                          style: TextStyle(
                            fontSize: 24, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0), // Adjust shadow offset as needed
                                blurRadius: 4.0, // Adjust shadow blur radius as needed
                                color: Colors.black.withOpacity(0.5), // Shadow color
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 100,
                color: Colors.amber,
                child: Center(child: Expanded(
                  child: Center(
                    child: IntrinsicWidth(
                      child: TextField(
                        keyboardType: TextInputType.number, // Allows only numeric input
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), // Allow digits and a decimal point
                        ],
                        decoration: InputDecoration(
                          hintText: '0.0',
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Set the border color to white
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Set the border color to white
                          ),
                        ),
                        maxLines: 1, // Ensure the width wraps content
                      ),
                    ),
                  ),
                )),

              ),
              ElevatedButton(onPressed: () {
                newMultiplier = 1.0;
                shouldStopped = false;
                Timer.periodic(Duration(milliseconds: 800), (timer) {
                  setState(() {
                    if(shouldStopped){}
                    else{
                      newMultiplier += 0.1;
                    }
                  });
                });

                resetAnimations();
                trailPointsBezier.clear();
                trailPointsFalling.clear();
              }, child: Text("Start")),
              ElevatedButton(onPressed: (){
                print("><><><><><><>><><><><: Flying is Finished: "+currentOffsetVariable.toString());

                // resetAnimations();
                // startNewAnimation(currentOffsetVariable);
              }, child: Text("Stop")),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
      ),
    );
  }

  Offset currentOffset(Offset value){
    return value;
  }

}

class BezierTween extends Tween<Offset> {
  final Offset begin;
  final Offset end;
  final Offset control;

  BezierTween({required this.begin, required this.end, required this.control})
      : super(begin: begin, end: end);

  @override
  Offset lerp(double t) {
    final t1 = 1 - t;
    return begin * t1 * t1 + control * 2 * t1 * t + end * t * t;
  }
}

class FallingPlaneAnimation extends StatefulWidget {
  final VoidCallback? onEnd;
  double leftPosition = 0;
  double topPosition = 0;
  List<Offset> trailPointsFalling;

  FallingPlaneAnimation({this.onEnd, required this.leftPosition, required this.topPosition, required this.trailPointsFalling});

  @override
  FallingPlaneAnimationState createState() =>
      FallingPlaneAnimationState(leftPostion2: leftPosition, topPostion2: topPosition, trailPointsFalling: trailPointsFalling);
}

class FallingPlaneAnimationState extends State<FallingPlaneAnimation> {
  double _fallingDistance = 0;
  double _rotation = 0;

  double leftPostion2;
  double topPostion2;
  List<Offset> trailPointsFalling;

  // if(topPosition2>140){
  //
  // }

  static int dropTime = Random().nextInt(6000);

  FallingPlaneAnimationState({required this.leftPostion2, required this.topPostion2, required this.trailPointsFalling});

  @override
  void initState() {
    super.initState();
    startFallingAnimation();

  }

  void startFallingAnimation() async {
    await Future.delayed(Duration(milliseconds: dropTime));

    double initialTop = topPostion2;
    
    trailPointsFalling.add(Offset(leftPostion2, initialTop));

    setState(() {
      _fallingDistance = 150;
      MyHomeState.shouldStopped = true;
    });

    for (int i = 0; i < 360; i += 5) {
      await Future.delayed(Duration(milliseconds: 50));
      setState(() {
        _rotation = i.toDouble();

        initialTop += 5;

        trailPointsFalling.add(Offset(leftPostion2, initialTop));
      });
    }

    // await Future.delayed(Duration(milliseconds: 1450));
    // widget.onEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 1500),
      left: leftPostion2,
      top: topPostion2 + _fallingDistance,
      child: Transform.rotate(
        angle: _rotation * (3.14159265359 / 180),
        child: Container(
          width: 50,
          child: Image.asset(
              "images/airplane.png"),
        ),
      ),
    );
  }
}
class TrailLine extends StatelessWidget {
  final List<Offset> points;

  TrailLine({required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrailLinePainter(points: points),
    );
  }
}

class TrailLinePainter extends CustomPainter {
  final List<Offset> points;

  TrailLinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green // Choose a color for your trail line
      ..strokeWidth = 2.0; // Adjust the line width as needed

    for (var i = 1; i < points.length; i++) {
      canvas.drawLine(points[i - 1], points[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}



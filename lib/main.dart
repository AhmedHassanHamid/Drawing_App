// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_this

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class DrawingArea{
  Offset point;
  Paint areaPaint;

  DrawingArea({this.point, this.areaPaint});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyHomePage> {

  List<DrawingArea> points = [];
  Color selectedColor;
  double strokeWidth;

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }


  void selectColor() {
      showDialog(
        builder: (context) => AlertDialog(
          title: const Text('Color Chooser'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                this.setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"))
          ],
        ), context: context,
      );
    }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(138, 35, 135, 1.0),
                    Color.fromRGBO(233, 64, 87, 1.0),
                    Color.fromRGBO(242, 113, 33, 1.0),
                  ]),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: width * 0.80,
                  height: height * 0.80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                      )
                    ],
                  ),
                  child: GestureDetector(
                    onPanDown: (details){
                      this.setState(() {
                        points.add(DrawingArea(
                          point: details.localPosition,
                          areaPaint: Paint()
                          ..strokeCap = StrokeCap.round
                          ..isAntiAlias = true
                          .. color = selectedColor
                          .. strokeWidth = strokeWidth
                        ));
                      });
                    },
                    onPanUpdate: (details){
                      this.setState(() {
                        points.add(DrawingArea(
                          point: details.localPosition,
                          areaPaint: Paint()
                          ..strokeCap = StrokeCap.round
                          ..isAntiAlias = true
                          .. color = selectedColor
                          .. strokeWidth = strokeWidth
                        ));
                      });
                    },
                    onPanEnd: (details){
                      this.setState(() {
                        points.add(null);
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      child: CustomPaint(
                        painter: MyCustomPainter(points: points),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: width * 0.80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            selectColor();
                          }, icon: Icon(Icons.color_lens, color: selectedColor)),
                      Expanded(child: Slider(
                        min: 1.0,
                        max: 7.0,
                        activeColor: selectedColor,
                        value: strokeWidth, onChanged: (value){
                          this.setState(() {
                            strokeWidth = value;
                          });
                        },),),   
                      IconButton(
                          onPressed: () {
                            this.setState(() {
                              points.clear();
                            });
                          }, icon: Icon(Icons.layers_clear)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {

  List<DrawingArea> points;

  MyCustomPainter({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    

    for(int x=0;x<points.length-1;x++) {
      if(points[x] != null && points[x+1] != null) {
        Paint paint = points[x].areaPaint;
        canvas.drawLine(points[x].point, points[x+1].point, paint);
      }else if(points[x] !=null && points[x+1] == null) {
        Paint paint = points[x].areaPaint;
        canvas.drawPoints(PointMode.points, [points[x].point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
}

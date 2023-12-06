import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingBarEx extends StatefulWidget {
  int count = 5;
  int scoreValue = 1;
  bool enable = true;
  Function(int value) score;

  RatingBarEx({super.key, required this.score, this.count = 5, this.scoreValue = 1,this.enable = true});

  @override
  State<RatingBarEx> createState() => _RatingBarExState();
}

class _RatingBarExState extends State<RatingBarEx> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.h,
      child: ListView.builder(
        shrinkWrap: false,
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: widget.count,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              if(!widget.enable){
                return;
              }
              setState(() {
                widget.scoreValue = index;
              });
              widget.score(widget.scoreValue);
            },
            child: (widget.scoreValue >= index)
                ? Icon(
                    Icons.star,
                    color: Colors.red,
                    size: 20,
                  )
                : Icon(
                    Icons.star_border_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
          );
        },
      ),
    );
  }
}

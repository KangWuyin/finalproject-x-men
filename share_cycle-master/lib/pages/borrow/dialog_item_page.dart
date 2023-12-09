import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/widget/title.dart';

class DialogItemPage extends StatefulWidget {

  List<dynamic> data=[];

  Function(dynamic) selectItemClick;
  Function(dynamic)? selectItemDataClick;

  DialogItemPage({super.key,required this.data,
    required this.selectItemClick,
    this.selectItemDataClick,});

  @override
  State<DialogItemPage> createState() => _DialogItemPageState();
}

class _DialogItemPageState extends State<DialogItemPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          width: double.maxFinite,
          child: Column(
            children: widget.data.map((e){
              return GestureDetector(
                onTap: () {
                  widget.selectItemClick(e["name"]);
                  if(widget.selectItemDataClick!=null){
                    widget.selectItemDataClick!(e);
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1))),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "${e["name"]}",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 20,
                      ),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}

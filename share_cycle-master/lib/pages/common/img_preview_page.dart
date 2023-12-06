import 'package:flutter/material.dart';

class ImgPreviewPage extends StatefulWidget {
  List<String> urlImageData = [];
  int position = 0;

  ImgPreviewPage({super.key, required this.urlImageData, this.position = 0});

  @override
  State<ImgPreviewPage> createState() => _ImgPreviewPageState();
}

class _ImgPreviewPageState extends State<ImgPreviewPage> with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _pageController.animateToPage(widget.position, duration: Duration(seconds: 1), curve: Curves.easeIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.urlImageData.length,
      itemBuilder: (BuildContext context, int index) {
        String imgUrl = widget.urlImageData[index];
        return GestureDetector(onTap: (){
          Navigator.pop(context);
        },child: Container(
          color: Colors.red,
          width: double.maxFinite,
          height: double.maxFinite,
          child: Image.network(
            imgUrl,
            fit: BoxFit.fill,
          ),
        ),);
      },
    );
  }
}

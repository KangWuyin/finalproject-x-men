

import 'package:flutter/material.dart';
import 'package:share_cycle/widget/title.dart';

import '../../generated/l10n.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(title: "About us",leading: true),
      body: Container(
        padding: EdgeInsets.only(left: 10,right: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: Image.asset("assets/images/about_us.jpg",fit: BoxFit.fill,width: 100,height: 100,),
              ),
              SizedBox(height: 10,),
              Divider(height: 1,color: Colors.black,),
              SizedBox(height: 10,),
              Semantics(
                label: S.of(context).about_title,
                child: Text("${S.of(context).about_title}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 10,),
              Semantics(
                label: S.of(context).about_content,
                child: Text("${S.of(context).about_content}",style: TextStyle(fontSize: 16),),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

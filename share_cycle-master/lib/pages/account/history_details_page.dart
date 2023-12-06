import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/bean/history_bean.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/utils/image_utils.dart';
import 'package:share_cycle/widget/rating_bar_ex.dart';
import 'package:share_cycle/widget/title.dart';

import '../../generated/l10n.dart';

class HistoryDetailsPage extends StatefulWidget {
  int type = 1; // 借出   // 借入
  String title = "";
  HistoryBean historyBean;

  HistoryDetailsPage({super.key, required this.title, required this.type, required this.historyBean});

  @override
  State<HistoryDetailsPage> createState() => _HistoryDetailsPageState();
}

class _HistoryDetailsPageState extends State<HistoryDetailsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  UserBean? userBean;
  List<dynamic> images = [];
  List<dynamic> commentData = [];

  int scoreValue = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getGoodsScore();
      setState(() {
        images.addAll((json.decode(widget.historyBean.goodsImg.toString()) as List<dynamic>).map((e) => e).toList()); // 归还的图片
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(
        title: widget.title,
        leading: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              SizedBox(
                height: 150.h,
                child: (images.isNotEmpty)
                    ? PageView.builder(
                        itemCount: images.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: EdgeInsets.all(1),
                            child: Image.network(
                              ImageUtils.firebaseImageUrl(fileName: images[index]),
                              fit: BoxFit.fill,
                              width: double.maxFinite,
                            ),
                          );
                        },
                      )
                    : Container(),
              ),
              SizedBox(
                height: 10,
              ),
              (widget.type == 1) ? borrowWidget() : lendWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget itemLabel({required String labelLeft, required String labelRight}) {
    return Container(
      margin: EdgeInsets.only(top: 5.h),
      child: Row(
        children: [
          Text(
            labelLeft,
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
          SizedBox(
            width: 20.w,
          ),
          Text(
            labelRight,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget borrowWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          itemLabel(labelLeft: "${S.of(context).date} ", labelRight: widget.historyBean.historyDate.toString()),
          itemLabel(labelLeft: "${S.of(context).lender}", labelRight: "${widget.historyBean.toLenderName}"),
          itemLabel(labelLeft: "${S.of(context).location}", labelRight: widget.historyBean.address.toString()),
          itemLabel(labelLeft: "${S.of(context).item_status}",
              labelRight: (widget.historyBean.state.toString()=="return"?
              "${S.of(context).returned}":
              "${S.of(context).return_ex}")),
          Container(
            margin: EdgeInsets.only(top: 5.h),
            child: Row(
              children: [
                Text(
                  "${S.of(context).getting_score}",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                SizedBox(
                  width: 20.w,
                ),
                Expanded(
                    child: RatingBarEx(
                  score: (value) {},
                  scoreValue: widget.historyBean.goodsScore ?? 0,
                )),
              ],
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            "${S.of(context).comment}",
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
          SizedBox(
            height: 5.h,
          ),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
            width: double.maxFinite,
            height: 150,
            child: Text(
              "${widget.historyBean.toApplyComment.toString()}",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget lendWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          itemLabel(labelLeft: "${S.of(context).date}", labelRight: "${widget.historyBean.historyDate}"),
          itemLabel(labelLeft: "${S.of(context).borrower}", labelRight: widget.historyBean.applyName.toString()), // 目前谁借的
          itemLabel(labelLeft: "${S.of(context).location}", labelRight: "${widget.historyBean.address}"),
          itemLabel(labelLeft: "${S.of(context).item_status}",
              labelRight: (widget.historyBean.state.toString()=="return"?
              "${S.of(context).returned}":
              "${S.of(context).return_ex}")),
          Container(
            margin: EdgeInsets.only(top: 5.h),
            child: Row(
              children: [
                Text(
                  "${S.of(context).getting_score}",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                SizedBox(
                  width: 20.w,
                ),
                Expanded(
                    child: RatingBarEx(
                  score: (value) {},
                  enable: false,
                  scoreValue: scoreValue,
                )),
              ],
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            '${S.of(context).comment}',
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
          SizedBox(
            height: 5.h,
          ),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
            width: double.maxFinite,
            height: 150,
            child: Text(
              "${widget.historyBean.toLendComment.toString()}",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  getGoodsScore() async {
    var future = await db
        .collection("goods_score")
        .where("lend_id", isEqualTo: widget.historyBean.lendId) //
        .get();
    var docs = future.docs;
    dynamic allScore = 0;
    for (var value in docs) {
      allScore += value.get("goods_score");
    }

    if(allScore==0){
      setState(() {
        scoreValue=0;
      });
      return;
    }

    setState(() {
      scoreValue = allScore ~/ docs.length;
    });
  }

  // 获取该产品的所有评论

  getGoodsComment() async {
    commentData.clear();
    var future = await db.collection("return").where("lend_id", isEqualTo: widget.historyBean.lendId).get(GetOptions());
    var docs = future.docs;
    for (var value in docs) {
      commentData.add({
        "lender_comment": value.get("lender_comment"), // 出借人
        "borrowed_comment": value.get("borrowed_comment"), // 借入人
      });
    }
    setState(() {});
  }
}

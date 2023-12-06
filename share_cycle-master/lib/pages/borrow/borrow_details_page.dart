import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/pages/borrow/apply_page.dart';
import 'package:share_cycle/pages/lends/lend_goods_page.dart';
import 'package:share_cycle/utils/image_utils.dart';
import 'package:share_cycle/utils/snack_utils.dart';
import 'package:share_cycle/utils/sp_utils.dart';
import 'package:share_cycle/widget/rating_bar_ex.dart';
import 'package:share_cycle/widget/title.dart';

class BorrowDetailsPage extends StatefulWidget {
  dynamic data;

  BorrowDetailsPage({super.key, this.data});

  @override
  State<BorrowDetailsPage> createState() => _BorrowDetailsPageState();
}

class _BorrowDetailsPageState extends State<BorrowDetailsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<dynamic> returnData = [];
  List<dynamic> images = [];
  UserBean? userBean;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userBean = UserBean.fromJson(json.decode(await getData("local_user")));
      getReturnData();
      setState(() {
        images = (json.decode(widget.data["goods_img"]) as List<dynamic>).map((e) => e).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(title: "${S.of(context).goods_details}", leading: true),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 轮播
              SizedBox(
                height: 200,
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
                height: 10.h,
              ),
              Divider(
                color: Colors.black,
                height: 1,
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: Text(
                  "${S.of(context).item_name}：${widget.data["goods_name"]}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Divider(
                color: Colors.black,
                height: 1,
              ),
              SizedBox(
                height: 8.h,
              ),
              label(title: '${S.of(context).information}', content: '${widget.data["information"]}'),
              label(title: '${S.of(context).available_date}', content: '${widget.data["start_date"]} - ${widget.data["end_date"]}'),
              label(title: '${S.of(context).phone_number}', content: '${widget.data["phone"]}'),
              label(title: '${S.of(context).email}', content: '${widget.data["email"]}'),
              SizedBox(
                height: 8.h,
              ),
              Divider(
                color: Colors.black,
                height: 1,
              ),
              SizedBox(
                height: 8.h,
              ),
              if (widget.data['user_id'] == userBean?.id.toString())
                Container(
                  margin: EdgeInsets.only(left: 40, right: 40),
                  width: double.maxFinite,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                          return LendGoodsPage(
                            goodsType: widget.data['goods_type'],
                            type: widget.data['goods_type'],
                            oldData: widget.data,
                          );
                        }));
                      },
                      child: Text("${S.of(context).update}",
                        style: TextStyle(fontSize: 20),)),
                ),


              if(widget.data['state'] == 1)
                Text("${S.of(context).the_item_has_been_lent_out}"),

              (widget.data['user_id'] == userBean?.id.toString())
                  ? Container(
                      child: Column(
                      children: [
                        Text(
                          "${S.of(context).personal_effects}",
                          style: TextStyle(fontSize: 16),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              // 进行删除操作
                              await db.collection("lend").doc(widget.data['id']).delete();
                              SnackUtils.showSnack(context, "${S.of(context).removed_successfully}");
                              Navigator.pop(context);
                            },
                            child: Text(
                              "${S.of(context).off_shelf}", // 下架
                              style: TextStyle(fontSize: 20),
                            )), //当前为自己的物品，无法申请
                      ],
                    ))
                  : Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      width: double.maxFinite,
                      child: ElevatedButton(
                          onPressed: () {
                            if(widget.data['state'] == 1){
                              SnackUtils.showSnack(context, "${S.of(context).the_item_has_been_lent_out}");
                              return;
                            }
                            // 判断是否为自己的产品
                            if (widget.data['user_id'] == userBean?.id.toString()) {
                              SnackUtils.showSnack(context, "Currently, it is one's own item and cannot be applied for");
                              return;
                            }
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ApplyPage(data: widget.data)));
                          },
                          child: Text("${S.of(context).apply}")),
                    ),

              SizedBox(
                height: 20.h,
              ),

              SizedBox(
                width: double.maxFinite,
                child: Text(
                  "${S.of(context).comment}",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ListView.builder(
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: returnData.length,
                itemBuilder: (BuildContext context, int index) {
                  dynamic e = returnData[index];
                  return Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        children: [
                          RatingBarEx(
                            scoreValue: e["score"],
                            score: (int value) {},
                            enable: false,
                          ),
                          Row(
                            children: [
                              Text(
                                "${e['user_name']}  ", //borrowed comment
                                style: TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  e["borrowed_comment"],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "${S.of(context).lend_comment}  ",
                                style: TextStyle(fontSize: 16, color: Colors.blue),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  e["lender_comment"],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ));
                },
              ),
              SizedBox(
                height: 20.h,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget label({required String title, required String content}) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 2.h,
          ),
          Text(
            "$content",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  getReturnData() async {
    returnData.clear();
    var future = await db.collection("return").where("lend_id", isEqualTo: widget.data['id']).get(GetOptions());
    var docs = future.docs;
    for (var value in docs) {
      returnData.add({
        "id": value.id,
        "address": value.get("address"),
        "lender_comment": value.get("lender_comment"), // 出借人
        "borrowed_comment": value.get("borrowed_comment"), // 借入人
        "lend_id": value.get("lend_id"),
        "return_date": value.get("return_date"),
        "return_img": value.get("return_img"),
        "score": value.get("score"),
        "user_id": value.get("user_id"),
        "user_name": value.get("user_name"),
      });
    }
    setState(() {});
  }
}

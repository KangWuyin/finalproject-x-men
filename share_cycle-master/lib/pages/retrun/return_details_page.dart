import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/pages/dialog/date_dialog.dart';
import 'package:share_cycle/utils/date_tool.dart';
import 'package:share_cycle/utils/image_utils.dart';
import 'package:share_cycle/utils/snack_utils.dart';
import 'package:share_cycle/utils/sp_utils.dart';
import 'package:share_cycle/widget/rating_bar_ex.dart';
import 'package:share_cycle/widget/title.dart';

class ReturnDetailsPage extends StatefulWidget {
  dynamic applyData;

  ReturnDetailsPage({super.key, this.applyData});

  @override
  State<ReturnDetailsPage> createState() => _ReturnDetailsPageState();
}

class _ReturnDetailsPageState extends State<ReturnDetailsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  UserBean? userBean;
  String returnDate = "";
  int? selectAddress = 1;
  int score = 1;
  String address = "225 Terry Avenue";
  String comment = "";
  String returnImg = "";
  List<File> returnGoodsImg = [];
  String goodsImage = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userBean = UserBean.fromJson(json.decode(await getData("local_user")));
      address = widget.applyData['address'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(title: "${S.of(context).return_ex}", leading: true),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 轮播
              SizedBox(
                height: 200,
                child: (returnGoodsImg.isNotEmpty)
                    ? PageView.builder(
                        itemCount: returnGoodsImg.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: EdgeInsets.all(1),
                            child: Image.file(
                              returnGoodsImg[index],
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
              Container(
                width: double.maxFinite,
                child: ElevatedButton(
                    onPressed: () async {
                      // 选择图片上传
                      List<File> showOpenPhoto = await ImageUtils.showOpenPhoto(
                        context,
                      );
                      if (showOpenPhoto.isNotEmpty) {
                        setState(() {
                          returnGoodsImg = showOpenPhoto;
                        });
                        ImageUtils.firebaseUploadFile(
                            selectFile: returnGoodsImg,
                            goodsImage: (goodsImageUrl) {
                              goodsImage = goodsImageUrl;
                              print("上传的图片 ${goodsImage}");
                            });
                      }
                    },
                    child: Text(
                      // "Upload Image",
                      "${S.of(context).upload_image}",
                      style: TextStyle(fontSize: 20),
                    )),
              ),
              Text(
                "${S.of(context).return_data}",
                style: TextStyle(fontSize: 20),
              ),
              GestureDetector(
                onTap: () {
                  showDateSelect(context,
                      startDate: widget.applyData['start_date'],
                      endDate: widget.applyData['end_date'],
                      selectDate: (value) {
                    print("日期${value}");
                    setState(() {
                      returnDate = value;
                    });
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    (returnDate == "") ? "${S.of(context).select_data}" : returnDate,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                "${S.of(context).return_location}",
                style: TextStyle(fontSize: 20),
              ),

              Text(address,
                style: TextStyle(fontSize: 20),),

              // RadioMenuButton(
              //     style: ButtonStyle(
              //       // 去除外边距
              //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //       padding: MaterialStateProperty.all(const EdgeInsets.only(left: 0, right: 30, top: 4, bottom: 4)),
              //     ),
              //     value: 1,
              //     groupValue: selectAddress,
              //     onChanged: (value) {
              //       address = "225 Terry Avenue";
              //       setState(() {
              //         selectAddress = value;
              //       });
              //     },
              //     child: Text("225 Terry Avenue")),
              // RadioMenuButton(
              //     style: ButtonStyle(
              //       // 去除外边距
              //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //       padding: MaterialStateProperty.all(const EdgeInsets.only(left: 0, right: 30, top: 4, bottom: 4)),
              //     ),
              //     value: 2,
              //     groupValue: selectAddress,
              //     onChanged: (value) {
              //       address = "401 Terry Ave N";
              //       setState(() {
              //         selectAddress = value;
              //       });
              //     },reserved
              //     child: Text("401 Terry Ave N")),
              Text(
                "${S.of(context).score}:",
                style: TextStyle(fontSize: 20),
              ),
              RatingBarEx(
                scoreValue: score,
                score: (scoreValue) {
                  score = scoreValue;
                },
                enable: (widget.applyData['state'] == 3),
              ),
              Text(
                "${S.of(context).comment}:",
                style: TextStyle(fontSize: 20),
              ),
              TextField(
                maxLines: 5,
                onChanged: (value) {
                  comment = value;
                },
                decoration: InputDecoration(
                    labelText: "", labelStyle: TextStyle(color: Colors.black, fontSize: 20), border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1))),
              ),
              SizedBox(
                height: 20.h,
              ),
              if (widget.applyData['state'] == 3)
                Container(
                  width: double.maxFinite,
                  child: loading?Container(alignment: Alignment.center,
                  child: SizedBox(width: 20,height: 20,child: CircularProgressIndicator(),),):ElevatedButton(
                      onPressed: () {
                        returnGoods();
                      },
                      child: Text("${S.of(context).return_ex}")),
                ),
              if (widget.applyData['state'] == 4)
                Container(
                  width: double.maxFinite,
                  child: Text(
                    "${S.of(context).the_current_item_has_been_returned}", // 当前物品已经归还
                    style: TextStyle(fontSize: 20),
                  ),
                  alignment: Alignment.center,
                )
            ],
          ),
        ),
      ),
    );
  }

  returnGoods() async {
    if (goodsImage == "") {
      SnackUtils.showSnack(context, "${S.of(context).please_select_at_least_one_image}");
      return;
    }
    if (returnDate == "") {
      SnackUtils.showSnack(context, "${S.of(context).please_select_a_time}");
      return;
    }
    if (comment == "") {
      SnackUtils.showSnack(context, "${S.of(context).please_fill_in_the_comment}");
      return;
    }

    setState(() {
      loading = true;
    });
    var data = widget.applyData;
    // 判断是否已经归还
    DocumentSnapshot applyResult = await db.collection("apply").doc(data["id"]).get();
    dynamic applyTemp = applyResult.data();
    if (applyTemp['state'] == 4) {
      SnackUtils.showSnack(context, "${S.of(context).the_item_has_been_returned}"); //该物品已经归还
      setState(() {
        loading = false;
      });
      return;
    }
    // 申请表修改状态
    await db.collection("apply").doc(data["id"]).update({
      "state": 4 // 修改为已经归还
    });

    // 返回的数据
    var createReturn = await db.collection("return").add({
      "return_img": returnImg,
      "address": address,
      "return_date": returnDate,
      "score": score,
      "user_name": userBean?.username,
      "user_id": userBean?.id,
      "lend_id": data["lend_id"],
      "return_goods_img": goodsImage,
      "lender_comment": "", // 出借人
      "borrowed_comment": comment, // 借入人
    });

    // 发送通知
    dynamic map = {
      "apply_id": data["id"], // 申请表的id
      "lend_id": data["lend_id"], // 物品id
      "return_user_id": userBean?.id, // 归还的用户
      "return_goods_img": goodsImage,
      "return_id": createReturn.id, // 归还的信息id
      "body": "${userBean?.username} ${data['goods_name']}" // 归还物品
    };
    // 发送消息
    await db.collection("message").add({
      "content": json.encode(map),
      "type": 3, // 归还通知
      "datetime": DateTool.getToDay(),
      "state": 0,
      "auditing_state": -1,
      "user_id": data["lend_user_id"] // 这个是物品主人的id
    });
    // 打分
    await db.collection("goods_score").add({
      "lend_id": data["lend_id"], // 物品
      "lend_user_id": data["lend_user_id"], // 谁的物品
      "goods_score": score, //分数
      "score_user_id": userBean?.id, // 打分人
    });
    // 给出借人打分
    await db.collection("user_score").add({
      "user_id": data["lend_user_id"], // 给谁的分数
      "scoring_user": userBean?.id, // 打分人
      "score": score, //分数
    });

    // 修改对应的数据
    QuerySnapshot searchHistory = await db
        .collection("history")
        .where("apply_id", isEqualTo: data["id"]) // 根据申请id 查询
        .where("apply_user_id", isEqualTo: userBean?.id) // 提交申请的人id
        .get();
    // 修改分数，评论
      await db.collection("history").doc(searchHistory.docs[0].id).update({
        "goods_score": score, // 评分
        "comment": comment, // 评论
        "to_lend_comment": comment, // 借入的人对借出的人讲话话
        "state": "return", // 状态
        "return_date": DateTool.getToDay(), // 状态
      });
    setState(() {
      loading = false;
    });
    SnackUtils.showSnack(context, "${S.of(context).returned}"); // 已归还
    Navigator.pop(context);
  }
}

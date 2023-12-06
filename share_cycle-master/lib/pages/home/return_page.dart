import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/pages/retrun/return_details_page.dart';
import 'package:share_cycle/utils/image_utils.dart';
import 'package:share_cycle/utils/snack_utils.dart';
import 'package:share_cycle/utils/sp_utils.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  UserBean? userBean;

  List<dynamic> dataApply = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userBean = UserBean.fromJson(json.decode(await getData("local_user")));

      getGoodsApply();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            " ${S.of(context).you_have_borrowed}:",
            style: TextStyle(fontSize: 16),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: dataApply.length,
            itemBuilder: (BuildContext context, int index) {
              dynamic dataTemp = dataApply[index];
              int state = dataTemp['state'];
              List<dynamic> images =
                  (json.decode(dataTemp["goods_img"]) as List<dynamic>)
                      .map((e) => e)
                      .toList();
              return GestureDetector(
                  onTap: () async {
                    // 不确定
                    if (dataTemp['state'] == 4) {
                      SnackUtils.showSnack(
                          context, "${S.of(context).this_goods_old_returned}");
                      // return;
                    }

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ReturnDetailsPage(applyData: dataTemp)),
                    );
                    getGoodsApply();
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 2))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          "${ImageUtils.firebaseImageUrl(fileName: images[0])}",
                          fit: BoxFit.fill,
                          width: 60,
                          height: 60,
                        ),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.only(top: 5, left: 5),
                          alignment: Alignment.topLeft,
                          child: Text(
                            dataTemp["goods_name"].toString(),
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 7, right: 7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color:
                                      (state == 4) ? Colors.grey : Colors.red),
                              child: Text(
                                (state == 4)
                                    ? "${S.of(context).old_returned}"
                                    : "${S.of(context).old_un_returned}",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: (state == 4)
                                        ? Colors.white
                                        : Colors.white),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                "${dataTemp['borrowing_date']}",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
            },
          )),
        ],
      ),
    );
  }

  getGoodsApply() async {
    dataApply.clear();
    var applyResult = await db
        .collection("apply")
        .orderBy("borrowing_date", descending: true)
        .where("applicant_user_id", isEqualTo: userBean?.id)
        // .where("state",isEqualTo: 3)
        .where("state", whereIn: [3, 4]) // 2 被拒  3 已借入  4 已返还
        .get();
    for (var value in applyResult.docs) {
      dataApply.add({
        "id": value.id,
        "goods_name": value["goods_name"],
        "goods_img": value["goods_img"],
        "applicant_name": value["applicant_name"],
        "email": value["email"],
        "contact_phone": value["contact_phone"],
        "address": value["address"],
        "end_date": value["end_date"],
        "start_date": value["start_date"],
        "lend_id": value["lend_id"], // 出id
        "applicant_user_id": value["applicant_user_id"], // 申请人id
        "lend_user_id": value["lend_user_id"], // 出借人id
        "state": value["state"], // 0刚提交 1 审核通过  2 审核拒绝
        "borrowing_date": value["borrowing_date"] ?? "" // 借入时间
      });
    }
    setState(() {});
  }
}

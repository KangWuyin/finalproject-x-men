import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/bean/history_bean.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/pages/account/history_details_page.dart';
import 'package:share_cycle/pages/dialog/img_preview_dialog.dart';
import 'package:share_cycle/utils/image_utils.dart';
import 'package:share_cycle/utils/sp_utils.dart';
import 'package:share_cycle/widget/title.dart';

import '../../generated/l10n.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  UserBean? userBean;

  List<HistoryBean> historyBorrowedData = [];
  List<HistoryBean> historyLendData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userBean = UserBean.fromJson(json.decode(await getData("local_user")));
      getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(title: "${S.of(context).History}", leading: true),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            //
            Text(
              "${S.of(context).history_of_borrowed_items}",
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            Container(
              height: 150.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: historyBorrowedData.length,
                itemBuilder: (BuildContext context, int index) {
                  HistoryBean historyBean = historyBorrowedData[index];
                  List<dynamic> images = [];
                  if (historyBean.goodsImg != "") {
                    images.addAll((json.decode(historyBean.goodsImg.toString()) as List<dynamic>).map((e) => e).toList());
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return HistoryDetailsPage(title: '${S.of(context).history_of_borrowed_items}', type: 1, historyBean: historyBean);
                      }));
                    },
                    child: Container(
                      margin: EdgeInsets.all(5),
                      height: 150.h,
                      width: 150.h,
                      child: Image.network(
                        ImageUtils.firebaseImageUrl(fileName: images[0]),
                        fit: BoxFit.fill,
                      ),
                    ),
                  );
                },
              ),
            ),
            Text("${S.of(context).history_of_Lend_Items}", style: TextStyle(fontSize: 24, color: Colors.black)),
            Container(
              height: 150.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: historyLendData.length,
                itemBuilder: (BuildContext context, int index) {
                  HistoryBean historyBean = historyLendData[index];
                  List<dynamic> images = [];
                  if (historyBean.goodsImg != "") {
                    images.addAll((json.decode(historyBean.goodsImg.toString()) as List<dynamic>).map((e) => e).toList());
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return HistoryDetailsPage(title: '${S.of(context).history_of_Lend_Items}', type: 2, historyBean: historyBean);
                      }));
                    },
                    child: Container(
                      margin: EdgeInsets.all(5),
                      height: 150.h,
                      width: 150.h,
                      child: (images.isNotEmpty)
                          ? Image.network(
                              ImageUtils.firebaseImageUrl(fileName: images[0]),
                              fit: BoxFit.fill,
                            )
                          : Container(
                              color: Colors.red,
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get historical information
  getHistory() async {
    historyBorrowedData.clear();
    historyLendData.clear();
    var future = await db
        .collection("history")
    .orderBy("history_date",descending: true)
        // .where("user_id", isEqualTo: userBean?.id) //
        // .where("apply_id", isEqualTo: userBean?.id) //
        .get();
    var docs = future.docs;
    for (var value in docs) {
      // Determine if it is equal to the current user
      if (value['lend_user_id'] == userBean?.id!) {
        // lender
        historyLendData.add(HistoryBean(
            id: value.id,
            lendUserId: value['lend_user_id'],
            applyUserId: value['apply_user_id'],
            address: value['address'],
            // Evaluation given to borrowers
            toApplyComment: value['to_apply_comment'],
            // Reviews for lenders
            toLendComment: value['to_lend_comment'],
            goodsImg: value['goods_img'],
            goodsScore: value['goods_score'],
            historyDate: value['history_date'],
            lendId: value['lend_id'],
            toLenderName: value['lender_name'],
            applyName: value['apply_name'],
            state: value['state'],));
      }

      // borrow
      if (value['apply_user_id'] == userBean?.id!) {
        historyBorrowedData.add(HistoryBean(
            id: value.id,
            lendUserId: value['lend_user_id'],
            applyUserId: value['apply_user_id'],
            address: value['address'],
            toApplyComment: value['to_apply_comment'],
            toLendComment: value['to_lend_comment'],
            goodsImg: value['goods_img'],
            goodsScore: value['goods_score'],
            historyDate: value['history_date'],
            lendId: value['lend_id'],
            toLenderName: value['lender_name'],
            applyName: value['apply_name'],
            state: value['state'],
        )
        );
      }
    }
    print("借出的数据 ${historyLendData}");
    print("借来的数据 ${historyBorrowedData}");

    setState(() {});
  }
}

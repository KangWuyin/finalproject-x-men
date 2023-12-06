import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/pages/dialog/date_dialog.dart';
import 'package:share_cycle/utils/date_tool.dart';
import 'package:share_cycle/utils/email_utils.dart';
import 'package:share_cycle/utils/image_utils.dart';
import 'package:share_cycle/utils/snack_utils.dart';
import 'package:share_cycle/utils/sp_utils.dart';
import 'package:share_cycle/widget/title.dart';

import '../../generated/l10n.dart';

// 申请使用页面
class ApplyPage extends StatefulWidget {
  dynamic data;

  ApplyPage({super.key, this.data});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  UserBean? userBean;

  String applicantName = "";
  String email = "";
  String contactPhone = "";

  String startDate = "";
  String endDate = "";
  int? selectAddress = 1; // 申请
  String? address = "225 Terry Avenue"; // 申请
  List<dynamic> images = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userBean = UserBean.fromJson(json.decode(await getData("local_user")));
      setState(() {
        address = widget.data['address'];
        images = (json.decode(widget.data["goods_img"]) as List<dynamic>).map((e) => e).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(title: "${S.of(context).apply_goods}", leading: true),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              // 申请人的姓名
              TextField(
                decoration: InputDecoration(
                  labelText: "${S.of(context).applicant_name}", //applicant Name
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
                onChanged: (value) {
                  applicantName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "${S.of(context).email}",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "${S.of(context).contact_phone}",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
                onChanged: (value) {
                  contactPhone = value;
                },
              ),

              Text(
                "${S.of(context).meeting_address}",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "${address}",
                style: TextStyle(fontSize: 20),
              ),
              // RadioMenuButton(
              //     style: ButtonStyle(
              //       // 去除外边距
              //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //       padding: MaterialStateProperty.all(const EdgeInsets.only(
              //           left: 0, right: 30, top: 4, bottom: 4)),
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
              //       padding: MaterialStateProperty.all(const EdgeInsets.only(
              //           left: 0, right: 30, top: 4, bottom: 4)),
              //     ),
              //     value: 2,
              //     groupValue: selectAddress,
              //     onChanged: (value) {
              //       address = "401 Terry Ave N";
              //       setState(() {
              //         selectAddress = value;
              //       });
              //     },
              //     child: Text("401 Terry Ave N")),

              SizedBox(
                height: 10.h,
              ),
              Text(
                "${S.of(context).i_want_to_borrow_form}",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      showDateSelect(context, startDate: widget.data['start_date'], endDate: widget.data['end_date'], selectDate: (value) {
                        setState(() {
                          startDate = value;
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
                        (startDate == "") ? "${S.of(context).select_data}" : startDate,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "to",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      if(startDate==""){
                        SnackUtils.showSnack(context, "${S.of(context).please_select_start_time}");
                        return;
                      }
                      // 结束日期
                      showDateSelect(context, startDate: startDate, endDate: widget.data['end_date'], selectDate: (value) {
                        setState(() {
                          endDate = value;
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
                        (endDate == "") ? "${S.of(context).select_data}" : endDate,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.maxFinite,
                child: (loading)
                    ? Container(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (applicantName == "") {
                            SnackUtils.showSnack(context, "${S.of(context).please_enter_contact_person}"); //"请输入联系人");
                            return;
                          }
                          if (email == "") {
                            SnackUtils.showSnack(context, "${S.of(context).please_enter_your_email_address}");
                            return;
                          }
                          if (!EmailUtils.checkEmail(context, email)) {
                            return;
                          }
                          if (contactPhone == "") {
                            SnackUtils.showSnack(context, "${S.of(context).please_enter_the_contact_phone_number}");
                            return;
                          }
                          if (startDate == "") {
                            SnackUtils.showSnack(context, "${S.of(context).please_select_start_time}");
                            return;
                          }
                          if (endDate == "") {
                            SnackUtils.showSnack(context, "${S.of(context).please_select_end_time}");
                            return;
                          }
                          setState(() {
                            loading = true;
                          });

                          // 判断当前是否已经提交过
                          var querySnapshot = await db
                              .collection("apply")
                              .where("lend_id", isEqualTo: widget.data['id'])
                              .where("state", isEqualTo: 0) //
                              .get();
                          if (querySnapshot.size > 0) {
                            SnackUtils.showSnack(
                                context, "${S.of(context).the_item_has_already_submitted_an_application}"); //该物品已经提交申请  The item has already submitted an application
                            setState(() {
                              loading = false;
                            });
                            return;
                          }
                          var createApply = await db.collection("apply").add({
                            "goods_img": widget.data["goods_img"],
                            "lend_user_name": widget.data['name'],
                            "applicant_name": applicantName,
                            "email": email,
                            "contact_phone": contactPhone,
                            "address": address,
                            "goods_name": widget.data["goods_name"],
                            "end_date": endDate,
                            "start_date": startDate,
                            "create_date": DateTool.getToDay(),
                            "last_date": DateTool.getToDay(),
                            "lend_id": widget.data['id'], // 出id
                            "applicant_user_id": userBean?.id, // 申请人id
                            "lend_user_id": widget.data['user_id'], // 出借人id
                            "state": 0, // 0刚提交 1 审核通过  2 审核拒绝  3 已经归还
                            "borrowing_date": "", // 归还时间
                          });
                          // 把这个发布的商品状态修改为申请中的状态  0 是默认  1 申请中  2 出借中
                          dynamic da = widget.data;
                          await db.collection("lend").doc(da['id']).update({
                            "state": 1,
                          });
                          // 申请了之后发送通知给出借人
                          dynamic data = {
                            "apply_id": createApply.id,
                            "body": "${userBean?.username} ",
                            "address": address,
                            "user_id": widget.data['user_id'],
                            // 这个应该是出借人的id
                            "apply_user_id": userBean?.id,
                            // 申请人
                            "apply_user_name": "${userBean?.username}",
                            // 申请人姓名
                            "lend_user_name": widget.data['name'],
                            // 持有人姓名
                            "lend_id": widget.data['id'],
                            // 商品id
                            "goods_img": widget.data["goods_img"],
                            "goods_name": widget.data["goods_name"],
                          };
                          await db.collection("message").add({
                            "content": json.encode(data),
                            "type": 2, // 2告诉出借人 东西被申请借出
                            "datetime": DateTool.getToDay(),
                            "state": 0, // 0 未读
                            "auditing_state": -1,
                            "user_id": widget.data['user_id'], // 这个应该是出借人的id
                          });

                          // 添加一个借出的数据
                          SnackUtils.showSnack(context, "${S.of(context).successfully_submitted_application}"); // 提交申请成功
                          setState(() {
                            loading = false;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          "${S.of(context).submit}",
                          style: TextStyle(fontSize: 20),
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

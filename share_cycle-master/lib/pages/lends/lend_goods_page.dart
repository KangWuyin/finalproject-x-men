import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/pages/dialog/date_dialog.dart';
import 'package:share_cycle/utils/date_tool.dart';
import 'package:share_cycle/utils/email_utils.dart';
import 'package:share_cycle/utils/image_utils.dart';
import 'package:share_cycle/utils/snack_utils.dart';
import 'package:share_cycle/utils/sp_utils.dart';
import 'package:share_cycle/widget/title.dart';

class LendGoodsPage extends StatefulWidget {
  String goodsType;
  String type;

  dynamic oldData;

  LendGoodsPage(
      {super.key, required this.goodsType, required this.type, this.oldData});

  @override
  State<LendGoodsPage> createState() => _LendGoodsPageState();
}

class _LendGoodsPageState extends State<LendGoodsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  UserBean? userBean;

  TextEditingController _name = TextEditingController();
  TextEditingController _goodsName = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _information = TextEditingController();
  TextEditingController _phone = TextEditingController();

  // String name = "";
  // String goodsName = "";
  String goodsImage = "";
  String address = "225 Terry Avenue";
  String email = "";
  String startDate = "";
  String endDate = "";

  // String information = "";
  // String phone = "";

  int? selectAddress = 1;
  List<File> selectFile = [];
  bool loading = false;

  List<dynamic> oldImageUrl = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userBean = UserBean.fromJson(json.decode(await getData("local_user")));

      if (widget.oldData != null) {
        _name = TextEditingController();
        _name.text = widget.oldData['name'];
        _goodsName = TextEditingController();
        _goodsName.text = widget.oldData['goods_name'];
        goodsImage = widget.oldData['goods_img'];
        _email = TextEditingController();
        _email.text = widget.oldData['email'];
        _information = TextEditingController();
        _information.text = widget.oldData['information'];
        _phone = TextEditingController();
        _phone.text = widget.oldData['phone'];

        address = widget.oldData['address'];
        if (address == "225 Terry Avenue") {
          selectAddress = 1;
        } else {
          selectAddress = 2;
        }

        startDate = widget.oldData['start_date'];
        endDate = widget.oldData['end_date'];

        oldImageUrl =
            (json.decode(widget.oldData["goods_img"]) as List<dynamic>)
                .map((e) => e)
                .toList();

        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          titleWidget(title: "${S.of(context).upload_goods}", leading: true),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 150.h,
                  width: double.maxFinite,
                  child: (selectFile.isNotEmpty)
                      ? PageView.builder(
                          itemCount: selectFile.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Image.file(selectFile[index],
                                fit: BoxFit.fill);
                          },
                        )
                      : PageView.builder(
                          itemCount: oldImageUrl.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Image.network(
                                ImageUtils.firebaseImageUrl(
                                    fileName: oldImageUrl[index]),
                                fit: BoxFit.fill,
                                width: double.maxFinite);
                          },
                        )),
              Container(
                width: double.maxFinite,
                child: ElevatedButton(
                    onPressed: () async {
                      // select image to upload
                      List<File> showOpenPhoto = await ImageUtils.showOpenPhoto(
                        context,
                      );
                      if (showOpenPhoto.isNotEmpty) {
                        setState(() {
                          selectFile = showOpenPhoto;
                        });
                        ImageUtils.firebaseUploadFile(
                            selectFile: selectFile,
                            goodsImage: (goodsImageUrl) {
                              goodsImage = goodsImageUrl;
                            });
                      }
                    },
                    child: Text("${S.of(context).upload_image}",
                        style: TextStyle(fontSize: 20))),
              ),
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: "${S.of(context).your_name}",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              TextField(
                controller: _goodsName,
                decoration: InputDecoration(
                  labelText: "${S.of(context).goods_name}",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      showDateSelect(context,
                          startDate: DateTool.getToDay(),
                          endDate: "", selectDate: (value) {
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
                        (startDate == "")
                            ? "${S.of(context).select_data}"
                            : startDate,
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
                      if (startDate == "") {
                        SnackUtils.showSnack(context,
                            "${S.of(context).please_select_start_time_lend}");
                        return;
                      }
                      showDateSelect(context, startDate: startDate, endDate: "",
                          selectDate: (value) {
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
                        (endDate == "")
                            ? "${S.of(context).select_data}"
                            : endDate,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ))
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "${S.of(context).address}",
                style: TextStyle(fontSize: 20),
              ),
              RadioMenuButton(
                  style: ButtonStyle(
                    // remove margin
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: MaterialStateProperty.all(const EdgeInsets.only(
                        left: 0, right: 30, top: 4, bottom: 4)),
                  ),
                  value: 1,
                  groupValue: selectAddress,
                  onChanged: (value) {
                    address = "225 Terry Avenue";
                    setState(() {
                      selectAddress = value;
                    });
                  },
                  child: Text("225 Terry Avenue")),
              RadioMenuButton(
                  style: ButtonStyle(
                    //remove margin
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: MaterialStateProperty.all(const EdgeInsets.only(
                        left: 0, right: 30, top: 4, bottom: 4)),
                  ),
                  value: 2,
                  groupValue: selectAddress,
                  onChanged: (value) {
                    address = "401 Terry Ave N";
                    setState(() {
                      selectAddress = value;
                    });
                  },
                  child: Text("401 Terry Ave N")),
              TextField(
                controller: _phone,
                decoration: InputDecoration(
                  labelText: "${S.of(context).phone}",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: "${S.of(context).email}",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              TextField(
                controller: _information,
                maxLines: 5,
                decoration: InputDecoration(
                    labelText: "${S.of(context).information}",
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1))),
              ),
              SizedBox(
                height: 10.h,
              ),
              if (loading)
                Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!loading)
                Container(
                  width: double.maxFinite,
                  child: ElevatedButton(
                      onPressed: () async {
                        String name = _name.text;
                        String goodsName = _goodsName.text;
                        String email = _email.text;
                        String information = _information.text;
                        String phone = _phone.text;

                        if (loading) {
                          return;
                        }

                        if (goodsImage == "") {
                          SnackUtils.showSnack(context,
                              "${S.of(context).please_select_an_item_photo}"); //Please select an item photo
                          return;
                        }
                        if (name == "") {
                          SnackUtils.showSnack(context,
                              "${S.of(context).please_fill_in_the_name_of_the_lender}"); //Please fill in the lender's name
                          return;
                        }
                        if (goodsName == "") {
                          SnackUtils.showSnack(context,
                              "${S.of(context).please_fill_in_the_item_name}"); //Please fill in the item name
                          return;
                        }

                        if (!EmailUtils.checkEmail(context, email)) {
                          return;
                        }
                        // if(email==""){
                        //   SnackUtils.showSnack(context, "${S.of(context).please_fill_in_the_email_address}");
                        //   return;
                        // }
                        if (startDate == "") {
                          SnackUtils.showSnack(context,
                              "${S.of(context).please_select_the_start_date}");
                          return;
                        }
                        if (endDate == "") {
                          SnackUtils.showSnack(context,
                              "${S.of(context).please_select_the_end_date}");
                          return;
                        }
                        if (information == "") {
                          SnackUtils.showSnack(context,
                              "${S.of(context).please_fill_in_the_description_information}"); // Please fill in the description information
                          return;
                        }

                        setState(() {
                          loading = true;
                        });

                        // submit product lending information
                        // String goodsImageEx= "";
                        // if(widget.oldData!=null && goodsImage == ""){
                        //   goodsImageEx =  widget.oldData["goods_img"];
                        // }else{
                        //   goodsImageEx=goodsImage;
                        // }
                        final lend = <String, dynamic>{
                          "address": address,
                          "email": email,
                          "end_date": endDate,
                          "start_date": startDate,
                          "goods_img":
                              goodsImage, // If no modifications are made, then use the previous part
                          "goods_type": widget.type,
                          "name": name,
                          "goods_name": goodsName,
                          "phone": phone,
                          "information": information,
                          "user_id": userBean?.id,
                          "create_date": DateTool.getToDay(),
                          "state":
                              0, // 0 have not been borrowed  1 have been borrowed
                        };
                        // Determine whether to modify or add.
                        if (widget.oldData != null) {
                          // modify
                          await db
                              .collection('lend')
                              .doc(widget.oldData['id'])
                              .update(lend);
                          SnackUtils.showSnack(context,
                              "${S.of(context).successfully_update_the_loaned_item}"); //modification of lent items added successfully
                          setState(() {
                            loading = false;
                          });
                        } else {
                          var createValue =
                              await db.collection('lend').add(lend);
                          if (createValue.id != "") {
                            SnackUtils.showSnack(context,
                                "${S.of(context).successfully_added_the_loaned_item}"); //Item successfully added for lending
                          }
                          setState(() {
                            loading = false;
                          });
                        }

                        Navigator.pop(context);
                      },
                      child: Text(
                        "${S.of(context).submit}",
                        style: TextStyle(fontSize: 20),
                      )),
                ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

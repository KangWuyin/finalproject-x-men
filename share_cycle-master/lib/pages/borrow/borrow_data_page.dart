import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/pages/borrow/borrow_details_page.dart';
import 'package:share_cycle/pages/borrow/dialog_item_page.dart';
import 'package:share_cycle/utils/image_utils.dart';
import 'package:share_cycle/utils/sp_utils.dart';
import 'package:share_cycle/widget/title.dart';

// List data
// All products submitted for lending by others
class BorrowDataPage extends StatefulWidget {
  String title = "";
  String type = "";

  BorrowDataPage({super.key, required this.title, required this.type});

  @override
  State<BorrowDataPage> createState() => _BorrowDataPageState();
}

class _BorrowDataPageState extends State<BorrowDataPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<dynamic> lendDataAll = [];
  List<dynamic> lendData = [];

  bool isLoading = false;
  bool showLocation = false;
  bool showSort = false;

  // prerequisite
  String title = "";
  String type = "";
  String address = "All";
  int selectAddressId = 0;
  String selectSort = "";

  UserBean? userBean;
  bool isSearch = false;
  String searchValue = "";

  @override
  void initState() {
    super.initState();
    title = widget.title;
    type = widget.type;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userBean = UserBean.fromJson(json.decode(await getData("local_user")));
      selectSort = S.of(context).sort;
      setState(() {

      });
      getLends();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          child: (isSearch)
              ? Row(
                  children: [
                    Expanded(child: TextField(
                      onChanged: (value) {
                        searchValue = value;
                      },
                    )),
                    ElevatedButton(onPressed: (){ getLends(goodsName: searchValue);}, child: Icon(Icons.search)),
                    GestureDetector(
                      onTap: () {
                        getLends(goodsName: "");
                        setState(() {
                          isSearch = false;
                          searchValue = "";
                        });
                      },
                      child: Icon(Icons.close_sharp),
                    )
                  ],
                )
              : Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
        actions: [
          if (!isSearch)
            GestureDetector(
              onTap: () {
                // start search
                setState(() {
                  isSearch = true;
                });
              },
              child: Icon(Icons.search),
            ),
          SizedBox(
            width: 5.w,
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                    onTap: () async {
                      setState(() {
                        showSort = false;
                        showLocation = !showLocation;
                      });
                    },
                    child:Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "$address",
                          style: TextStyle(fontSize: 20),
                        ),

                      ],
                    ),
                ),

                Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showLocation = false;
                      showSort = !showSort;
                    });
                  },
                  child: Text(
                    "${selectSort}",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.black,
                ),
              ],
            ),

            if(isLoading)
              CircularProgressIndicator(),
            Expanded(
              child: Stack(
                children: [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1,
                      childAspectRatio: 1,
                      crossAxisSpacing: 1,
                    ),
                    itemCount: lendData.length,
                    itemBuilder: (BuildContext context, int index) {
                      dynamic data = lendData[index];
                      List<dynamic> images = (json.decode(data["goods_img"]) as List<dynamic>).map((e) => e).toList();
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return BorrowDetailsPage(
                              data: data,
                            );
                          }));
                          getLends();
                        },
                        child: Container(
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black, width: 1)),
                          child: Column(
                            children: [
                              Expanded(
                                child: (data["goods_img"] == "")
                                    ? Container(
                                        height: 60,
                                      )
                                    // image show
                                    : Container(
                                        height: 60,
                                        child: Image.network(
                                          ImageUtils.firebaseImageUrl(fileName: images[0]),
                                          fit: BoxFit.fill,
                                          width: double.maxFinite,
                                        ),
                                      ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(
                                height: 1,
                                color: Colors.black,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  "${data["goods_name"]}",
                                  maxLines: 2,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Visibility(
                      visible: showLocation,
                      child: DialogItemPage(
                        data: [
                          {"id": 0, "name": "All"},
                          {"id": 1, "name": "225 Terry Avenue"},
                          {"id": 2, "name": "401 Terry Ave N"},
                        ],
                        selectItemDataClick: (value){

                          address = value['name'];
                          selectAddressId = value['id'];
                          getLends();
                          setState(() {
                            showLocation = false;
                            showSort = false;
                          });
                        },
                        selectItemClick: (value) {
                        //   address = value;
                        //   getLends();
                        //   setState(() {
                        //     showLocation = false;
                        //     showSort = false;
                        //   });
                        },
                      )),
                  Visibility(
                      visible: showSort,
                      child: DialogItemPage(
                        data: [
                          {"id": 0, "name": "${S.of(context).lend_all}"},
                          {"id": 1, "name": "${S.of(context).reserved}"},
                          {"id": 2, "name": "${S.of(context).un_reserved}"},
                        ],
                        selectItemDataClick: (value){
                          //  Express center delivery
                          // if (value == "Reverse") {
                          selectSort = value['name'];
                          if (value['id'] == 0) { // all
                              // 倒序 Reverse
                              lendData.clear();
                              lendData.addAll(lendDataAll);
                          } else if (value['id'] == 1) { // reserve
                            lendData.clear();
                            lendDataAll.forEach((element) {
                              if(element['state']==1){
                                lendData.add(element);
                              }
                            });
                          } else if (value['id'] == 2) { // unreserved
                            lendData.clear();
                            lendDataAll.forEach((element) {
                              if(element['state']==0){
                                lendData.add(element);
                              }
                            });
                          }

                          setState(() {
                            showSort = false;
                            showLocation = false;
                          });
                        },
                        selectItemClick: (value) {
                        },
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getLends({String goodsName = ""}) async {
    dynamic future;
   setState(() {
     isLoading = true;
   });
    if(selectAddressId==0){
      future = await db
          .collection("lend")
          .orderBy("create_date", descending: true)
          .where("goods_type", isEqualTo: type)
          // .where("address", isEqualTo: address)
      // .where("state", isEqualTo: 0)
          .get(GetOptions());
    }else {
      future = await db
          .collection("lend")
          .orderBy("create_date", descending: true)
          .where("goods_type", isEqualTo: type)
          .where("address", isEqualTo: address)
      // .where("state", isEqualTo: 0)
          .get(GetOptions());
    }

    lendDataAll.clear();
    lendData.clear();
    var docs = future.docs;
    for (var value in docs) {
      lendData.add({
        "id": value.id,
        "address": value.get("address"),
        "email": value.get("email"),
        "start_date": value.get("start_date"),
        "end_date": value.get("end_date"),
        "goods_img": value.get("goods_img"),
        "goods_type": value.get("goods_type"),
        "information": value.get("information"),
        "name": value.get("name"),
        "goods_name": value.get("goods_name"),
        "phone": value.get("phone"),
        "create_date": value.get("create_date"),
        "user_id": value.get("user_id"),
        "state": value.get("state"),
      });
    }
    // If the filter is not empty, then filter locally.
    if (goodsName != "") {
      lendData.clear();
      for (var value in docs) {
        String goodsNameResult = value.get("goods_name");
        if (goodsNameResult.contains(goodsName)) {
          //包含
          lendData.add({
            "id": value.id,
            "address": value.get("address"),
            "email": value.get("email"),
            "start_date": value.get("start_date"),
            "end_date": value.get("end_date"),
            "goods_img": value.get("goods_img"),
            "goods_type": value.get("goods_type"),
            "information": value.get("information"),
            "name": value.get("name"),
            "goods_name": value.get("goods_name"),
            "phone": value.get("phone"),
            "create_date": value.get("create_date"),
            "user_id": value.get("user_id"),
            "state": value.get("state"),
          });
        }
      }
    }
    setState(() {
      isLoading = false;
    });

    lendDataAll.addAll(lendData);

    setState(() {});
  }
}

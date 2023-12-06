

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/pages/lends/lend_goods_page.dart';
import 'package:share_cycle/utils/sp_utils.dart';

class LendPage extends StatefulWidget {
  const LendPage({super.key});

  @override
  State<LendPage> createState() => _LendPageState();
}

class _LendPageState extends State<LendPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 10,right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${S.of(context).lending}",style: TextStyle(fontSize: 16),),

            item(iconData: Icons.account_balance, label: "${S.of(context).furniture}",type:"Furniture", click: () {}),
            item(iconData: Icons.pan_tool_alt_sharp, label: "${S.of(context).tools}",type:"Tools", click: () {}),
            item(iconData: Icons.school, label: "${S.of(context).school_supplies}",type:"School supplies", click: () {}),
            item(iconData: Icons.devices, label: "${S.of(context).devices}",type:"Devices", click: () {}),
            item(iconData: Icons.house, label: "${S.of(context).household_appliances}",type:"Household appliances", click: () {}),
            item(iconData: Icons.devices_other, label: "${S.of(context).others}",type:"Others", click: () {}),
          ],
        ),
      ),
    );
  }

  Widget item({required IconData iconData, String label = "", String type = "", required Function click}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return LendGoodsPage(goodsType: label,type: type,);
        }));

        // click();
      },
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        margin: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          children: [
            Expanded(child: Container(
              child: Icon(
                iconData,
                size: 30,
              ),
              alignment: Alignment.centerRight,
            )),
            SizedBox(
              width: 20,
            ),
            Expanded(flex: 2,child: Text(
              "${label}",
              style: TextStyle(fontSize: 20),
            )),
          ],
        ),
      ),
    );
  }
}

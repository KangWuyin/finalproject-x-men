import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/pages/borrow/borrow_data_page.dart';

class BorrowPage extends StatefulWidget {
  const BorrowPage({super.key});

  @override
  State<BorrowPage> createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.amber,
              margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              child: Image.asset("assets/images/borrowind.jpg"),
            ),
            Divider(
              height: 2,
              color: Colors.black12,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "${S.of(context).classification}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 2,
              color: Colors.black12,
            ),
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

  Widget item({required IconData iconData, String label = "",required String type , required Function click}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return BorrowDataPage(title: label,type: type,);
        }));
        click();
      },
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        margin: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          children: [
            Expanded(
                child: Container(
              child: Icon(
                iconData,
                size: 30,
              ),
              alignment: Alignment.centerRight,
            )),
            SizedBox(
              width: 20,
            ),
            Expanded(
                flex: 2,
                child: Text(
                  "${label}",
                  style: TextStyle(fontSize: 20),
                )),
          ],
        ),
      ),
    );
  }
}

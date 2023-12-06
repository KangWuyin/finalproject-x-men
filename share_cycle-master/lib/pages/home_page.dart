import 'package:flutter/material.dart';
import 'package:share_cycle/event_utils.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/pages/home/account_page.dart';
import 'package:share_cycle/pages/home/borrow_page.dart';
import 'package:share_cycle/pages/home/lend_page.dart';
import 'package:share_cycle/pages/home/return_page.dart';
import 'package:share_cycle/widget/title.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String title = "";

  List<String> dataTitle = [
    // "Borrow ",
    // "Lend",
    // "Return",
    // "Account",
  ];
  List dataWidget = [
    BorrowPage(),
    LendPage(),
    ReturnPage(),
    AccountPage(),
  ];

  int currentIndex = 0;

  setCurrent(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        setLanguage();
      });
    });

    eventBus.on<CheckLanguageEvent>().listen((event) {
      if(event.check!){
        // 重新加载读取
        setState(() {
          setLanguage();
        });
      }
    });
  }

  setLanguage(){
    setState(() {
      dataTitle.clear();
      dataTitle=[
        "${S.of(context).home_borrow}",
        "${S.of(context).home_lend}",
        "${S.of(context).home_return}",
        "${S.of(context).home_account}",
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(title: dataTitle[currentIndex]),
      bottomNavigationBar: (dataTitle.isNotEmpty)?BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.black,
        unselectedFontSize: 12,
        selectedFontSize: 12,
        unselectedIconTheme: IconThemeData(color: Colors.black),
        selectedItemColor: Colors.lightBlue,
        currentIndex: currentIndex,
        items:  [
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "${dataTitle[0].toString()}"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "${dataTitle[1].toString()}"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_return), label: "${dataTitle[2].toString()}"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "${dataTitle[3].toString()}"),
        ],
        onTap: (index) {
          setCurrent(index);
        },
        type: BottomNavigationBarType.fixed,
      ):null,
      body: dataWidget[currentIndex],
    );
  }
}

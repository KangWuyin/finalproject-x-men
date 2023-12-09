class DateTool {
  /// days of the month
  static String getToDay() {
    DateTime currentTime = DateTime.now();
    var month = (currentTime.month.toString().length == 1) ? "0${currentTime.month}" : currentTime.month;
    var day = (currentTime.day.toString().length == 1) ? "0${currentTime.day}" : currentTime.day;
    var hour = (currentTime.hour.toString().length == 1) ? "0${currentTime.hour}" : currentTime.hour;
    var minute = (currentTime.minute.toString().length == 1) ? "0${currentTime.minute}" : currentTime.minute;
    var second = (currentTime.second.toString().length == 1) ? "0${currentTime.second}" : currentTime.second;
    return "${currentTime.year}-$month-$day $hour:$minute:$second";
  }

  /// Current Time Year Month Day Hour Minute
  static String getTodayYearMothDayHourMinute() {
    DateTime currentTime = DateTime.now();
    var month = (currentTime.month.toString().length == 1) ? "0${currentTime.month}" : currentTime.month;
    var day = (currentTime.day.toString().length == 1) ? "0${currentTime.day}" : currentTime.day;
    var hour = (currentTime.hour.toString().length == 1) ? "0${currentTime.hour}" : currentTime.hour;
    var minute = (currentTime.minute.toString().length == 1) ? "0${currentTime.minute}" : currentTime.minute;
    return "${currentTime.year}-$month-$day $hour:$minute";
  }

  /// Last hours of the day
  static String todayEnd() {
    DateTime currentTime = DateTime.now();
    var month = (currentTime.month.toString().length == 1) ? "0${currentTime.month}" : currentTime.month;
    var day = (currentTime.day.toString().length == 1) ? "0${currentTime.day}" : currentTime.day;
    return "${currentTime.year}-${month}-${day} 23:59:59";
  }

  /// timestamp
  static String timestamp() {
    DateTime currentTime = DateTime.now();
    return "${currentTime.microsecondsSinceEpoch}";
  }

  // How many days before the specified time, or how many days before the current time
  static String ageDay(String currDateTime, int days) {
    DateTime dateTime = (currDateTime != "") ? DateTime.parse(currDateTime) : DateTime.now();
    DateTime dateResult = DateTime(dateTime.year, dateTime.month, dateTime.day - days, dateTime.hour, dateTime.minute, dateTime.second);
    var month = (dateResult.month.toString().length == 1) ? "0${dateResult.month}" : dateResult.month;
    var day = (dateResult.day.toString().length == 1) ? "0${dateResult.day}" : dateResult.day;
    return "${dateResult.year}-$month-$day";
  }

  // Generate time-date data
  static List<DateBean> getCompleteData({String startDate = ""}) {

    List<DateBean> dateBeans = [];

    DateTime firstTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: -90));

    DateTime startDateTime = (startDate != "") ? DateTime.parse(startDate) : DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);

    DateTime endDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    while (startDateTime.millisecondsSinceEpoch < endDateTime.millisecondsSinceEpoch) {

      DateBean monthDateBean = DateBean();
      monthDateBean.monthStr = "${startDateTime.year}-${startDateTime.month}"; // 年月
      monthDateBean.itemType = DateBean.item_type_month;
      dateBeans.add(monthDateBean);
      addDatePlaceholder(dateBeans, 6, monthDateBean.monthStr.toString());

      DateTime currentLastTime = DateTime(
        startDateTime.year,
        startDateTime.month + 1,
      );
      currentLastTime = currentLastTime.subtract(Duration(days: 1));

      while (startDateTime.millisecondsSinceEpoch <= currentLastTime.millisecondsSinceEpoch) {
        if (startDateTime.millisecondsSinceEpoch == firstTime.millisecondsSinceEpoch) {
          switch (startDateTime.weekday) {
            case 1:
              break;
            case 2:
              addDatePlaceholder(dateBeans, 1, monthDateBean.monthStr.toString());
              break;
            case 3:
              addDatePlaceholder(dateBeans, 2, monthDateBean.monthStr.toString());
              break;
            case 4:
              addDatePlaceholder(dateBeans, 3, monthDateBean.monthStr.toString());
              break;
            case 5:
              addDatePlaceholder(dateBeans, 4, monthDateBean.monthStr.toString());
              break;
            case 6:
              addDatePlaceholder(dateBeans, 5, monthDateBean.monthStr.toString());
              break;
            case 7:
              addDatePlaceholder(dateBeans, 6, monthDateBean.monthStr.toString());
              break;
          }
        } else {
          if (startDateTime.day == 1) {
            switch (startDateTime.weekday) {
              case 1:
                break;
              case 2:
                addDatePlaceholder(dateBeans, 1, monthDateBean.monthStr.toString());
                break;
              case 3:
                addDatePlaceholder(dateBeans, 2, monthDateBean.monthStr.toString());
                break;
              case 4:
                addDatePlaceholder(dateBeans, 3, monthDateBean.monthStr.toString());
                break;
              case 5:
                addDatePlaceholder(dateBeans, 4, monthDateBean.monthStr.toString());
                break;
              case 6:
                addDatePlaceholder(dateBeans, 5, monthDateBean.monthStr.toString());
                break;
              case 7:
                addDatePlaceholder(dateBeans, 6, monthDateBean.monthStr.toString());
                break;
            }
          }
        }
        DateBean dateBean = DateBean();
        dateBean.dateTime = startDateTime;
        dateBean.day = startDateTime.day.toString();
        dateBean.monthStr = monthDateBean.monthStr;
        dateBean.itemType = DateBean.item_type_day;
        dateBeans.add(dateBean);
        if (startDateTime.millisecondsSinceEpoch == currentLastTime.millisecondsSinceEpoch) {
          var weekDay = startDateTime.weekday;
          switch (weekDay) {
            case 1:
              addDatePlaceholder(dateBeans, 6, monthDateBean.monthStr.toString());
              break;
            case 2:
              addDatePlaceholder(dateBeans, 5, monthDateBean.monthStr.toString());
              break;
            case 3:
              addDatePlaceholder(dateBeans, 4, monthDateBean.monthStr.toString());
              break;
            case 4:
              addDatePlaceholder(dateBeans, 3, monthDateBean.monthStr.toString());
              break;
            case 5:
              addDatePlaceholder(dateBeans, 2, monthDateBean.monthStr.toString());
              break;
            case 6:
              addDatePlaceholder(dateBeans, 1, monthDateBean.monthStr.toString());
              break;
          }
        }
        startDateTime = startDateTime.add(Duration(days: 1));
      }
    }
    dateBeans.forEach((element) {
      if (element.itemType == DateBean.item_type_month) {
        print("月份------------:${element.monthStr.toString()}");
      } else {
        print("日期:${element.dateTime?.month.toString()}-${element.dateTime?.day.toString()}");
      }
    });
    return dateBeans;
  }

  //Add an empty date placeholder
  static void addDatePlaceholder(List<DateBean> dateBeans, int count, String monthStr) {
    for (int i = 0; i < count; i++) {
      DateBean dateBean = DateBean();
      dateBean.monthStr = "占位 ${monthStr}";
      dateBeans.add(dateBean);
    }
  }
}

class DateBean {
  //item type
  static int item_type_day = 1; //日期item
  static int item_type_month = 2; //月份item

  int itemType = 1;
  //item state
  static int ITEM_STATE_BEGIN_DATE = 1;
  static int ITEM_STATE_END_DATE = 2;
  static int ITEM_STATE_SELECTED = 3;
  static int ITEM_STATE_NORMAL = 4;
  static int ITEM_STATE_NO_CHECK = 5;
  int itemState = ITEM_STATE_NORMAL;

  DateTime? dateTime;
  String? day;
  String? monthStr;
}

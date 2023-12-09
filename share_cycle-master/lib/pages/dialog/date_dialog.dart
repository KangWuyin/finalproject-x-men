import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

showDateSelect(BuildContext context, {
  String startDate = "",String endDate="",
  required Function(String) selectDate}) async {
  final String currentLocale = Intl.defaultLocale ?? window.locale.languageCode;
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.parse(startDate),
    firstDate: startDate==""? DateTime(2023):DateTime.parse(startDate), // start time
    lastDate: endDate==""? DateTime(2024,12,31):DateTime.parse(endDate),  // end time
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    locale: Locale("$currentLocale")
  );
  if (picked != null) {
    dynamic month =  picked.month<10?"0${picked.month}":picked.month;
    dynamic day =  picked.day<10?"0${picked.day}":picked.month;
    selectDate("${picked.year}-${month}-${day}");
  }
}

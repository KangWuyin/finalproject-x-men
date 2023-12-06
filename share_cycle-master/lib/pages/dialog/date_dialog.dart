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
    firstDate: startDate==""? DateTime(2023):DateTime.parse(startDate), // 开始时间
    lastDate: endDate==""? DateTime(2024,12,31):DateTime.parse(endDate),  // 结束时间选择
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    locale: Locale("$currentLocale")
  );
  if (picked != null) {
    selectDate("${picked.year}-${picked.month}-${picked.day}");
  }
}

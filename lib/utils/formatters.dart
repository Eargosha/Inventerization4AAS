String formatDateTime(DateTime dateTime, {bool? deep}) {
  String addLeadingZero(int number) => number.toString().padLeft(2, '0');

  int day = dateTime.day;
  int month = dateTime.month;
  int year = dateTime.year;
  int hour = dateTime.hour;
  int minute = dateTime.minute;

  return deep == true ? '${addLeadingZero(day)}.${addLeadingZero(month)}.$year ${addLeadingZero(hour)}:${addLeadingZero(minute)}' : '${addLeadingZero(day)}.${addLeadingZero(month)}.$year';
}

import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'edit.dart';

Color txtColor = Colors.black,
    bodyColor = Colors.white,
    mainColor = Colors.blue;
Widget Txt(String txt, Color color, double size, bool bold) {
  return Text(
    txt,
    style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal),
  );
}

Widget Input(
    double h,
    double w,
    String hint,
    String val,
    TextInputType type,
    Color color,
    Color txtC,
    TextEditingController controller,
    Function tap,
    Function save) {
  return SizedBox(
    width: w,
    height: h,
    child: TextFormField(
      initialValue: val,
      controller: controller,
      keyboardType: type,
      style: TextStyle(color: txtC, fontSize: 20, fontWeight: FontWeight.w500),
      decoration: InputDec(hint, color),
      onChanged: save,
      onTap: tap,
    ),
  );
}

InputDecoration InputDec(String txt, Color color) {
  return InputDecoration(
    fillColor: color,
    filled: true,
    hintText: txt,
    hintStyle: TextStyle(
        color: color == bodyColor ? txtColor : Colors.white, fontSize: 22),
    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(5),
    ),
    focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: mainColor, width: 2)),
  );
}

//
//Widget DateInput(Function save, String hint, DateTime val) {
//  return DateTimeField(
//    enabled: true,
//    format: DateFormat("yyyy-MM-dd"),
//    onSaved: save,
//    keyboardType: TextInputType.datetime,
//    decoration: InputDec(hint, bodyColor),
//    onChanged: save,
//    onShowPicker: (context, currentValue) {
//      return showDatePicker(
//          context: context,
//          firstDate: DateTime.now(),
//          initialDate: val,
//          lastDate: DateTime.now().add(new Duration(days: 365)));
//    },
//  );
//}
Widget ListItem(
    BuildContext context, int id, String title, String date, String days) {
  return ListTile(
    contentPadding: EdgeInsets.all(8),
    title: Padding(
      padding: EdgeInsets.only(bottom: 7),
      child: Txt(title, mainColor, 20, true),
    ),
    subtitle: Txt('$date', txtColor, 18, false),
    trailing: Txt("$days", txtColor, 18, false),
    onLongPress: () {},
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Edit(),
          settings: RouteSettings(arguments: [id, title, date])));
    },
  );
}

String Remaining(int days, int hours, int minutes) {
  String txt;
  int months;
  if (days % 28 == 0) {
    months = (days / 28).toInt();
  } else if (days % 29 == 0) {
    months = (days / 29).toInt();
  } else if (days % 30 == 0) {
    months = (days / 28).toInt();
  } else if (days % 31 == 0) {
    months = (days / 28).toInt();
  } else {
    months = 0;
  }
  if (months > 1) {
    txt = "$months months ";
  } else if (months == 1) {
    txt = "1 month ";
  } else if (days > 1 && days % 7 != 0) {
    txt = "$days days ";
  } else if (days == 1 && months == 0) {
    txt = "1 day ";
  } else if (days % 7 == 0 && days != 7 && days != 0) {
    txt = "${days % 7} weeks";
  } else if (days == 7) {
    txt = "1 week ";
  } else if (hours > 1) {
    txt = "$hours hours ";
  } else if (hours == 1) {
    txt = "1 hour ";
  } else if (minutes > 1) {
    txt = "$minutes minutes ";
  } else if (minutes == 1) {
    txt = "1 minute ";
  }
  return txt;
}

int Week(DateTime dateTime) {
  String dat = dateTime.toString();
  String firstDay = dat.substring(0, 8) + '01' + dat.substring(10);
  int weekDay = DateTime.parse(firstDay).weekday;
  DateTime testDate = DateTime.now();
  int weekOfMonth;
  if (weekDay == 7) {
    weekDay = 0;
  }
  weekOfMonth = ((testDate.day + weekDay) / 7).ceil();
  return weekOfMonth;
}

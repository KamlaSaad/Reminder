import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'db.dart';
import 'variables.dart';

class Edit extends StatefulWidget {
  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  List data;
  String title, date, time;
  SQL_Helper db;
  @override
  void initState() {
    super.initState();
    db = SQL_Helper();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width,
        h = MediaQuery.of(context).size.height;
    data = ModalRoute.of(context).settings.arguments;
    var t = DateTime.parse(data[2]);
    String oldD = "${t.year}-${t.month}-${t.day}";
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              if (title != null && date != null && time != null) {
                int result =
                    await db.updateEvent(data[0], title, "$date $time");
                Navigator.of(context).pop();
                print('result $result');
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              int result = await db.deleteEvent(data[0]);
              print('result $result');
              await db.getEvents();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Input(50, w, "", "${data[1]}", TextInputType.text, Colors.transparent,
              txtColor, null, () {}, (val) {
            setState(() {
              title = val != null ? val : data[1];
            });
          }),
          FlatButton(
            onPressed: () async {
              var selectedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  initialDate: DateTime.parse(data[2]),
                  lastDate: DateTime.now().add(new Duration(days: 365)));
              if (selectedDate != null) {
                var month = selectedDate.month < 10
                    ? "0${selectedDate.month}"
                    : selectedDate.month;
                var day = selectedDate.day < 10
                    ? "0${selectedDate.day}"
                    : selectedDate.day;
                setState(() {
                  date = "${selectedDate.year}-$month-$day";
                });
              }
            },
            child: Txt('${date == null ? oldD : date}', txtColor, 20, false),
          ),
          FlatButton(
            onPressed: () async {
              print("${Week(DateTime.now())}");
              var selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: t.hour, minute: t.minute),
              );
              if (selectedTime != null) {
                var hour = selectedTime.hour < 10
                    ? "0${selectedTime.hour}"
                    : selectedTime.hour;
                var minute = selectedTime.minute < 10
                    ? "0${selectedTime.minute}"
                    : selectedTime.minute;
                setState(() {
                  time = "$hour:$minute";
                });
              }
            },
            child: Txt('${time == null ? "${t.hour}: ${t.minute}" : time}',
                txtColor, 20, false),
          )
        ],
      ),
    );
  }
}

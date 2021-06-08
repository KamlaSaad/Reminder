import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'edit.dart';
import 'search.dart';
import 'dart:async';
import 'db.dart';
import 'variables.dart';

Workmanager workmanager = Workmanager();
AudioPlayer player = AudioPlayer();
AudioCache cache = AudioCache();
String myDate, currentDate;
bool play = false;
var d;

void callbackDispatcher() {
  workmanager.executeTask((task1, inputdata1) async {
    await cache.play('mhmd.mp3');
    return Future.value(true);
  });
}

void main() async {
//  WidgetsFlutterBinding.ensureInitialized();
//  await workmanager.initialize(callbackDispatcher);
//  await workmanager.registerPeriodicTask("test_workertask1", "test_workertask1",
//      inputData: {"data1": "value1", "data2": "value2"},
//      frequency: Duration(minutes: 40),
//      initialDelay: Duration(minutes: 1));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder',
      debugShowCheckedModeBanner: false,
      home: Home(),
      routes: {
        'home': (context) => Home(),
        'edit': (context) => Edit(),
        'search': (context) => Search(),
      },
    );
  }
}

bool delete = false;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  SQL_Helper db;
  String title = "", time = "Time", date = "Date", category = "All", todayNot;
  int listLength = 1, days, hours, minutes;
  var events, flutterLN;
  bool sent = false;
  @override
  void initState() {
    super.initState();
    db = SQL_Helper();
    var androidSetting = AndroidInitializationSettings('ic_launcher');
    var IOSSetting = IOSInitializationSettings();
    var settings =
        InitializationSettings(android: androidSetting, iOS: IOSSetting);
    flutterLN = FlutterLocalNotificationsPlugin();
    flutterLN.initialize(settings);
    listenNotify();
  }

  Future notification(String msg) async {
    var androidDetails = AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.high);
    var iosDetails = IOSNotificationDetails();
    var notDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    flutterLN.show(0, "Reminder", msg, notDetails);
  }

  listenNotify() {
    notify();
    Timer(Duration(seconds: 35), () => notify());
  }

  notify() {
    if (todayNot != null && myDate == currentDate) {
      notification("Now is ${todayNot}");
      print(d);
//      setState(() {
//        sent = result != null ? true : false;
//      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width,
        h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Icon(
                Icons.notifications,
                color: Colors.white,
                size: 100,
              ),
              decoration: BoxDecoration(
                color: mainColor,
              ),
            ),
            DrawerItem("All"),
            Separator(),
            DrawerItem("Today"),
            Separator(),
            DrawerItem("This Week"),
            Separator(),
            DrawerItem("This Month"),
            Separator()
          ],
        ),
      ),
      appBar: AppBar(
        title: Txt("Reminder", Colors.white, 22, true),
        actions: [
          delete
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {},
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).pushNamed("search");
                  },
                ),
        ],
      ),
      body: FutureBuilder(
        future: db.getEvents(),
        builder: (context, AsyncSnapshot snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snap.data.length == 0) {
            return Center(
              child: EventMsg("No Events"),
            );
          }
          return ListView.builder(
              itemCount: listLength,
              itemBuilder: (context, int i) {
                d = DateTime.parse(snap.data[i]['DATE']);
                var now = DateTime.now();
                var remain = d.difference(now);
                String myDate = "${d.year}-${d.month}-${d.day}";
                String myFullDate = "${d.year}-${d.month}-${d.day}";
                todayNot = snap.data[i]['TITLE'];
                days = (remain.inDays);
                hours = (remain.inHours);
                minutes = (remain.inMinutes);
                var txt = !remain.isNegative
                    ? Remaining(days, hours, minutes)
                    : (d == DateTime.now() ? "Now" : "Lost");

                Timer(Duration(seconds: 35), () {
                  setState(() {
                    play = d == now ? true : false;
                    days = (remain.inDays);
                    hours = (remain.inHours);
                    minutes = (remain.inMinutes);
                    txt = remain.isNegative
                        ? "Lost"
                        : ((days == 0 && hours == 0 && minutes == 0)
                            ? "Now"
                            : Remaining(days, hours, minutes));
                  });
                  // print(todayNot);
                });

                var currentWeek = Week(DateTime.now()),
                    week = Week(d),
                    currentMonth = DateTime.now().month,
                    month = d.month,
                    currentDay = DateTime.now().day,
                    day = d.day,
                    list,
                    list0 = ListItem(
                        context,
                        snap.data[i]['ID'],
                        snap.data[i]['TITLE'],
                        snap.data[i]['DATE'],
                        txt == null ? "Now" : txt);
                if (category == "Today" && txt != "Lost") {
                  if (currentDay == day && currentMonth == month) {
                    listLength = snap.data.length;
                    list = list0;
                  } else if (snap.data.length == 0 &&
                      currentDay != day &&
                      currentMonth != month) {
                    list = Center(child: EventMsg("No Events Today"));
                  }
                } else if (category == "This Week" && txt != "Lost") {
                  if (currentMonth == month && currentWeek == week) {
                    listLength = snap.data.length;
                    list = list0;
                  } else if (snap.data.length == 0 &&
                      currentMonth != month &&
                      currentWeek != week) {
                    list = Center(child: EventMsg("No Events This Week"));
                  }
                } else if (category == "This Month" && txt != "Lost") {
                  if (currentMonth == month) {
                    listLength = snap.data.length;
                    list = list0;
                  } else if (snap.data.length == 0 && currentMonth == month) {
                    list = Center(
                      child: EventMsg("No Events This Month"),
                    );
                  }
                } else {
                  listLength = snap.data.length;
                  list = list0;
                }
                return list;
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "add event",
        child: Icon(Icons.add),
        onPressed: () async {
          //scheduleAlarm(DateTime.now().add(Duration(minutes: 1)));
          //await cache.play("mhmd.mp3");
          print("Note :$todayNot");
          print("date: $myDate");
          print("now: $currentDate");
          AddBox(context, w, h);
        },
      ),
    );
  }

  DrawerItem(String txt) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
        child: Txt(txt, txtColor, 24, false),
        onTap: () {
          setState(() {
            category = txt;
          });
          print(category);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Separator() {
    return Container(
      color: mainColor.withOpacity(0.4),
      height: 1,
    );
  }

  EventMsg(String msg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.notifications,
          color: mainColor,
          size: 60,
        ),
        Txt(msg, Colors.black, 22, false),
      ],
    );
  }

  AddBox(BuildContext context, double w, double h) {
    showModalBottomSheet(
        useRootNavigator: true,
        context: context,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, setModalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Txt("Add New Event", mainColor, 22, true),
                Input(50, w * 0.65, "Title", "", TextInputType.text, bodyColor,
                    txtColor, null, () {}, (val) {
                  setState(() {
                    title = val;
                  });
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      minWidth: w * 0.3,
                      color: bodyColor,
                      onPressed: () async {
                        var selectedDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            initialDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(new Duration(days: 365)));
                        if (selectedDate != null) {
                          var month = selectedDate.month < 10
                              ? "0${selectedDate.month}"
                              : selectedDate.month;
                          var day = selectedDate.day < 10
                              ? "0${selectedDate.day}"
                              : selectedDate.day;
                          setModalState(() {
                            date = "${selectedDate.year}-$month-$day";
                          });
                        }
                      },
                      child: Txt('$date', txtColor, 20, false),
                    ),
                    SizedBox(
                      width: w * 0.05,
                    ),
                    FlatButton(
                      minWidth: w * 0.3,
                      color: bodyColor,
                      onPressed: () async {
                        var selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          var hour = selectedTime.hour < 10
                              ? "0${selectedTime.hour}"
                              : selectedTime.hour;
                          var minute = selectedTime.minute < 10
                              ? "0${selectedTime.minute}"
                              : selectedTime.minute;
                          setModalState(() {
                            time = "$hour:$minute";
                          });
                        }
                      },
                      child: Txt('$time', txtColor, 20, false),
                    )
                  ],
                ),
                SizedBox(
                  height: h * 0.01,
                ),
                FlatButton(
                  color: mainColor,
                  minWidth: w * 0.65,
                  child: Txt("Confirm", Colors.white, 22, false),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  onPressed: () async {
                    print('date $date ,title $title');
                    if (title != "" && date != " " && time != " ") {
                      int result = await db.addEvent(title, "$date $time");
                      print('result $result');
                      date = "Date";
                      time = "Time";
                    }
                    await db.getEvents();
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(
                  height: h * 0.01,
                ),
              ],
            );
          });
        });
  }
//  void scheduleAlarm(DateTime scheduledNotificationDateTime) async {
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//      'alarm_notif',
//      'alarm_notif',
//      'Channel for Alarm notification',
//      icon: 'codex_logo',
//      sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
//      largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
//    );
//
//    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
//        sound: 'a_long_cold_sting.wav',
//        presentAlert: true,
//        presentBadge: true,
//        presentSound: true);
//    var platformChannelSpecifics = NotificationDetails();
//
//    await flutterLocalNotificationsPlugin.schedule(0, 'Office', title,
//        scheduledNotificationDateTime, platformChannelSpecifics);
//  }
}

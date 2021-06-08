import 'package:flutter/material.dart';
import 'db.dart';
import 'variables.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String title = "";
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
    return Scaffold(
      appBar: AppBar(
        title: Input(50, w, "Search", "", TextInputType.text,
            Colors.transparent, Colors.white, null, () {}, (val) {
          setState(() {
            title = val;
          });
        }),
      ),
      body: FutureBuilder(
        future: db.search(title),
        builder: (context, AsyncSnapshot snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              itemCount: snap.data.length,
              itemBuilder: (context, int i) {
                DateTime date = DateTime.parse(snap.data[i]['DATE']);
                var remain = DateTime.now().difference(date);
                int days = (remain.inDays).abs(),
                    hours = (remain.inHours).abs(),
                    minutes = (remain.inMinutes).abs();
                String txt = Remaining(days, hours, minutes);
                return ListItem(context, snap.data[i]['ID'],
                    snap.data[i]['TITLE'], snap.data[i]['DATE'], txt);
              });
        },
      ),
    );
  }
}

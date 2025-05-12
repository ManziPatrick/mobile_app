import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoMo Manager',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: SmsListScreen(),
    );
  }
}

class SmsListScreen extends StatefulWidget {
  const SmsListScreen({super.key});

  @override
  _SmsListScreenState createState() => _SmsListScreenState();
}

class _SmsListScreenState extends State<SmsListScreen> {
  final Telephony telephony = Telephony.instance;
  List<SmsMessage> momoMessages = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void requestPermissions() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      await Permission.sms.request();
    }
    loadMessages();
  }

  void loadMessages() async {
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      filter: SmsFilter.where(SmsColumn.ADDRESS).equals("MTN").or(SmsColumn.ADDRESS).equals("AIRTEL"),
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    setState(() {
      momoMessages = messages.where((msg) => isMomoTransaction(msg.body ?? "")).toList();
    });
  }

  bool isMomoTransaction(String message) {
    return message.contains("received") || message.contains("sent") || message.contains("frw");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My MoMo Transactions")),
      body: momoMessages.isEmpty
          ? Center(child: Text("No MoMo messages found"))
          : ListView.builder(
              itemCount: momoMessages.length,
              itemBuilder: (context, index) {
                final msg = momoMessages[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(msg.body ?? ""),
                    subtitle: Text("From: ${msg.address}"),
                  ),
                );
              },
            ),
    );
  }
}

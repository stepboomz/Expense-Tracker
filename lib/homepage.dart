import 'dart:async';
import 'package:expensetracker/EditTransactionScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'google_sheets_api.dart';
import 'loading_circle.dart';
import 'plus_button.dart';
import 'top_card.dart';
import 'transaction.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // collect user input
  final _textcontrollerAMOUNT = TextEditingController();
  final _textcontrollerITEM = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isIncome = false;
  bool timerHasStarted = false;
  DateTime? _selectedDate;

  int _calculateSelectedDateIncome() {
    if (_selectedDate == null) {
      return 0;
    }
    int totalIncome = 0;
    for (var transaction in GoogleSheetsApi.currentTransactions) {
      if (transaction.length < 4) {
        continue;
      }
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final transactionDate = dateFormat.parse(transaction[3]);
      final transactionDateOnly = DateTime(
          transactionDate.year, transactionDate.month, transactionDate.day);

      if (transactionDateOnly == _selectedDate && transaction[2] == 'income') {
        totalIncome += int.parse(transaction[1]);
      }
    }
    return totalIncome;
  }

  int _calculateSelectedDateExpense() {
    if (_selectedDate == null) {
      return 0;
    }
    int totalExpense = 0;
    for (var transaction in GoogleSheetsApi.currentTransactions) {
      if (transaction.length < 4) {
        continue;
      }
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final transactionDate = dateFormat.parse(transaction[3]);
      final transactionDateOnly = DateTime(
          transactionDate.year, transactionDate.month, transactionDate.day);

      if (transactionDateOnly == _selectedDate && transaction[2] == 'expense') {
        totalExpense += int.parse(transaction[1]);
      }
    }
    return totalExpense;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _fetchAndUpdateTransactions() async {
    await GoogleSheetsApi.fetchAndUpdateTransactions(); // Corrected method name
    setState(() {});
  }

  // enter the new transaction into the spreadsheet
  void _enterTransaction() {
    GoogleSheetsApi.insert(
      _textcontrollerITEM.text,
      _textcontrollerAMOUNT.text,
      _isIncome,
    ).then((_) {
      // Update the state after the data is added to the Google Sheet
      setState(() {});
    });
  }

  void _deleteTransaction(int index) async {
    await GoogleSheetsApi.deleteRow(index + 2);
    setState(() {});
  }

  // new transaction
  void _newTransaction() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Center(child: Text('บันทึกรายรับ-รายจ่าย')),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('รายจ่าย'),
                          Switch(
                            value: _isIncome,
                            onChanged: (newValue) {
                              setState(() {
                                _isIncome = newValue;
                              });
                            },
                          ),
                          Text('รายรับ'),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'จำนวนเงิน',
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'กรุณากรอกจำนวนเงิน';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                controller: _textcontrollerAMOUNT,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'หมายเหตุ?',
                              ),
                              controller: _textcontrollerITEM,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  MaterialButton(
                    color: Colors.grey[600],
                    child:
                        Text('ยกเลิก', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  MaterialButton(
                    color: Colors.grey[600],
                    child: Text('ตกลง', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _enterTransaction();
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
              );
            },
          );
        });
  }

  // wait for the data to be fetched from google sheets
  void startLoading() {
    timerHasStarted = true;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (GoogleSheetsApi.loading == false) {
        setState(() {});
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // start loading until the data arrives
    if (GoogleSheetsApi.loading == true && timerHasStarted == false) {
      startLoading();
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            TopNeuCard(
              balance: (GoogleSheetsApi.calculateIncome() -
                      GoogleSheetsApi.calculateExpense())
                  .toString(),
              income: GoogleSheetsApi.calculateIncome().toString(),
              expense: GoogleSheetsApi.calculateExpense().toString(),
            ),
            // ...
            Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '${_selectedDate != null ? DateFormat('dd-MM-yyyy').format(_selectedDate!) : ''}',
                        style: TextStyle(fontSize: 20, color: Colors.red)),
                    // Add the following code to display the selected date's income and expense
                    if (_selectedDate != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'รายรับ: ${NumberFormat('#,###').format(_calculateSelectedDateIncome())} ฿',
                            style: TextStyle(fontSize: 18, color: Colors.green),
                          ),
                          Text(
                            'รายจ่าย: ${NumberFormat('#,###').format(_calculateSelectedDateExpense())} ฿',
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          ),
                        ],
                      ),
                  ],
                )),
// ...

            Expanded(
              child: GoogleSheetsApi.loading == true
                  ? LoadingCircle()
                  : ListView.builder(
                      itemCount: GoogleSheetsApi.currentTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction =
                            GoogleSheetsApi.currentTransactions[index];

                        // Check if the transaction has at least 4 elements
                        if (transaction.length < 4) {
                          return SizedBox.shrink();
                        }

                        final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                        final transactionDate =
                            dateFormat.parse(transaction[3]);
                        final transactionDateOnly = DateTime(
                            transactionDate.year,
                            transactionDate.month,
                            transactionDate.day);

                        // กรองรายการที่มีวันที่ตรงกับวันที่ที่เลือก
                        if (_selectedDate == null ||
                            transactionDateOnly == _selectedDate) {
                          // เปลี่ยนแปลงรูปแบบวันที่เป็นรูปแบบสั้นก่อนส่งค่าให้กับ MyTransaction
                          final shortDateFormat = DateFormat('dd-MM-yyyy');
                          final transactionDateFormatted =
                              shortDateFormat.format(transactionDate);

                          return MyTransaction(
                            transactionName: transaction[0],
                            money: transaction[1],
                            expenseOrIncome: transaction[2],
                            onDelete: () => _deleteTransaction(index),
                            transactionDate: transactionDateFormatted,
                            // ...
                            onEdit: () async {
                              // Convert transaction from List<dynamic> to List<String>
                              List<String> transactionStrings = transaction
                                  .map((dynamic value) => value.toString())
                                  .toList();

                              // Display the edit transaction dialog
                              final bool? updated = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return EditTransactionDialog(
                                    transaction: transactionStrings,
                                    rowIndex: index,
                                  );
                                },
                              );

                              if (updated != null && updated) {
                                // Update the UI, for example by calling a function that fetches transactions and updates the state
                                _fetchAndUpdateTransactions();
                              }
                            },
                            // ...
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PlusButton(
                //   function: _newTransaction,
                // ),
                Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add),
                        color: Colors.white,
                        onPressed: () {
                          _newTransaction(); // เพิ่มวงเล็บ () เพื่อเรียกใช้ฟังก์ชั่น
                        },
                      ),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        color: Colors.white,
                        onPressed: () {
                          _selectDate(context);
                        },
                      ),
                      Text(
                        'Calendar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.clear),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                      ),
                      Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyTransaction extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onEdit; // Add this line

  final String transactionName;
  final String money;
  final String expenseOrIncome;
  final String transactionDate; // Add this line

  MyTransaction({
    required this.transactionName,
    required this.money,
    required this.expenseOrIncome,
    required this.onDelete, // Add this line
    required this.transactionDate, // Add this line
    required this.onEdit, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(15),
          color: Colors.grey[100],
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: onDelete,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: onEdit,
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.grey[500]),
                        child: Center(
                          child: Icon(
                            Icons.attach_money_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transactionName,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              )),
                          // Add transaction date display
                          Text(
                            'รายการ: ' + transactionDate,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    (expenseOrIncome == 'expense' ? '-' : '+') +
                        NumberFormat('#,###').format(int.parse(money)) +
                        ' ฿',
                    style: TextStyle(
                      fontSize: 16,
                      color: expenseOrIncome == 'expense'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

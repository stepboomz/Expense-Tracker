import 'package:expensetracker/google_sheets_api.dart';
import 'package:flutter/material.dart';

class EditTransactionDialog extends StatefulWidget {
  final List<String> transaction;
  final int rowIndex;

  EditTransactionDialog({
    required this.transaction,
    required this.rowIndex,
  });

  @override
  _EditTransactionDialogState createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  TextEditingController _transactionNameController = TextEditingController();
  TextEditingController _moneyController = TextEditingController();
  String _expenseOrIncome = 'expense';

  @override
  void initState() {
    super.initState();
    _transactionNameController.text = widget.transaction[0];
    _moneyController.text = widget.transaction[1];
    _expenseOrIncome = widget.transaction[2];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Transaction'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _transactionNameController,
              decoration: InputDecoration(labelText: 'Transaction Name'),
            ),
            TextField(
              controller: _moneyController,
              decoration: InputDecoration(labelText: 'Money'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _expenseOrIncome,
              onChanged: (String? newValue) {
                setState(() {
                  _expenseOrIncome = newValue!;
                });
              },
              items: <String>['expense', 'income']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Update transaction data with new values
            await GoogleSheetsApi.updateTransaction(
              transactionName: _transactionNameController.text,
              money: _moneyController.text,
              expenseOrIncome: _expenseOrIncome,
              rowIndex: widget.rowIndex,
            );

            Navigator.of(context).pop(
                true); // Return true to indicate that the transaction has been updated
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

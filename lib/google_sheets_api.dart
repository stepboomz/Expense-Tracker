import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
  {

  }
  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  static Future<void> updateTransaction({
    required String transactionName,
    required String money,
    required String expenseOrIncome,
    required int rowIndex,
  }) async {
    if (_worksheet == null) return;

    // Update the transaction in currentTransactions
    currentTransactions[rowIndex] = [
      transactionName,
      money,
      expenseOrIncome,
      currentTransactions[rowIndex][3], // Keep the original date
    ];

    await _worksheet!.values.insertValue(
      transactionName,
      column: 1,
      row: rowIndex + 2,
    );
    await _worksheet!.values.insertValue(
      money,
      column: 2,
      row: rowIndex + 2,
    );
    await _worksheet!.values.insertValue(
      expenseOrIncome,
      column: 3,
      row: rowIndex + 2,
    );
  }

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  static Future<void> deleteRow(int rowIndex) async {
    try {
      // Ensure the worksheet is initialized
      if (_worksheet == null) return;

      // Delete the row
      await _worksheet!.deleteRow(rowIndex);

      // Update the transactions list in the app
      await fetchAndUpdateTransactions();
    } catch (e) {
      print('Error in deleting row: $e');
    }
  }

  // dateFormat.format(getDateFromExcelValue(double.parse(row[3]))),

  static Future fetchAndUpdateTransactions() async {
    if (_worksheet == null) return;

    // Clear the current transactions list
    currentTransactions.clear();

    // Fetch the latest transactions
    final values = await _worksheet!.values.allRows(fromRow: 2);

    // Update the current transactions list
    numberOfTransactions = values.length;
    currentTransactions.addAll(values
        .map((row) => [
              row[0],
              row[1],
              row[2],
              dateFormat.format(getDateFromExcelValue(double.parse(row[3]))),
            ])
        .toList());
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing transactions from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);
      final DateTime transactionDate = getDateFromExcelValue(
          double.parse(await _worksheet!.values.value(column: 4, row: i + 1)));

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
          dateFormat.format(transactionDate), // Convert DateTime to String
        ]);
      }
    }
    // Sort the transactions in descending order by date
    currentTransactions.sort((a, b) {
      DateTime dateA = DateFormat("yyyy-MM-dd HH:mm:ss").parse(a[3]);
      DateTime dateB = DateFormat("yyyy-MM-dd HH:mm:ss").parse(b[3]);
      return dateB.compareTo(dateA);
    });

    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);

    // Add the current date to the new transaction
    String currentDate =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
      currentDate,
    ]);

    // Fetch and update transactions after inserting a new one
    await fetchAndUpdateTransactions();
    // Sort the transactions in descending order by date
    currentTransactions.sort((a, b) {
      DateTime dateA = DateFormat("yyyy-MM-dd HH:mm:ss").parse(a[3]);
      DateTime dateB = DateFormat("yyyy-MM-dd HH:mm:ss").parse(b[3]);
      return dateB.compareTo(dateA);
    });
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  static DateTime getDate(String dateAsString) {
    return DateTime.parse(dateAsString);
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}

DateTime getDateFromExcelValue(double excelValue) {
  final DateTime baseDate = DateTime(1899, 12, 30); // Excel epoch
  return baseDate.add(Duration(days: excelValue.floor()));
}

final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

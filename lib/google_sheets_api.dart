import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "gsheet-385709",
  "private_key_id": "e4538d27d407a5f1ccb15f2e7e3dc6b39428491d",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCka+zOD5juNd8j\nRlx4/LMvdhAnVL3oo2ceicXvZZXiLP7HxEwfZh1v0mmpW5vHTuK5t1ds11g2vs+T\nTgLFGHxlN1EJgXb9eCmlqy+zM46iSYLm4RTBu9+wHUKE66K4YgDLzYnPxN3Ob4MD\nKuAvii6OjyM5oyw2lcrpUsPBRDAYhshT/4jSRKY0iLZMctVJ3C1JuxUTfrf+Cvjw\n6srNyZVGFXTqnh46b8djPEw9fqfFOX+USpRBhLcfwLju9fLMgw5nAIRGorYXXfzw\nhDs+z2ac3+Cvxw1ItX61M645cxXn/7zyqxRtnAj/HDhHEvyaV70n8/rzwvUvpRbx\nkE4DiBJZAgMBAAECggEACO7GHEHTrKlnmIqDjp0n/P2cjg54DNIH0axpgQKTXIjW\nRLMg8ZnCIqebTvSnp3HdNnrD+KlQZRUDwPx9gQi+BV+2et46QTYMiTAeNM2pw55b\nysBSuN3EntRQH1mP6xWD9o6RnKSU6li7lOn46QxIUD1ti/2V8tc7gWaaNP9H36Uo\nl5O57ZilNO7bknO50oha/cfzWVEBetZqjOgRLEUgdEIHgd+PW/ii+v/bZR1Loo3F\nskvx0mVQ3oVBNcjUuDxuILK6UB0c/PZvFskwDSPVVxmeAnz7oPh/Wp8UZ4ftsekj\naYbwQEJwwLzRcFGyGZ9d37EhD6rZMPI3pDPsN8Ic8wKBgQDbzkeixWzbP1vYGYXs\nmjqULpdV+OBZFpAOuChECHdqFAJV2O/UF3ZxGYxiSl7rFrGKpNogqciQrKvenNrO\nSMojQmfbaF6l7lFVI2rP6Rewsd+qC7w52s6sZC8Y9EzZJNz0yzUHealzUC46Tzzy\nyIe1W5wKFt9R099hcWd7XWrlywKBgQC/fvkKKB+ryI6CADbpBuey6Ia1IGrC20O9\nXm1RuGSz6/kuram+QL2p3KBkHCEV0AsMZ9yUpGpYSbrjqjdvW44vCxULvfzyWjLd\n2qsi6HAZgRhdK+8QZ2K3xt3mJlD3NeZ4cOrwpWIQlWZpcuIflRhvHURLQXvcUWze\nxueLGGlD6wKBgH7qZ6CLoCQkPFLVwedw0hwXnthMQLYP+hQVr2JBBTph3UtWXHw5\nI/GAD/f8+zuAufjU4QH1JtKqcP6z0P9FNjoPsMoWRHhI1/tx3M25yC0FN6EG76L0\nPVt66VreTLUgvNg3sSHk1Lu5c0fF0upYcUt9XubQeBfWX2fzRA4OTZfrAoGATdLC\nTxhjVqLZF4gSyL0fqJvLMw0LlkkZzHn1n4J6moxJ5mh5VXJmIgQhws2TvJOiCdaj\n1FzFQ0AjjaZ9hOoGbKPqV61MgQmbJoJZjoQ8GoFWb3cNXvNFMT7Gq2Pi/7SOB2CM\nemQb6HVu+2fO8drb5TxVpufj+HO29QqMywCOtyUCgYEAgSD3f9BlARWPKTFY1nsm\nxoD4FWSjKmkCPQcfDs5TT2jc7eUm/3T2B4eB3R84xxojeAclUp5a1eZ0Cc7Of9w/\nvkiK9c0ZXYfhtvfoO5R0l3q1gFBbdjXlDOhuP+eTgm1VNPoWgtssHCsKe5TBsYzy\nv9g4aJhKrFmaBjfttWRfXsU=\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheet1@gsheet-385709.iam.gserviceaccount.com",
  "client_id": "103349950621407021825",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheet1%40gsheet-385709.iam.gserviceaccount.com"
  }
  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '15-w35FztEx6iIHUo7kW75VqYrJbjcYp2MpP8ivc6keg';
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

  // load existing notes from the spreadsheet
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

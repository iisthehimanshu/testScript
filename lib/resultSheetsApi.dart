import 'package:gsheets/gsheets.dart';

class resultSheetsApi{
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "iwayplus-401806",
  "private_key_id": "3dc2023f2377c5fc08488f92add0c6a11c92ff86",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCss8IJmwyO8+Ff\nNqHEKeCjwhhOBrJFldDxHb5r9KTvxpk71IwcRzuw02jMG0OiXqV/VO41n71Rb87H\nuGgLBjKs3ZLUOOxbM6HndINp2CofySM/4JyL3x+Sj1lBHVfYgdn2EoA2VFNNj6c8\nBsFMvtqtr7yCJDAtKJvmgTT2Dfn4DQlM+YWDqZoGGOyv6UALzJfLdvCusZduxoDI\naUcIk0E/a3ntNXTlrpkhuNZ5rhUoJnBvqL18BdJnXk1l4fhdaPQdod9hffgzmL05\nz8cN0OkxBF5LHWPZUzmfm9vM/pRD4O/8gXEWedpC36JNEwL/Om/HMJJz/anw/9uC\nLCx836I5AgMBAAECggEAHFGrpzyT/hryoVTJiOufCOtKZf0GHY/3/5mzgGtQ4nqL\n5Pow8XAi0xePjyyHVigz9iG8n/FuL1zoqOpNsUUWaS86JO+inj/ktBnwdJo8KhMm\n4xIXSX5QZI16AsnnfjqovYeCG6aPNGAyeY7YApgnLqTrAeIiPj1y9wTH5PMcwrZH\nWByc1kDAYBnN3VZZmO/e3CX+n//IWO8ReZPkr3Z9Cc6n97uFecCGc27chfOobMa5\nVaFDrDvJVgtsEnGU5EZ1gUJ9nVp7Tm4faKcpt9mRbJkW5wHDpRoeFJxMIkxOYlWo\nJBLtDKSJxT016ExqRmaV8M8wA5mKdgHvFFANnDDDOwKBgQDkNghmLlV75bE+kiqm\n5PL9GWSkSdILF8ohd8UV4tpNbi3TYkMPxcWpLTAzWdqXKUL9bwB6wrjUoNJkJzRi\n0O3rhi2x0kShd4RIjZz6bY8b+3ovi6h6IYORSCIyOsH0EZG9s//XO0X5wEItXtWe\nHn5GMRvMYQAaB01buBBpMpt00wKBgQDBu1w/9dlcgdr3VC8V/peTSV3at4x2NEqg\n+d+6YzzmnPKR5FmY/WqCu9GXnGjMNDKqalP443RIl3f7QdrHIxXCw9Vx62llMlIW\nGxY3YffmbrAPIlk6gChLN5rN8di/uKCJRk0YUvbV/4xoqYfDgIjLcgMUEk9sjGPf\noViqNkJVQwKBgEh0/2WyAGI+I3CCaBhlSOEjVtjyt0XeX8cQh/rS9Azxlosu/6va\nV0/HkS48sTKdXy+oNrbDbHvWM/aom/Fj9KZ7C7cR08iQcee3TsgUUQPJbJn79ZoR\nWfyesnzQOxSLH4Ljy69Cmo0Zhelx2tFBTUZsAS96/NVGzED6x/senk0RAoGAT1jH\nrcKp5gOhhU9LgbympEKWWDB5LSi5sDjnc1WV6fY6O5rFP637Y9Q9QdVj7s8qOTYX\ncobmZ5zyHUyZqJosHXtL/r6mijYT/M3XSZOsjwqivXAaD6XR2wzJMLRvTAb4aYEL\nrny8cGWcQnm9C0unu3vU2vGs6g6OEVfqErzqajUCgYASkCrFgkvL+814LowbhgUM\nfeg/sMOBaUujj5eWhYOyMAMeVz/VsCTbaFdKoXpFryb8PdEKF5MR2E+9FtfhUDu8\nfbYOWhX/JyDSFk3Q3nC/TTD7FuIaTvi9F9rJ/AsIx75Qinn/2up6WaVbFZQMaTjE\nRUHykg5pbOHbhlgvFwQSFQ==\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets@iwayplus-401806.iam.gserviceaccount.com",
  "client_id": "102177461265904694678",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40iwayplus-401806.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''';
  static final _spreadsheetId = "17Np1AwaV7XthXmVu44awUI9Peq55gzrGY11ZJybg9mo";
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _resultSheet1;
  static Worksheet? _resultSheet2;
  static Worksheet? _liftScript;
  static Worksheet? _entriesScript;

  static Future init() async{
    try {
      final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
      _resultSheet1 = await _getWorkSheet(spreadsheet, title: 'Sheet1');
      _resultSheet2 = await _getWorkSheet(spreadsheet, title: 'Sheet2');
      _liftScript = await _getWorkSheet(spreadsheet, title: 'liftScript');
      _entriesScript = await _getWorkSheet(spreadsheet, title: 'entriesScript');
      await _resultSheet1!.clear();
      await _resultSheet2!.clear();
      await _liftScript!.clear();
      await _entriesScript!.clear();
    }catch(e){
      print("init error $e");
    }
  }

  static addRowsSheet1(List<List<dynamic>> rows){
    _resultSheet1!.values.appendRows(rows);
  }
  static addRowsSheet2(List<List<dynamic>> rows){
    _resultSheet2!.values.appendRows(rows);
  }
  static addRowsLiftScript(List<List<dynamic>> rows){
    _liftScript!.values.appendRows(rows);
  }
  static addRowsEntriesScript(List<List<dynamic>> rows){
    _entriesScript!.values.appendRows(rows);
  }
  static Future<Worksheet?> _getWorkSheet(Spreadsheet spreadsheet,{required String title})async{
    try {
      return await spreadsheet.addWorksheet(title);
    }catch(e){
      return spreadsheet.worksheetByTitle(title);
    }
  }
}
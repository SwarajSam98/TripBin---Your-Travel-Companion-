import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;


class ExcelLoader {
  static Future<List<Map<String, String>>> loadCitiesFromAssets() async {
    // Load the Excel file from the assets
    final ByteData data = await rootBundle.load('lib/assets/cities.xlsx');
    final List<int> bytes = data.buffer.asUint8List();

    // Read the Excel file
    var excel = Excel.decodeBytes(bytes);
    List<Map<String, String>> cities = [];

    // Iterate through all the sheets in the Excel file
    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]?.rows;

      // Skip the first row (headers)
      for (var row in rows!.skip(1)) {
        if (row.length > 1) {
          cities.add({
            'city': (row[0] as String?) ?? '', // City is the first column
            'country': (row[1] as String?) ?? '', // Country is the second column
          });
        }
      }
    }
    print("Cities loaded: ${cities.length}"); // Print the number of cities loade
    return cities;
  }
}

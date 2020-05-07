import 'package:fit_kit/fit_kit.dart';

class FitKitData {
  String result = '';
  Map<DataType, List<FitData>> results = Map();
  bool permissions;
  List<DataType> types = [DataType.STEP_COUNT];

  int limit = 99999;
  DateTime dateFrom;
  DateTime dateTo;

  FitKitData({this.dateFrom, this.dateTo});

  Future<List<FitData>> read() async {
    results.clear();

    try {
      permissions = await FitKit.requestPermissions(types);
      if (!permissions) {
        result = 'requestPermissions: failed';
      } else {
        for (DataType type in types) {
          results[type] = await FitKit.read(
            type,
            dateFrom: dateFrom ?? DateTime.now().subtract(Duration(days: 30)),
            dateTo: dateTo ?? DateTime.now(),
            limit: limit,
          );
        }

        result = 'readAll: success';
        return results[DataType.STEP_COUNT].toList();
      }
    } catch (e) {
      result = 'readAll: $e';
    }
    return null;
  }

  Future<void> revokePermissions() async {
    results.clear();

    try {
      await FitKit.revokePermissions();
      permissions = await FitKit.hasPermissions(types);
      result = 'revokePermissions: success';
    } catch (e) {
      result = 'revokePermissions: $e';
    }
  }

  Future<void> hasPermissions() async {
    try {
      permissions = await FitKit.hasPermissions(types);
    } catch (e) {
      result = 'hasPermissions: $e';
    }
  }
}

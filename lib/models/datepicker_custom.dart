import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class DatePickerModelCustom extends CommonPickerModel {
  DateTime maxTime;
  DateTime minTime;

  List<int> _leapYearMonths = const <int>[1, 3, 5, 7, 8, 10, 12];

  int calcDateCount(int year, int month) {
    if (_leapYearMonths.contains(month)) {
      return 31;
    } else if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29;
      }
      return 28;
    }
    return 30;
  }

  DatePickerModelCustom(
      {DateTime currentTime,
      DateTime maxTime,
      DateTime minTime,
      LocaleType locale})
      : super(locale: locale) {
    this.maxTime = maxTime ?? DateTime(2049, 12, 31);
    this.minTime = minTime ?? DateTime(1970, 1, 1);

    currentTime = currentTime ?? DateTime.now();
    if (currentTime != null) {
      if (currentTime.compareTo(this.maxTime) > 0) {
        currentTime = this.maxTime;
      } else if (currentTime.compareTo(this.minTime) < 0) {
        currentTime = this.minTime;
      }
    }
    this.currentTime = currentTime;

    _fillLeftLists();
    _fillMiddleLists();
    _fillRightLists();
    int minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    this.setLeftIndex(this.currentTime.day - minDay);
    this.setRightIndex(this.currentTime.year - this.minTime.year);
    this.setMiddleIndex(this.currentTime.month - minMonth);
  }

  void _fillRightLists() {
    this.leftList = List.generate(maxTime.year - minTime.year + 1, (int index) {
      // print('LEFT LIST... ${minTime.year + index}${_localeYear()}');
      return '${minTime.year + index}${_localeYear()}';
    });
  }

  int _maxMonthOfCurrentYear() {
    return currentTime.year == maxTime.year ? maxTime.month : 12;
  }

  int _minMonthOfCurrentYear() {
    return currentTime.year == minTime.year ? minTime.month : 1;
  }

  int _maxDayOfCurrentMonth() {
    int dayCount = calcDateCount(currentTime.year, currentTime.month);
    return currentTime.year == maxTime.year &&
            currentTime.month == maxTime.month
        ? maxTime.day
        : dayCount;
  }

  int _minDayOfCurrentMonth() {
    return currentTime.year == minTime.year &&
            currentTime.month == minTime.month
        ? minTime.day
        : 1;
  }

  void _fillMiddleLists() {
    int minMonth = _minMonthOfCurrentYear();
    int maxMonth = _maxMonthOfCurrentYear();

    this.middleList = List.generate(maxMonth - minMonth + 1, (int index) {
      return '${_localeMonth(minMonth + index)}';
    });
  }

  void _fillLeftLists() {
    int maxDay = _maxDayOfCurrentMonth();
    int minDay = _minDayOfCurrentMonth();
    this.rightList = List.generate(maxDay - minDay + 1, (int index) {
      return '${minDay + index}${_localeDay()}';
    });
  }

  @override
  void setRightIndex(int index) {
    super.setRightIndex(index);
    //adjust middle
    int destYear = index + minTime.year;
    int minMonth = _minMonthOfCurrentYear();
    DateTime newTime;
    //change date time
    if (currentTime.month == 2 && currentTime.day == 29) {
      newTime = currentTime.isUtc
          ? DateTime.utc(
              destYear,
              currentTime.month,
              calcDateCount(destYear, 2),
            )
          : DateTime(
              destYear,
              currentTime.month,
              calcDateCount(destYear, 2),
            );
    } else {
      newTime = currentTime.isUtc
          ? DateTime.utc(
              destYear,
              currentTime.month,
              currentTime.day,
            )
          : DateTime(
              destYear,
              currentTime.month,
              currentTime.day,
            );
    }
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillMiddleLists();
    _fillLeftLists();
    minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    this.setMiddleIndex(currentTime.month - minMonth);
    this.setLeftIndex(currentTime.day - minDay);
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    //adjust right
    int minMonth = _minMonthOfCurrentYear();
    int destMonth = minMonth + index;
    DateTime newTime;
    //change date time
    int dayCount = calcDateCount(currentTime.year, destMonth);
    newTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          )
        : DateTime(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          );
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillLeftLists();
    int minDay = _minDayOfCurrentMonth();
    this.setLeftIndex(currentTime.day - minDay);
  }

  @override
  void setLeftIndex(int index) {
    super.setLeftIndex(index);
    int minDay = _minDayOfCurrentMonth();
    currentTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            minDay + index,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            minDay + index,
          );
  }

  @override
  String rightStringAtIndex(int index) {
    if (index >= 0 && index < leftList.length) {
      return leftList[index];
    } else {
      return null;
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 0 && index < middleList.length) {
      return middleList[index];
    } else {
      return null;
    }
  }

  @override
  String leftStringAtIndex(int index) {
    if (index >= 0 && index < rightList.length) {
      return rightList[index];
    } else {
      return null;
    }
  }

  String _localeYear() {
    if (locale == LocaleType.zh) {
      return '年';
    } else if (locale == LocaleType.ko) {
      return '년';
    } else {
      return '';
    }
  }

  String _localeMonth(int month) {
    if (locale == LocaleType.zh) {
      return '$month月';
    } else if (locale == LocaleType.ko) {
      return '$month월';
    } else {
      List monthStrings = i18nObjInLocale(locale)['monthLong'];
      return monthStrings[month - 1];
    }
  }

  String _localeDay() {
    if (locale == LocaleType.zh) {
      return '日';
    } else if (locale == LocaleType.ko) {
      return '일';
    } else {
      return '';
    }
  }

  @override
  DateTime finalTime() {
    return currentTime;
  }
}

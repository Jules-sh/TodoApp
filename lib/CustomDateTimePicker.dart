import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CustomDateTimePicker extends TimePickerModel {
  CustomDateTimePicker()
      : super(showSecondsColumn: false, locale: LocaleType.de);
  // add Translation (if possible)
  //@override
  //String rightDivider() => "";

  //@override
  //List<int> layoutProportions() => [100, 100, 0];
}

import 'package:tmiui/models.dart/tmi_datetime.dart';

class BaseTable {
  TmiDateTime createdOn, updatedOn;
  String createdBy, updatedBy;
  BaseTable(this.createdBy, this.updatedBy, this.createdOn, this.updatedOn);
}

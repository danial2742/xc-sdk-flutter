import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'form_models.g.dart';

class FormModel {
  FormModel({
    required this.faName,
    required this.faFields,
    this.faEf,
    this.faVid,
    this.faSt,
    this.faHt,
    this.faTs,
    required this.faSu,
  }) : faId = const Uuid().v4();

  Map<String, String> toJson() => _formModelToJson(this);

  /// Form fields
  final List<FormFieldModel> faFields;

  /// View ID
  final String? faVid;

  /// Form name
  final String faName;

  /// ID
  final String? faId;

  /// Entry field
  final String? faEf;

  /// Start
  final String? faSt;

  /// Hesitation time
  final String? faHt;

  /// Time spent
  final String? faTs;

  /// Form submit status
  final bool faSu;

  Map<String, String> _formModelToJson(FormModel instance) {
    final val = <String, String>{
      'fa_name': faName,
      'fa_fields': json.encode(FormFieldModel.toJsonList(instance.faFields)),
      'fa_su': faSu ? '1' : '0',
    };

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('fa_vid', instance.faVid);
    writeNotNull('fa_id', instance.faId);
    writeNotNull('fa_ef', instance.faEf);
    writeNotNull('fa_st', instance.faSt);
    writeNotNull('fa_ht', instance.faHt);
    writeNotNull('fa_ts', instance.faTs);
    return val;
  }
}

@JsonSerializable(
  createFactory: false,
  includeIfNull: false,
  fieldRename: FieldRename.snake,
)
class FormFieldModel {
  FormFieldModel({
    required this.id,
    required this.trackContent,
    required this.controller,
    required this.node,
    required this.faFt,
    required this.faFn,
    this.faCn,
    this.faFts,
    this.faFht,
    this.faFb,
    this.faFch = 0,
    this.faFf = 0,
    this.faFd = 0,
    this.faFcu = 0,
    this.faFs,
  });

  static List<Map<String, dynamic>> toJsonList(List<FormFieldModel> models) =>
      models.map((e) => e.toJson()).toList();

  Map<String, dynamic> toJson() => _$FormFieldModelToJson(this);

  @JsonKey(includeToJson: false)
  final String id;

  /// Form field Name
  String faFn;

  /// Content value
  String? faCn;

  /// Total time spent
  int? faFts;

  /// Hesitation time
  int? faFht;

  /// Left blank
  bool? faFb;

  /// Number of changes
  int faFch;

  /// Number of focus
  int faFf;

  /// Number of deletes
  int faFd;

  /// Number of cursor
  int faFcu;

  /// Type
  String faFt;

  /// Size
  int? faFs;

  /// To check whether the user allows to send content or not
  @JsonKey(includeToJson: false)
  late final bool trackContent;

  /// To calculate [faFf]
  @JsonKey(includeToJson: false)
  late final FocusNode node;

  /// To calculate TextEditingController related fields such as: [faCh], [faFht], [faFb], [faFch], [faFd], [faFs]
  @JsonKey(includeToJson: false)
  late final TextEditingController controller;
}

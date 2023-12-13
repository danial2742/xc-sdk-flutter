// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$FormFieldModelToJson(FormFieldModel instance) {
  final val = <String, dynamic>{
    'fa_fn': instance.faFn,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('fa_cn', instance.faCn);
  writeNotNull('fa_fts', instance.faFts);
  writeNotNull('fa_fht', instance.faFht);
  writeNotNull('fa_fb', instance.faFb);
  writeNotNull('fa_fch', instance.faFch);
  writeNotNull('fa_ff', instance.faFf);
  writeNotNull('fa_fd', instance.faFd);
  writeNotNull('fa_fcu', instance.faFcu);
  writeNotNull('fa_ft', instance.faFt);
  writeNotNull('fa_fs', instance.faFs);
  return val;
}

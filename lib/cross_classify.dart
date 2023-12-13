import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_classify_sdk/models/form_models.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:uuid/uuid.dart';
export 'package:matomo_tracker/matomo_tracker.dart';
import 'package:crypto/crypto.dart';

RouteObserver<ModalRoute<void>> get crossClassifyObserver => matomoObserver;

class CrossClassify {
  CrossClassify._();
  static final instance = CrossClassify._();

  final _baseUrl = 'https://api.crossclassify.com/collect';
  final _matomoEndpoint = '/matomo.php';

  bool _initialized = false;
  bool get initialized => _initialized;

  final List<FormFieldModel> _formFields = [];
  final _formInterval = const Duration(seconds: 30);
  Timer? _timer;
  late final DateTime _startTime;
  late final String _formName;
  late final PerformanceInfo? _performanceInfo;
  late final String _pageViewId;
  Duration? _formHesitationTime;

  Future<void> initialize({required String apiKey, required int siteId}) async {
    if (apiKey.startsWith('#') || siteId == -1) {
      throw Exception('Please provide your own API key and site ID!');
    }
    if (_initialized) {
      //TODO handle all exptions properly
      throw Exception('Already Initialized!');
    }

    await MatomoTracker.instance.initialize(
        siteId: siteId,
        url: _baseUrl + _matomoEndpoint,
        customHeaders: {'x-api-key': apiKey},
        verbosityLevel: kDebugMode ? Level.all : Level.off,
        uid: await _getUid());

    _initialized = true;
  }

  void initForm({
    required String pvId,
    required String formName,
    required PerformanceInfo? performanceInfo,
  }) {
    _checkServiceInitialization();
    _startTime = DateTime.now();
    _pageViewId = pvId;
    _formName = formName;
    _performanceInfo = performanceInfo;
  }

  Future<String> _getUid() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (kIsWeb == false) {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        final fingerprint = sha256.convert(utf8.encode(
          androidInfo.board +
              androidInfo.brand +
              androidInfo.device +
              androidInfo.hardware +
              androidInfo.manufacturer +
              androidInfo.product +
              androidInfo.display +
              androidInfo.host +
              androidInfo.model +
              androidInfo.id +
              androidInfo.brand +
              androidInfo.serialNumber +
              androidInfo.displayMetrics.heightPx.toString() +
              androidInfo.displayMetrics.widthPx.toString(),
        ));
        debugPrint('Fingerprint: ${fingerprint.toString()}');
        return fingerprint.toString();
      } else if (Platform.isIOS) {
        final id = (await deviceInfoPlugin.iosInfo).identifierForVendor;
        if (id == null) {
          throw Exception('Failed to get the IOS identifier');
        }
        return id;
      }
    }
    return (await deviceInfoPlugin.webBrowserInfo).userAgent!;
  }

  void _checkServiceInitialization() {
    if (_initialized == false) {
      throw Exception('''The Cross Classify service has not been started yet!
          Call CrossClassify.instance.initialize to initialize the service.''');
    }
  }

  void _setDispatchTimer() {
    _timer = Timer.periodic(_formInterval, (timer) {
      _trackForm();
    });
  }

  void addFormField(FormFieldConfig config) {
    _checkServiceInitialization();
    final formField = FormFieldModel(
      id: config.id,
      trackContent: config.trackContent,
      controller: config.controller,
      node: config.node,
      faFt: config.formFieldType,
      faFn: config.formFieldType,
    );
    if (_formFields.isEmpty) {
      _setDispatchTimer();
      _subscribeFormHesitationTime(formField);
    }

    _registerFocusNode(formField);
    _registerTextController(formField);
    _formFields.add(formField);
  }

  void _registerTextController(FormFieldModel formField) {
    return formField.controller.addListener(() {
      final text = formField.controller.text;
      if (formField.faCn != text) {
        formField.faFts = _timeSinceStart().inMilliseconds;
        formField.faFch++;
      }
      if (formField.faFht == null && text.isNotEmpty) {
        formField.faFht = _timeSinceStart().inMilliseconds;
      }
      if (formField.faCn != null && formField.faCn!.length > text.length) {
        formField.faFd++;
      }
      formField.faCn = text;
    });
  }

  void _registerFocusNode(FormFieldModel formField) {
    formField.node.addListener(() {
      if (formField.node.hasFocus) {
        formField.faFf++;
        formField.faFcu++;
      }
    });
  }

  void _subscribeFormHesitationTime(FormFieldModel formField) {
    formField.controller.addListener(() {
      if (_formHesitationTime == null && formField.controller.text.isNotEmpty) {
        _formHesitationTime = _timeSinceStart();
        formField.faFht = _formHesitationTime!.inMilliseconds;
      }
    });
  }

  void _disposeNodeController(int index) {
    _formFields[index].controller.dispose();
    _formFields[index].node.dispose();
  }

  void removeFormField(String id) {
    final index = _formFields.indexWhere((element) => element.id == id);
    if (_formFields.isEmpty) {
      _disposeDispatchTimer();
    }
    _formFields[index].controller.clear();
    _formFields.removeAt(index);
  }

  void onFormSubmit() {
    _trackForm(isSubmitted: true);
    _disposeDispatchTimer();
  }

  void _disposeDispatchTimer() {
    _timer?.cancel();
  }

  void _calculateFieldsContentData() {
    for (var field in _formFields) {
      final text = field.controller.text;
      if (field.trackContent) {
        field.faCn = text;
      } else if (field.faFt.toLowerCase() != 'email') {
        field.faCn = null;
      }
      if (text.isEmpty) {
        field.faFb = true;
      } else {
        field.faFb = false;
      }
      field.faFs = text.length;
    }
  }

  void _trackForm({bool isSubmitted = false}) {
    _calculateFieldsContentData();
    final FormModel formModel = FormModel(
      faName: _formName,
      faSt: _startTime.millisecondsSinceEpoch.toString(),
      faVid: _pageViewId,
      faTs: _getTimeSpent(),
      faHt: _formHesitationTime?.inMilliseconds.toString(),
      faFields: _formFields,
      faSu: isSubmitted,
    );
    // for (final fields in _formFields) {
    //   debugPrint('type: ${fields.faFt} - content: ${fields.faCn}');
    //   debugPrint('node changes: ${fields.faFf}');
    //   debugPrint('changes: ${fields.faFch}');
    //   debugPrint('Left blank: ${fields.faFb}');
    //   debugPrint('deletes: ${fields.faFd}');
    //   debugPrint('field hesitation time: ${fields.faFht}');
    //   debugPrint('field spent time: ${fields.faFts}');
    // }
    MatomoTracker.instance.trackCustomAction(
        actionName: _formName,
        pvId: _pageViewId,
        performanceInfo: _performanceInfo,
        customActions: formModel.toJson());
  }

  String _getTimeSpent() =>
      (DateTime.now().difference(_startTime)).inMilliseconds.toString();

  Duration _timeSinceStart() {
    return DateTime.now().difference(_startTime);
  }

  void dispose() {
    _disposeDispatchTimer();
    for (var i = 0; i < _formFields.length; i++) {
      _disposeNodeController(i);
    }
  }
}

class FormFieldConfig {
  FormFieldConfig({
    required this.formFieldType,
    required this.trackContent,
    required this.controller,
    required this.node,
  }) : id = const Uuid().v4();
  final String id;
  final String formFieldType;
  final bool trackContent;
  TextEditingController controller;
  final FocusNode node;
}

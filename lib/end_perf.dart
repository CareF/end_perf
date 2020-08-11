// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:e2e/e2e.dart';

/// Usually it's recommended to limit callbacks of the test to [WidgetController]
/// API so it can be more universally used.
typedef ControlCallback = Future<void> Function(WidgetController controller);

bool _firstRun = true;

/// watches the [FrameTiming] of `action` and report it to the e2e binding.
Future<void> watchPerformance(
  E2EWidgetsFlutterBinding binding,
  Future<void> action(),{
  String reportKey = 'performance',
}) async {
  assert(() {
    if (_firstRun) {
      debugPrint(kDebugWarning);
      _firstRun = false;
    }
    return true;
  }());
  final List<FrameTiming> frameTimings = <FrameTiming>[];
  final TimingsCallback watcher = frameTimings.addAll;
  binding.addTimingsCallback(watcher);
  await action();
  binding.removeTimingsCallback(watcher);
  // TODO(CareF): determine if it's running on firebase and report metric online
  final FrameTimingSummarizer frameTimes = FrameTimingSummarizer(frameTimings);
  binding.reportData = <String, dynamic>{reportKey: frameTimes.summary};
}

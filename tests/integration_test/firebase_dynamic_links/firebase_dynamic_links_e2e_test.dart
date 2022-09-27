// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tests/firebase_options.dart';

void main() {
  group(
    'firebase_dynamic_links',
    () {
      const String androidPackageName = 'io.flutter.plugins.firebase.tests';
      const String iosBundleId = 'io.flutter.plugins.firebase.tests';
      const String urlHost = 'flutterfiretests.page.link';
      const String link = 'https://firebase.flutter.dev';

      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      });

      group('buildLink', () {
        test('build dynamic links', () async {
          FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
          const String oflLink = 'https://ofl-link.com';
          final Uri dynamicLink = Uri.parse(
            'https://$urlHost/?amv=0&apn=io.flutter.plugins.firebase.dynamiclinksexample&ibi=io.invertase.testing&imv=0&link=https%3A%2F%2Ftest-app%2Fhelloworld&ofl=$oflLink',
          );
          final DynamicLinkParameters parameters = DynamicLinkParameters(
            uriPrefix: 'https://$urlHost',
            longDynamicLink: dynamicLink,
            link: Uri.parse(link),
            androidParameters: const AndroidParameters(
              packageName: androidPackageName,
              minimumVersion: 1,
            ),
            iosParameters: const IOSParameters(
              bundleId: iosBundleId,
              minimumVersion: '2',
            ),
          );

          final Uri uri = await dynamicLinks.buildLink(parameters);

          // androidParameters.minimumVersion
          expect(
            uri.queryParameters['amv'],
            '1',
          );
          // iosParameters.minimumVersion
          expect(
            uri.queryParameters['imv'],
            '2',
          );
          // androidParameters.packageName
          expect(
            uri.queryParameters['apn'],
            androidPackageName,
          );
          // iosParameters.bundleId
          expect(
            uri.queryParameters['ibi'],
            iosBundleId,
          );
          // link
          expect(
            uri.queryParameters['link'],
            Uri.encodeFull(link),
          );
          // uriPrefix
          expect(
            uri.host,
            urlHost,
          );
        });
      });

      group('buildShortLink', () {
        test('build short dynamic links', () async {
          FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
          const String oflLink = 'https://ofl-link.com';
          final Uri dynamicLink = Uri.parse(
            'https://$urlHost?amv=0&apn=io.flutter.plugins.firebase.dynamiclinksexample&ibi=io.invertase.testing&imv=0&link=https%3A%2F%2Ftest-app%2Fhelloworld&ofl=$oflLink',
          );
          final DynamicLinkParameters parameters = DynamicLinkParameters(
            uriPrefix: 'https://$urlHost',
            longDynamicLink: dynamicLink,
            link: Uri.parse(link),
            androidParameters: const AndroidParameters(
              packageName: androidPackageName,
              minimumVersion: 1,
            ),
            iosParameters: const IOSParameters(
              bundleId: iosBundleId,
              minimumVersion: '2',
            ),
          );

          final ShortDynamicLink uri =
              await dynamicLinks.buildShortLink(parameters);

          // androidParameters.minimumVersion
          expect(
            uri.shortUrl.host,
            urlHost,
          );

          expect(
            uri.shortUrl.pathSegments.length,
            equals(1),
          );

          expect(
            uri.shortUrl.path.length,
            lessThanOrEqualTo(18),
          );
        });
      });

      group('getInitialLink', () {
        test('initial link', () async {
          PendingDynamicLinkData? pendingLink =
              await FirebaseDynamicLinks.instance.getInitialLink();

          expect(pendingLink, isNull);
        });
      });

      group('getDynamicLink', () {
        test(
          'dynamic link using uri',
          () async {
            Uri uri = Uri.parse('');
            PendingDynamicLinkData? pendingLink =
                await FirebaseDynamicLinks.instance.getDynamicLink(uri);
            expect(pendingLink, isNull);
            // We skip this on iOS because we are getting "Universal link URL could
            // not be parsed by Dynamic Links.". Needs more investigation to figure
            // more details out.
          },
          skip: defaultTargetPlatform == TargetPlatform.iOS,
        );
      });

      group('onLink', () {
        test('test multiple times', () async {
          StreamSubscription<PendingDynamicLinkData?> _onListenSubscription;
          StreamSubscription<PendingDynamicLinkData?>
              _onListenSubscriptionSecond;

          _onListenSubscription =
              FirebaseDynamicLinks.instance.onLink.listen((event) {});
          _onListenSubscriptionSecond =
              FirebaseDynamicLinks.instance.onLink.listen((event) {});

          await _onListenSubscription.cancel();
          await _onListenSubscriptionSecond.cancel();

          _onListenSubscription =
              FirebaseDynamicLinks.instance.onLink.listen((event) {});
          _onListenSubscriptionSecond =
              FirebaseDynamicLinks.instance.onLink.listen((event) {});

          await _onListenSubscription.cancel();
          await _onListenSubscriptionSecond.cancel();
        });
      });
    },
    // Only supported on Android & iOS.
    // TODO temporarily skipping tests on Android while we figure out CI issues.
    //      mainly we're using the google_atd Android emulators since they're more reliable,
    //      however they do not contain necessary APIs for Dynamic Links.
    skip: kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.android,
  );
}
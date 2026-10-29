import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/case/case_controller.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> scheduleDeadlineReminders(CaseData data) async {
    await init();
    await _plugin.cancelAll();

    final deathDate = data.deathDate;
    final now = DateTime.now();

    final reminders = <_Reminder>[
      _Reminder(
        id: 1,
        date: deathDate.add(const Duration(days: 14)),
        titleHi: 'पंजीकरण में 7 दिन बाकी',
        titleEn: '7 days left for free registration',
        bodyHi: '21 दिन की निःशुल्क अवधि 7 दिन में समाप्त हो रही है। RBD Act §13(1)',
        bodyEn: 'Free 21-day registration period ends in 7 days. RBD Act §13(1)',
      ),
      _Reminder(
        id: 2,
        date: deathDate.add(const Duration(days: 18)),
        titleHi: 'पंजीकरण में 3 दिन बाकी',
        titleEn: '3 days left for free registration',
        bodyHi: 'कल या परसों तक आवेदन करें — निःशुल्क अवधि समाप्त हो रही है।',
        bodyEn: 'Apply by tomorrow or the day after — free period is ending.',
      ),
      _Reminder(
        id: 3,
        date: deathDate.add(const Duration(days: 21)),
        titleHi: 'निःशुल्क पंजीकरण अवधि समाप्त',
        titleEn: 'Free registration period ended',
        bodyHi: '21 दिन पूरे हो गए। अब विलंबित पंजीकरण में शुल्क लग सकता है।',
        bodyEn: '21 days are over. Delayed registration may require a fee.',
      ),
      _Reminder(
        id: 4,
        date: deathDate.add(const Duration(days: 25)),
        titleHi: 'विलंबित पंजीकरण — जल्दी करें',
        titleEn: 'Delayed registration — act soon',
        bodyHi: 'विलंबित पंजीकरण के लिए प्राधिकारी की अनुमति और शुल्क लगेगा। RBD Act §13(2)',
        bodyEn: 'Delayed registration needs authority permission and fee. RBD Act §13(2)',
      ),
    ];

    for (final r in reminders) {
      if (r.date.isAfter(now)) {
        await _scheduleAt(
          id: r.id,
          date: r.date,
          title: r.titleHi,
          body: r.bodyHi,
        );
      }
    }
  }

  static Future<void> _scheduleAt({
    required int id,
    required DateTime date,
    required String title,
    required String body,
  }) async {
    final delay = date.difference(DateTime.now());
    if (delay.isNegative) return;

    // Use zonedSchedule for exact time, fallback to Future.delayed + show
    // For simplicity and Android compatibility, schedule via delayed show
    Future.delayed(delay, () async {
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'deadlines',
            'समय सीमा अनुस्मारक',
            channelDescription: 'Death registration deadline reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  static Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}

class _Reminder {
  final int id;
  final DateTime date;
  final String titleHi;
  final String titleEn;
  final String bodyHi;
  final String bodyEn;

  const _Reminder({
    required this.id,
    required this.date,
    required this.titleHi,
    required this.titleEn,
    required this.bodyHi,
    required this.bodyEn,
  });
}

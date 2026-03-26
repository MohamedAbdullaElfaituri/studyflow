import 'package:flutter/widgets.dart';

class AppCopy {
  const AppCopy(this.languageCode);

  final String languageCode;

  static AppCopy of(Locale locale) => AppCopy(locale.languageCode);

  bool get _isTr => languageCode == 'tr';
  bool get _isAr => languageCode == 'ar';

  String _pick({
    required String en,
    required String tr,
    required String ar,
  }) {
    if (_isTr) {
      return tr;
    }
    if (_isAr) {
      return ar;
    }
    return en;
  }

  String get continueWithGoogle => _pick(
        en: 'Continue with Google',
        tr: 'Google ile devam et',
        ar: 'المتابعة عبر Google',
      );

  String get continueWithApple => _pick(
        en: 'Continue with Apple',
        tr: 'Apple ile devam et',
        ar: 'المتابعة عبر Apple',
      );

  String get authDivider => _pick(
        en: 'Or continue with',
        tr: 'Veya şununla devam et',
        ar: 'أو تابع عبر',
      );

  String get chooseLanguageTitle => _pick(
        en: 'Choose your app language',
        tr: 'Uygulama dilini seç',
        ar: 'اختر لغة التطبيق',
      );

  String get chooseLanguageSubtitle => _pick(
        en: 'You can change this later in Settings without losing layout quality.',
        tr: 'Bunu daha sonra Ayarlar ekranından düzeni bozmadan değiştirebilirsin.',
        ar: 'يمكنك تغييرها لاحقًا من الإعدادات بدون التأثير على جودة الواجهة.',
      );

  String get examsTitle => _pick(
        en: 'Exams & Assignments',
        tr: 'Sınavlar ve Teslimler',
        ar: 'الاختبارات والتسليمات',
      );

  String get examsSubtitle => _pick(
        en: 'Track deadlines, countdowns, and critical academic milestones.',
        tr: 'Son teslimleri, geri sayımları ve kritik akademik tarihleri takip et.',
        ar: 'تابع المواعيد النهائية والعد التنازلي والمحطات الأكاديمية المهمة.',
      );

  String get addExamAction => _pick(
        en: 'Add exam',
        tr: 'Sınav ekle',
        ar: 'إضافة اختبار',
      );

  String get addExamTitle => _pick(
        en: 'Create exam item',
        tr: 'Sınav kaydı oluştur',
        ar: 'إنشاء عنصر اختبار',
      );

  String get editExamTitle => _pick(
        en: 'Edit exam item',
        tr: 'Sınav kaydını düzenle',
        ar: 'تعديل عنصر الاختبار',
      );

  String get examTypeLabel => _pick(
        en: 'Type',
        tr: 'Tür',
        ar: 'النوع',
      );

  String get examDateLabel => _pick(
        en: 'Exam date',
        tr: 'Tarih',
        ar: 'التاريخ',
      );

  String get saveExamAction => _pick(
        en: 'Save exam',
        tr: 'Sınavı kaydet',
        ar: 'حفظ الاختبار',
      );

  String get deleteExamAction => _pick(
        en: 'Delete exam',
        tr: 'Sınavı sil',
        ar: 'حذف الاختبار',
      );

  String get emptyExamsTitle => _pick(
        en: 'No upcoming academic deadlines',
        tr: 'Yaklaşan akademik tarih yok',
        ar: 'لا توجد مواعيد أكاديمية قريبة',
      );

  String get emptyExamsDescription => _pick(
        en: 'Add your exams or assignments to get visual countdown reminders.',
        tr: 'Görsel geri sayım için sınavlarını veya teslimlerini ekle.',
        ar: 'أضف الاختبارات أو المهام للحصول على تذكيرات مرئية بالعد التنازلي.',
      );

  String get examTypeExam => _pick(
        en: 'Exam',
        tr: 'Sınav',
        ar: 'اختبار',
      );

  String get examTypeAssignment => _pick(
        en: 'Assignment',
        tr: 'Teslim',
        ar: 'واجب',
      );

  String get examTypeQuiz => _pick(
        en: 'Quiz',
        tr: 'Quiz',
        ar: 'اختبار قصير',
      );

  String examCountdown(int days) => _pick(
        en: '$days days left',
        tr: '$days gün kaldı',
        ar: 'متبقي $days يوم',
      );

  String get habitsTitle => _pick(
        en: 'Habit Tracker',
        tr: 'Alışkanlık Takibi',
        ar: 'متابعة العادات',
      );

  String get habitsSubtitle => _pick(
        en: 'Build repeatable routines without making the UI feel heavy.',
        tr: 'Arayüzü yormadan tekrarlanabilir rutinler oluştur.',
        ar: 'ابنِ روتينًا متكررًا بدون أن تصبح الواجهة مرهقة.',
      );

  String get addHabitAction => _pick(
        en: 'Add habit',
        tr: 'Alışkanlık ekle',
        ar: 'إضافة عادة',
      );

  String get addHabitTitle => _pick(
        en: 'Create habit',
        tr: 'Alışkanlık oluştur',
        ar: 'إنشاء عادة',
      );

  String get editHabitTitle => _pick(
        en: 'Edit habit',
        tr: 'Alışkanlığı düzenle',
        ar: 'تعديل العادة',
      );

  String get habitGoalLabel => _pick(
        en: 'Daily goal count',
        tr: 'Günlük hedef adedi',
        ar: 'عدد الهدف اليومي',
      );

  String get habitFrequencyLabel => _pick(
        en: 'Frequency',
        tr: 'Sıklık',
        ar: 'التكرار',
      );

  String get habitDaily => _pick(
        en: 'Daily',
        tr: 'Günlük',
        ar: 'يومي',
      );

  String get habitWeekly => _pick(
        en: 'Weekly',
        tr: 'Haftalık',
        ar: 'أسبوعي',
      );

  String get saveHabitAction => _pick(
        en: 'Save habit',
        tr: 'Alışkanlığı kaydet',
        ar: 'حفظ العادة',
      );

  String get deleteHabitAction => _pick(
        en: 'Delete habit',
        tr: 'Alışkanlığı sil',
        ar: 'حذف العادة',
      );

  String get emptyHabitsTitle => _pick(
        en: 'No habits yet',
        tr: 'Henüz alışkanlık yok',
        ar: 'لا توجد عادات بعد',
      );

  String get emptyHabitsDescription => _pick(
        en: 'Create a small routine to support consistency, recovery, or revision.',
        tr: 'Tutarlılık, dinlenme veya tekrar için küçük bir rutin oluştur.',
        ar: 'أنشئ روتينًا صغيرًا يدعم الاستمرارية أو الاستراحة أو المراجعة.',
      );

  String habitProgress(int value, int target) => _pick(
        en: '$value / $target complete',
        tr: '$value / $target tamamlandı',
        ar: '$value / $target مكتمل',
      );

  String habitStreak(int streak) => _pick(
        en: '$streak day streak',
        tr: '$streak günlük seri',
        ar: 'سلسلة من $streak أيام',
      );

  String get searchTitle => _pick(
        en: 'Smart Search',
        tr: 'Akıllı Arama',
        ar: 'البحث الذكي',
      );

  String get searchSubtitle => _pick(
        en: 'Search courses, tasks, notes, and academic deadlines in one place.',
        tr: 'Dersleri, görevleri, notları ve tarihleri tek yerden ara.',
        ar: 'ابحث في المواد والمهام والملاحظات والمواعيد من مكان واحد.',
      );

  String get searchHint => _pick(
        en: 'Search all study content',
        tr: 'Tüm çalışma içeriğinde ara',
        ar: 'ابحث في كل محتوى الدراسة',
      );

  String get emptySearchTitle => _pick(
        en: 'Start typing to search',
        tr: 'Aramak için yazmaya başla',
        ar: 'ابدأ بالكتابة للبحث',
      );

  String get emptySearchDescription => _pick(
        en: 'Results will appear instantly across tasks, notes, courses, and exams.',
        tr: 'Sonuçlar görevler, notlar, dersler ve sınavlarda anında görünecek.',
        ar: 'ستظهر النتائج مباشرة عبر المهام والملاحظات والمواد والاختبارات.',
      );

  String get searchCoursesSection => _pick(
        en: 'Courses',
        tr: 'Dersler',
        ar: 'المواد',
      );

  String get searchTasksSection => _pick(
        en: 'Tasks',
        tr: 'Görevler',
        ar: 'المهام',
      );

  String get searchNotesSection => _pick(
        en: 'Notes',
        tr: 'Notlar',
        ar: 'الملاحظات',
      );

  String get searchExamsSection => _pick(
        en: 'Exams',
        tr: 'Sınavlar',
        ar: 'الاختبارات',
      );

  String get quickSearchAction => _pick(
        en: 'Search',
        tr: 'Ara',
        ar: 'بحث',
      );

  String get weeklyChallengeTitle => _pick(
        en: 'Weekly challenge',
        tr: 'Haftalık meydan okuma',
        ar: 'تحدي الأسبوع',
      );

  String weeklyChallengeDescription(int minutes) => _pick(
        en: 'Reach $minutes minutes of focused work this week to unlock bonus XP.',
        tr: 'Bu hafta $minutes dakika odaklı çalışıp bonus XP kazan.',
        ar: 'صل إلى $minutes دقيقة من التركيز هذا الأسبوع لفتح نقاط XP إضافية.',
      );

  String get levelLabel => _pick(
        en: 'Level',
        tr: 'Seviye',
        ar: 'المستوى',
      );

  String get xpLabel => _pick(
        en: 'XP',
        tr: 'XP',
        ar: 'XP',
      );

  String get syncStatusTitle => _pick(
        en: 'Sync status',
        tr: 'Senkron durumu',
        ar: 'حالة المزامنة',
      );

  String get syncReadyLabel => _pick(
        en: 'Ready for Supabase sync',
        tr: 'Supabase senkronizasyonuna hazır',
        ar: 'جاهز للمزامنة مع Supabase',
      );

  String get aboutLabel => _pick(
        en: 'About',
        tr: 'Hakkında',
        ar: 'حول التطبيق',
      );

  String get privacyLabel => _pick(
        en: 'Privacy',
        tr: 'Gizlilik',
        ar: 'الخصوصية',
      );

  String get termsLabel => _pick(
        en: 'Terms',
        tr: 'Kullanım koşulları',
        ar: 'الشروط',
      );

  String get placeholderLegalBody => _pick(
        en: 'Placeholder content is ready for final legal or course-project copy.',
        tr: 'Yer tutucu içerik, final yasal metin ya da ders projesi metni için hazır.',
        ar: 'المحتوى التجريبي جاهز للنص القانوني النهائي أو نسخة مشروع المقرر.',
      );

  String get premiumDashboardTitle => _pick(
        en: 'Your study command center',
        tr: 'Çalışma komuta merkezi',
        ar: 'مركز قيادة الدراسة',
      );

  String get premiumDashboardSubtitle => _pick(
        en: 'A single view for focus, progress, deadlines, and recovery.',
        tr: 'Odak, ilerleme, tarih ve dinlenmeyi tek ekranda topla.',
        ar: 'رؤية واحدة للتركيز والتقدم والمواعيد والاستراحة.',
      );

  String get plannerPulseTitle => _pick(
        en: 'Planner pulse',
        tr: 'Plan nabzı',
        ar: 'نبض الخطة',
      );

  String get plannerPulseSubtitle => _pick(
        en: 'A quick read on how balanced your week looks right now.',
        tr: 'Haftanın şu an ne kadar dengeli göründüğünü hızlıca oku.',
        ar: 'قراءة سريعة لمدى توازن أسبوعك الآن.',
      );

  String get motivationMomentTitle => _pick(
        en: 'Motivation moment',
        tr: 'Motivasyon anı',
        ar: 'لحظة تحفيز',
      );

  String get examsQuickCardTitle => _pick(
        en: 'Critical deadlines',
        tr: 'Kritik tarihler',
        ar: 'المواعيد الحرجة',
      );

  String get examsQuickCardSubtitle => _pick(
        en: 'Keep the next exam or delivery visible before it becomes stressful.',
        tr: 'Bir sonraki sınav veya teslimi, stres olmadan önce görünür tut.',
        ar: 'أبقِ الاختبار أو التسليم القادم مرئيًا قبل أن يتحول إلى ضغط.',
      );

  String get habitsQuickCardTitle => _pick(
        en: 'Routines in motion',
        tr: 'Devam eden rutinler',
        ar: 'العادات النشطة',
      );

  String get notificationPermissionsAction => _pick(
        en: 'Allow notifications',
        tr: 'Bildirimlere izin ver',
        ar: 'السماح بالإشعارات',
      );

  String get notificationPermissionsHint => _pick(
        en: 'Enable reminders for focus sessions, tasks, and deadlines.',
        tr: 'Odak seansları, görevler ve tarihler için hatırlatma aç.',
        ar: 'فعّل التذكيرات لجلسات التركيز والمهام والمواعيد.',
      );
}

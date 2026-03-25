// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'StudyFlow';

  @override
  String get splashSubtitle =>
      'Odaklı üniversite yaşamı için premium çalışma planlaması.';

  @override
  String get genericNavigationError => 'Bu ekran açılırken bir sorun oluştu.';

  @override
  String get genericErrorMessage => 'Bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get errorStateTitle => 'Küçük bir sorun oluştu';

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String get validationRequired => 'Bu alan zorunludur.';

  @override
  String get validationInvalidEmail => 'Geçerli bir e-posta adresi girin.';

  @override
  String validationMinLength(int min) {
    return 'En az $min karakter kullanın.';
  }

  @override
  String get errorUserNotFound => 'Bu e-posta ile bir hesap bulamadık.';

  @override
  String get errorInvalidCredentials => 'E-posta veya şifre yanlış.';

  @override
  String get errorDuplicateEmail => 'Bu e-posta zaten kullanılıyor.';

  @override
  String get errorMissingUser => 'İsteğinizi şu anda tamamlayamadık.';

  @override
  String get homeTab => 'Ana sayfa';

  @override
  String get tasksTab => 'Görevler';

  @override
  String get calendarTab => 'Takvim';

  @override
  String get focusTab => 'Odak';

  @override
  String get profileTab => 'Profil';

  @override
  String get loginTitle => 'Tekrar hoş geldin';

  @override
  String get loginSubtitle =>
      'Derslerini, görevlerini, notlarını ve odak geçmişini birlikte tutmak için giriş yap.';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get forgotPasswordAction => 'Şifremi unuttum';

  @override
  String get loginAction => 'Giriş yap';

  @override
  String get demoAccountTitle => 'Sunuma hazır demo akışı';

  @override
  String get demoAccountDescription =>
      'Sunum sırasında uygulamayı hızlıca göstermek için hazır bilgileri kullanın veya yeni bir hesap oluşturun.';

  @override
  String get noAccountPrompt => 'Hesabın yok mu?';

  @override
  String get signUpAction => 'Kayıt ol';

  @override
  String get signUpTitle => 'Hesabını oluştur';

  @override
  String get signUpSubtitle =>
      'Kendi çalışma sistemini tek ve zarif bir alanda kur.';

  @override
  String get fullNameLabel => 'Ad soyad';

  @override
  String get confirmPasswordLabel => 'Şifreyi doğrula';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor.';

  @override
  String get createAccountAction => 'Hesap oluştur';

  @override
  String get forgotPasswordTitle => 'Şifreni sıfırla';

  @override
  String get forgotPasswordSubtitle =>
      'E-posta adresini gir, sana sıfırlama akışını hazırlayalım.';

  @override
  String get sendResetLinkAction => 'Sıfırlama bağlantısı gönder';

  @override
  String get resetPasswordSentMessage =>
      'Hesap varsa, sıfırlama akışı hazırlandı.';

  @override
  String get onboardingTitleOne => 'Tüm derslerini tek akışta planla';

  @override
  String get onboardingSubtitleOne =>
      'Dersleri, ödevleri, son tarihleri ve notları sakin bir mobil deneyimle takip et.';

  @override
  String get onboardingTitleTwo => 'Akıllı içgörülerle odakta kal';

  @override
  String get onboardingSubtitleTwo =>
      'Çalışma oturumlarını seri, hedef ve haftalık özetlerle ölçülebilir ilerlemeye dönüştür.';

  @override
  String get onboardingTitleThree => 'Kapsayıcı, çok dilli ve özenli';

  @override
  String get onboardingSubtitleThree =>
      'İngilizce, Türkçe ve Arapça arasında geçiş yap; Arapça için tam RTL desteği al.';

  @override
  String get skipAction => 'Geç';

  @override
  String get nextAction => 'İleri';

  @override
  String get finishAction => 'Bitir';

  @override
  String welcomeBack(String name) {
    return 'Tekrar hoş geldin, $name';
  }

  @override
  String dashboardHeroSubtitle(String date) {
    return '$date için çalışma akışın burada.';
  }

  @override
  String get dailyStudyMinutesLabel => 'Bugünkü dakika';

  @override
  String get weeklyStudyMinutesLabel => 'Haftalık dakika';

  @override
  String get completedTasksLabel => 'Tamamlanan görev';

  @override
  String get streakLabel => 'Seri';

  @override
  String get quickActionsTitle => 'Hızlı işlemler';

  @override
  String get quickActionsSubtitle => 'Şimdi önemli olana hemen geç.';

  @override
  String get quickTaskSubtitle => 'Ödev ekle veya yönet';

  @override
  String get quickCourseSubtitle => 'Derslerini düzenle';

  @override
  String get quickNoteSubtitle => 'Ders notu yakala';

  @override
  String get quickAnalyticsSubtitle => 'İlerlemeni incele';

  @override
  String get todayPlanTitle => 'Bugünün planı';

  @override
  String get todayPlanSubtitle => 'Gün bitmeden ilgilenmen gerekenler.';

  @override
  String get emptyTodayTitle => 'Bugünün açık görünüyor';

  @override
  String get emptyTodayDescription =>
      'İvme kazanmak için bir görev ekle veya odak oturumu planla.';

  @override
  String get goalProgressTitle => 'Hedef ilerlemesi';

  @override
  String get goalProgressSubtitle =>
      'Günlük, haftalık ve aylık hedefleri tek bakışta gör.';

  @override
  String get viewAllAction => 'Tümünü gör';

  @override
  String get dailyGoalLabel => 'Günlük hedef';

  @override
  String get weeklyGoalLabel => 'Haftalık hedef';

  @override
  String get monthlyGoalLabel => 'Aylık hedef';

  @override
  String goalProgressValue(int value, int target) {
    return '$value/$target dk';
  }

  @override
  String get insightsTitle => 'Üretkenlik içgörüleri';

  @override
  String get insightsSubtitle =>
      'Son çalışma düzenine göre yardımcı gözlemler.';

  @override
  String insightStreak(int days) {
    return '$days günlük bir seridesin. Düzenini koru ve en verimli saatlerini sahiplen.';
  }

  @override
  String get insightPlanDay =>
      'Bugünkü planında alan var. Kısa bir odak oturumu ritmini korumana yardım edebilir.';

  @override
  String get insightBoostFocus =>
      'Haftalık hedefin hâlâ ulaşılabilir. İki odaklı oturum arayı kapatabilir.';

  @override
  String get insightStrongMomentum =>
      'İlerlemen dengeli görünüyor. Odaklı çalışmayı gerçekçi görev planıyla sürdür.';

  @override
  String get achievementsTitle => 'Başarılar';

  @override
  String get achievementsSubtitle =>
      'Sürekliliği güçlendiren küçük kazanımlar.';

  @override
  String get recentActivityTitle => 'Son etkinlik';

  @override
  String get recentActivitySubtitle =>
      'En son çalışma oturumların ve ivme sinyallerin.';

  @override
  String get emptyActivityTitle => 'Henüz son etkinlik yok';

  @override
  String get emptyActivityDescription =>
      'Etkinlik geçmişini oluşturmaya başlamak için bir odak oturumu tamamla.';

  @override
  String focusSessionSummary(int minutes) {
    return '$minutes dakikalık odak oturumu';
  }

  @override
  String get tasksTitle => 'Görevler';

  @override
  String get tasksSubtitle =>
      'Çalışma yükünü arat, filtrele ve netlikle tamamla.';

  @override
  String get addTaskAction => 'Görev ekle';

  @override
  String get addTaskTitle => 'Görev oluştur';

  @override
  String get editTaskTitle => 'Görevi düzenle';

  @override
  String get taskDetailTitle => 'Görev detayları';

  @override
  String get searchTasksHint => 'Görevlerde ara';

  @override
  String get sortByDueDate => 'Teslim tarihine göre sırala';

  @override
  String get sortByPriority => 'Önceliğe göre sırala';

  @override
  String get sortByCourse => 'Derse göre sırala';

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterPending => 'Bekliyor';

  @override
  String get filterInProgress => 'Devam ediyor';

  @override
  String get filterCompleted => 'Tamamlandı';

  @override
  String get archiveCompletedAction => 'Tamamlananları arşivle';

  @override
  String get emptyTasksTitle => 'Henüz görev yok';

  @override
  String get emptyTasksDescription =>
      'Bugünkü planı oluşturmak için ilk görevini ekle.';

  @override
  String get taskNotFoundTitle => 'Görev bulunamadı';

  @override
  String get taskNotFoundDescription =>
      'Bu görev silinmiş olabilir veya artık mevcut değil.';

  @override
  String get statusLabel => 'Durum';

  @override
  String get priorityLabel => 'Öncelik';

  @override
  String get dueDateLabel => 'Teslim tarihi';

  @override
  String get estimatedMinutesLabel => 'Tahmini dakika';

  @override
  String get courseLabel => 'Ders';

  @override
  String get linkedTasksTitle => 'Bağlı görevler';

  @override
  String get linkedTasksSubtitle =>
      'Bu dersle bağlantılı ödevler ve çalışma adımları.';

  @override
  String get emptyLinkedTasksTitle => 'Henüz bağlı görev yok';

  @override
  String get emptyLinkedTasksDescription => 'Bir görev ekleyip bu derse bağla.';

  @override
  String get subtasksTitle => 'Alt görevler';

  @override
  String get emptySubtasksDescription =>
      'İşi daha kolay ilerletmek için küçük adımlara böl.';

  @override
  String get deleteTaskAction => 'Görevi sil';

  @override
  String get titleLabel => 'Başlık';

  @override
  String get descriptionLabel => 'Açıklama';

  @override
  String get optionalCourseLabel => 'Ders bağlantısı yok';

  @override
  String get priorityLow => 'Düşük';

  @override
  String get priorityMedium => 'Orta';

  @override
  String get priorityHigh => 'Yüksek';

  @override
  String get priorityUrgent => 'Acil';

  @override
  String get pickDateAction => 'Tarih seç';

  @override
  String get pickTimeAction => 'Saat seç';

  @override
  String subtaskLabel(int index) {
    return 'Alt görev $index';
  }

  @override
  String get addSubtaskAction => 'Alt görev ekle';

  @override
  String get saveTaskAction => 'Görevi kaydet';

  @override
  String get coursesTitle => 'Dersler';

  @override
  String get addCourseAction => 'Ders ekle';

  @override
  String get addCourseTitle => 'Ders oluştur';

  @override
  String get editCourseTitle => 'Dersi düzenle';

  @override
  String get courseDetailTitle => 'Ders görünümü';

  @override
  String get emptyCoursesTitle => 'Henüz ders yok';

  @override
  String get emptyCoursesDescription =>
      'İlgili görevleri ve notları düzenlemek için bir ders oluştur.';

  @override
  String courseTaskNoteSummary(int taskCount, int noteCount) {
    return '$taskCount görev • $noteCount not';
  }

  @override
  String get courseNotFoundTitle => 'Ders bulunamadı';

  @override
  String get courseNotFoundDescription => 'Bu ders yüklenemedi.';

  @override
  String get instructorLabel => 'Öğretim üyesi';

  @override
  String get linkedNotesTitle => 'Bağlı notlar';

  @override
  String get linkedNotesSubtitle =>
      'Bu dersle ilişkili kısa notlar ve ders özetleri.';

  @override
  String get emptyLinkedNotesTitle => 'Henüz bağlı not yok';

  @override
  String get emptyLinkedNotesDescription => 'Bir not oluşturup bu derse bağla.';

  @override
  String get deleteCourseAction => 'Dersi sil';

  @override
  String get courseColorLabel => 'Ders rengi';

  @override
  String get saveCourseAction => 'Dersi kaydet';

  @override
  String get notesTitle => 'Notlar';

  @override
  String get addNoteAction => 'Not ekle';

  @override
  String get addNoteTitle => 'Not oluştur';

  @override
  String get editNoteTitle => 'Notu düzenle';

  @override
  String get searchNotesHint => 'Notlarda ara';

  @override
  String get emptyNotesTitle => 'Henüz not yok';

  @override
  String get emptyNotesDescription =>
      'İlk içgörünü, ders özetini veya tekrar kontrol listesini kaydet.';

  @override
  String get contentLabel => 'İçerik';

  @override
  String get pinNoteLabel => 'Bu notu sabitle';

  @override
  String get saveNoteAction => 'Notu kaydet';

  @override
  String get calendarTitle => 'Planlayıcı';

  @override
  String get calendarSubtitle =>
      'Günlük ajanda ile aylık ve haftalık planlama.';

  @override
  String get monthFormatLabel => 'Ay';

  @override
  String get weekFormatLabel => 'Hafta';

  @override
  String dailyAgendaTitle(String date) {
    return '$date için ajanda';
  }

  @override
  String get emptyAgendaDescription =>
      'Bu gün için planlanmış görev veya odak oturumu yok.';

  @override
  String get focusTitle => 'Odak modu';

  @override
  String get focusSubtitle =>
      'Pomodoro tarzı oturumlarla bilinçli ve enerjik kal.';

  @override
  String get focusModeLabel => 'Odak oturumu';

  @override
  String get breakModeLabel => 'Mola oturumu';

  @override
  String get startAction => 'Başlat';

  @override
  String get pauseAction => 'Duraklat';

  @override
  String get resumeAction => 'Sürdür';

  @override
  String get resetAction => 'Sıfırla';

  @override
  String get customizeSessionTitle => 'Oturumu özelleştir';

  @override
  String focusDurationLabel(int minutes) {
    return 'Odak süresi: $minutes dakika';
  }

  @override
  String breakDurationLabel(int minutes) {
    return 'Mola süresi: $minutes dakika';
  }

  @override
  String get linkCourseOptionalLabel => 'Oturumu bir derse bağla';

  @override
  String get focusHistoryTitle => 'Odak geçmişi';

  @override
  String get focusHistorySubtitle =>
      'İlerleme zaman çizelgene kaydedilen son tamamlanan oturumlar.';

  @override
  String get emptyFocusHistoryTitle => 'Henüz odak geçmişi yok';

  @override
  String get emptyFocusHistoryDescription =>
      'Çalışma ritmini takip etmeye başlamak için bir oturum başlat.';

  @override
  String get focusSessionCompleteMessage =>
      'Odak oturumu tamamlandı. Harika iş.';

  @override
  String get analyticsTitle => 'Analitik';

  @override
  String get weeklyFocusChartTitle => 'Son 7 gün';

  @override
  String get courseDistributionTitle => 'Ders dağılımı';

  @override
  String get miscLabel => 'Diğer';

  @override
  String courseAnalyticsRow(String course, int minutes) {
    return '$course: $minutes dakika';
  }

  @override
  String get goalsTitle => 'Hedefler';

  @override
  String get studyGoalsTitle => 'Çalışma hedefleri';

  @override
  String get saveGoalsAction => 'Hedefleri kaydet';

  @override
  String get goalsSavedMessage => 'Hedeflerin güncellendi.';

  @override
  String get dailyCheckInTitle => 'Günlük yoklama';

  @override
  String get dailyCheckInDescription =>
      'Yoğun günlerde bile hedeflerinle bağını korumak için kısa bir oturum kaydet.';

  @override
  String get dailyCheckInAction => 'Şimdi yoklama yap';

  @override
  String get dailyCheckInSuccessMessage =>
      'Bugüne kısa bir yoklama oturumu eklendi.';

  @override
  String get weeklyReviewTitle => 'Haftalık değerlendirme';

  @override
  String get weeklyReviewDescription =>
      'Kısa bir değerlendirme ilerlemeyi görmene ve gelecek haftayı ayarlamana yardım eder.';

  @override
  String weeklyReviewSummary(int minutes, int tasks) {
    return 'Bu hafta $minutes dakika çalıştın ve $tasks görev tamamladın.';
  }

  @override
  String get profileFallbackName => 'StudyFlow Öğrencisi';

  @override
  String get editProfileAction => 'Profili düzenle';

  @override
  String get profileOverviewTitle => 'Profil özeti';

  @override
  String get profileOverviewSubtitle =>
      'Mevcut çalışma kimliğinin ve ivmenin kısa görünümü.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get logoutAction => 'Çıkış yap';

  @override
  String get editProfileTitle => 'Profili düzenle';

  @override
  String get saveProfileAction => 'Profili kaydet';

  @override
  String get languageSectionTitle => 'Dil';

  @override
  String get englishLabel => 'İngilizce';

  @override
  String get turkishLabel => 'Türkçe';

  @override
  String get arabicLabel => 'Arapça';

  @override
  String get themeSectionTitle => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get taskRemindersLabel => 'Görev hatırlatmaları';

  @override
  String get studyRemindersLabel => 'Çalışma hatırlatmaları';

  @override
  String get dailyReminderLabel => 'Günlük hatırlatma';

  @override
  String get notificationPreviewTitle => 'StudyFlow hatırlatması';

  @override
  String get notificationPreviewBody =>
      'Kısa bir odak oturumu bugünü ileri taşıyabilir.';

  @override
  String get previewNotificationAction => 'Bildirimi önizle';

  @override
  String get accessibilityPlaceholderTitle => 'Erişilebilirlik desteği';

  @override
  String get accessibilityPlaceholderDescription =>
      'Daha büyük metin, azaltılmış hareket ve yardımcı teknolojiler için ayarlar burada genişletilebilir.';
}

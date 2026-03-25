// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'StudyFlow';

  @override
  String get splashSubtitle => 'تخطيط دراسي مميز لحياة جامعية أكثر تركيزًا.';

  @override
  String get genericNavigationError => 'حدثت مشكلة أثناء فتح هذه الشاشة.';

  @override
  String get genericErrorMessage => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errorStateTitle => 'واجهنا مشكلة بسيطة';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get validationRequired => 'هذا الحقل مطلوب.';

  @override
  String get validationInvalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String validationMinLength(int min) {
    return 'استخدم $min أحرف على الأقل.';
  }

  @override
  String get errorUserNotFound => 'لم نعثر على حساب بهذا البريد الإلكتروني.';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorDuplicateEmail => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get errorMissingUser => 'تعذر إكمال طلبك الآن.';

  @override
  String get homeTab => 'الرئيسية';

  @override
  String get tasksTab => 'المهام';

  @override
  String get calendarTab => 'التقويم';

  @override
  String get focusTab => 'التركيز';

  @override
  String get profileTab => 'الملف الشخصي';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle =>
      'سجّل الدخول لتجعل الدورات والمهام والملاحظات وسجل التركيز في مكان واحد.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get forgotPasswordAction => 'نسيت كلمة المرور؟';

  @override
  String get loginAction => 'تسجيل الدخول';

  @override
  String get demoAccountTitle => 'عرض جاهز للمشروع';

  @override
  String get demoAccountDescription =>
      'استخدم بيانات الدخول المعبأة مسبقًا أو أنشئ حسابًا جديدًا لاستعراض التطبيق بسرعة أثناء العرض.';

  @override
  String get noAccountPrompt => 'ليس لديك حساب؟';

  @override
  String get signUpAction => 'إنشاء حساب';

  @override
  String get signUpTitle => 'أنشئ حسابك';

  @override
  String get signUpSubtitle =>
      'ابنِ نظامك الدراسي الشخصي في مساحة أنيقة واحدة.';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get createAccountAction => 'إنشاء الحساب';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنجهز لك مسار إعادة التعيين.';

  @override
  String get sendResetLinkAction => 'إرسال رابط إعادة التعيين';

  @override
  String get resetPasswordSentMessage =>
      'إذا كان الحساب موجودًا، فقد تم تجهيز مسار إعادة التعيين.';

  @override
  String get onboardingTitleOne => 'خطط كل مقرراتك في تدفق واحد';

  @override
  String get onboardingSubtitleOne =>
      'تابع المواد والواجبات والمواعيد النهائية والملاحظات بتجربة هادئة موجهة للهاتف.';

  @override
  String get onboardingTitleTwo => 'ابقَ مركزًا مع رؤى ذكية';

  @override
  String get onboardingSubtitleTwo =>
      'حوّل جلسات الدراسة إلى تقدم قابل للقياس عبر السلاسل والأهداف والملخصات الأسبوعية.';

  @override
  String get onboardingTitleThree => 'شامل ومتعدد اللغات ومتقن';

  @override
  String get onboardingSubtitleThree =>
      'بدّل بين الإنجليزية والتركية والعربية مع دعم RTL كامل للعربية.';

  @override
  String get skipAction => 'تخطي';

  @override
  String get nextAction => 'التالي';

  @override
  String get finishAction => 'إنهاء';

  @override
  String welcomeBack(String name) {
    return 'مرحبًا بعودتك يا $name';
  }

  @override
  String dashboardHeroSubtitle(String date) {
    return 'إليك تدفق دراستك ليوم $date.';
  }

  @override
  String get dailyStudyMinutesLabel => 'دقائق اليوم';

  @override
  String get weeklyStudyMinutesLabel => 'دقائق الأسبوع';

  @override
  String get completedTasksLabel => 'المهام المكتملة';

  @override
  String get streakLabel => 'السلسلة';

  @override
  String get quickActionsTitle => 'إجراءات سريعة';

  @override
  String get quickActionsSubtitle => 'انتقل مباشرة إلى ما يهم الآن.';

  @override
  String get quickTaskSubtitle => 'أضف الواجبات أو أدِرها';

  @override
  String get quickCourseSubtitle => 'نظّم مقرراتك';

  @override
  String get quickNoteSubtitle => 'دوّن ملاحظات المحاضرات';

  @override
  String get quickAnalyticsSubtitle => 'راجع تقدمك';

  @override
  String get todayPlanTitle => 'خطة اليوم';

  @override
  String get todayPlanSubtitle => 'ما يحتاج إلى اهتمام قبل نهاية اليوم.';

  @override
  String get emptyTodayTitle => 'يومك خفيف';

  @override
  String get emptyTodayDescription => 'أضف مهمة أو خطط جلسة تركيز لبناء الزخم.';

  @override
  String get goalProgressTitle => 'تقدم الأهداف';

  @override
  String get goalProgressSubtitle =>
      'الأهداف اليومية والأسبوعية والشهرية في لمحة.';

  @override
  String get viewAllAction => 'عرض الكل';

  @override
  String get dailyGoalLabel => 'الهدف اليومي';

  @override
  String get weeklyGoalLabel => 'الهدف الأسبوعي';

  @override
  String get monthlyGoalLabel => 'الهدف الشهري';

  @override
  String goalProgressValue(int value, int target) {
    return '$value/$target دقيقة';
  }

  @override
  String get insightsTitle => 'رؤى الإنتاجية';

  @override
  String get insightsSubtitle => 'ملاحظات مفيدة مبنية على أنماطك الأخيرة.';

  @override
  String insightStreak(int days) {
    return 'أنت على سلسلة من $days أيام. حافظ على الروتين واحمِ أفضل ساعات دراستك.';
  }

  @override
  String get insightPlanDay =>
      'لديك مساحة في خطة اليوم. جلسة تركيز قصيرة قد تحافظ على إيقاعك.';

  @override
  String get insightBoostFocus =>
      'هدفك الأسبوعي ما يزال ممكنًا. جلستان مركزتان قد تغلقان الفجوة.';

  @override
  String get insightStrongMomentum =>
      'تقدمك يبدو ثابتًا. واصل الجمع بين العمل المركز والتخطيط الواقعي للمهام.';

  @override
  String get achievementsTitle => 'الإنجازات';

  @override
  String get achievementsSubtitle => 'انتصارات صغيرة تعزز الاستمرارية.';

  @override
  String get recentActivityTitle => 'النشاط الأخير';

  @override
  String get recentActivitySubtitle => 'أحدث جلسات الدراسة وإشارات الزخم.';

  @override
  String get emptyActivityTitle => 'لا يوجد نشاط حديث بعد';

  @override
  String get emptyActivityDescription => 'أكمل جلسة تركيز لبدء بناء سجل نشاطك.';

  @override
  String focusSessionSummary(int minutes) {
    return 'جلسة تركيز لمدة $minutes دقيقة';
  }

  @override
  String get tasksTitle => 'المهام';

  @override
  String get tasksSubtitle => 'ابحث وصفِّ وأكمل عبء الدراسة بوضوح.';

  @override
  String get addTaskAction => 'إضافة مهمة';

  @override
  String get addTaskTitle => 'إنشاء مهمة';

  @override
  String get editTaskTitle => 'تعديل المهمة';

  @override
  String get taskDetailTitle => 'تفاصيل المهمة';

  @override
  String get searchTasksHint => 'ابحث في المهام';

  @override
  String get sortByDueDate => 'ترتيب حسب تاريخ الاستحقاق';

  @override
  String get sortByPriority => 'ترتيب حسب الأولوية';

  @override
  String get sortByCourse => 'ترتيب حسب المقرر';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterPending => 'قيد الانتظار';

  @override
  String get filterInProgress => 'قيد التنفيذ';

  @override
  String get filterCompleted => 'مكتملة';

  @override
  String get archiveCompletedAction => 'أرشفة المهام المكتملة';

  @override
  String get emptyTasksTitle => 'لا توجد مهام بعد';

  @override
  String get emptyTasksDescription => 'أنشئ مهمتك الأولى لبناء خطة اليوم.';

  @override
  String get taskNotFoundTitle => 'المهمة غير موجودة';

  @override
  String get taskNotFoundDescription =>
      'قد تكون هذه المهمة حُذفت أو لم تعد متاحة.';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get priorityLabel => 'الأولوية';

  @override
  String get dueDateLabel => 'تاريخ الاستحقاق';

  @override
  String get estimatedMinutesLabel => 'الدقائق المقدرة';

  @override
  String get courseLabel => 'المقرر';

  @override
  String get linkedTasksTitle => 'المهام المرتبطة';

  @override
  String get linkedTasksSubtitle =>
      'الواجبات وخطوات الدراسة المرتبطة بهذا المقرر.';

  @override
  String get emptyLinkedTasksTitle => 'لا توجد مهام مرتبطة بعد';

  @override
  String get emptyLinkedTasksDescription => 'أضف مهمة واربطها بهذا المقرر.';

  @override
  String get subtasksTitle => 'المهام الفرعية';

  @override
  String get emptySubtasksDescription =>
      'قسّم هذا العمل إلى خطوات أصغر لتسهيل التقدم.';

  @override
  String get deleteTaskAction => 'حذف المهمة';

  @override
  String get titleLabel => 'العنوان';

  @override
  String get descriptionLabel => 'الوصف';

  @override
  String get optionalCourseLabel => 'بدون ربط بمقرر';

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get priorityMedium => 'متوسطة';

  @override
  String get priorityHigh => 'مرتفعة';

  @override
  String get priorityUrgent => 'عاجلة';

  @override
  String get pickDateAction => 'اختر التاريخ';

  @override
  String get pickTimeAction => 'اختر الوقت';

  @override
  String subtaskLabel(int index) {
    return 'مهمة فرعية $index';
  }

  @override
  String get addSubtaskAction => 'إضافة مهمة فرعية';

  @override
  String get saveTaskAction => 'حفظ المهمة';

  @override
  String get coursesTitle => 'المقررات';

  @override
  String get addCourseAction => 'إضافة مقرر';

  @override
  String get addCourseTitle => 'إنشاء مقرر';

  @override
  String get editCourseTitle => 'تعديل المقرر';

  @override
  String get courseDetailTitle => 'نظرة عامة على المقرر';

  @override
  String get emptyCoursesTitle => 'لا توجد مقررات بعد';

  @override
  String get emptyCoursesDescription =>
      'أنشئ مقررًا لتنظيم المهام والملاحظات المرتبطة به.';

  @override
  String courseTaskNoteSummary(int taskCount, int noteCount) {
    return '$taskCount مهام • $noteCount ملاحظات';
  }

  @override
  String get courseNotFoundTitle => 'المقرر غير موجود';

  @override
  String get courseNotFoundDescription => 'تعذر تحميل هذا المقرر.';

  @override
  String get instructorLabel => 'المحاضر';

  @override
  String get linkedNotesTitle => 'الملاحظات المرتبطة';

  @override
  String get linkedNotesSubtitle =>
      'مراجع سريعة وملاحظات محاضرات مرتبطة بهذا المقرر.';

  @override
  String get emptyLinkedNotesTitle => 'لا توجد ملاحظات مرتبطة بعد';

  @override
  String get emptyLinkedNotesDescription => 'أنشئ ملاحظة واربطها بهذا المقرر.';

  @override
  String get deleteCourseAction => 'حذف المقرر';

  @override
  String get courseColorLabel => 'لون المقرر';

  @override
  String get saveCourseAction => 'حفظ المقرر';

  @override
  String get notesTitle => 'الملاحظات';

  @override
  String get addNoteAction => 'إضافة ملاحظة';

  @override
  String get addNoteTitle => 'إنشاء ملاحظة';

  @override
  String get editNoteTitle => 'تعديل الملاحظة';

  @override
  String get searchNotesHint => 'ابحث في الملاحظات';

  @override
  String get emptyNotesTitle => 'لا توجد ملاحظات بعد';

  @override
  String get emptyNotesDescription =>
      'سجّل أول فكرة أو ملخص محاضرة أو قائمة مراجعة.';

  @override
  String get contentLabel => 'المحتوى';

  @override
  String get pinNoteLabel => 'تثبيت هذه الملاحظة';

  @override
  String get saveNoteAction => 'حفظ الملاحظة';

  @override
  String get calendarTitle => 'المخطط';

  @override
  String get calendarSubtitle => 'تخطيط شهري وأسبوعي مع أجندة يومية.';

  @override
  String get monthFormatLabel => 'شهر';

  @override
  String get weekFormatLabel => 'أسبوع';

  @override
  String dailyAgendaTitle(String date) {
    return 'أجندة $date';
  }

  @override
  String get emptyAgendaDescription =>
      'لا توجد مهام أو جلسات تركيز مخططة لهذا اليوم.';

  @override
  String get focusTitle => 'وضع التركيز';

  @override
  String get focusSubtitle => 'استخدم جلسات بومودورو لتبقى مقصودًا ومتحفزًا.';

  @override
  String get focusModeLabel => 'جلسة تركيز';

  @override
  String get breakModeLabel => 'جلسة استراحة';

  @override
  String get startAction => 'ابدأ';

  @override
  String get pauseAction => 'إيقاف مؤقت';

  @override
  String get resumeAction => 'استئناف';

  @override
  String get resetAction => 'إعادة ضبط';

  @override
  String get customizeSessionTitle => 'تخصيص الجلسة';

  @override
  String focusDurationLabel(int minutes) {
    return 'مدة التركيز: $minutes دقيقة';
  }

  @override
  String breakDurationLabel(int minutes) {
    return 'مدة الاستراحة: $minutes دقيقة';
  }

  @override
  String get linkCourseOptionalLabel => 'اربط الجلسة بمقرر';

  @override
  String get focusHistoryTitle => 'سجل التركيز';

  @override
  String get focusHistorySubtitle =>
      'أحدث الجلسات المكتملة المحفوظة في خط تقدمك.';

  @override
  String get emptyFocusHistoryTitle => 'لا يوجد سجل تركيز بعد';

  @override
  String get emptyFocusHistoryDescription =>
      'ابدأ جلسة لتبدأ في تتبع إيقاع دراستك.';

  @override
  String get focusSessionCompleteMessage => 'اكتملت جلسة التركيز. عمل رائع.';

  @override
  String get analyticsTitle => 'التحليلات';

  @override
  String get weeklyFocusChartTitle => 'آخر 7 أيام';

  @override
  String get courseDistributionTitle => 'توزيع المقررات';

  @override
  String get miscLabel => 'متفرقات';

  @override
  String courseAnalyticsRow(String course, int minutes) {
    return '$course: $minutes دقيقة';
  }

  @override
  String get goalsTitle => 'الأهداف';

  @override
  String get studyGoalsTitle => 'أهداف الدراسة';

  @override
  String get saveGoalsAction => 'حفظ الأهداف';

  @override
  String get goalsSavedMessage => 'تم تحديث أهدافك.';

  @override
  String get dailyCheckInTitle => 'تسجيل يومي';

  @override
  String get dailyCheckInDescription =>
      'أضف جلسة قصيرة لتحافظ على اتصالك بأهدافك حتى في الأيام المزدحمة.';

  @override
  String get dailyCheckInAction => 'سجّل الآن';

  @override
  String get dailyCheckInSuccessMessage =>
      'تمت إضافة جلسة تسجيل سريعة إلى اليوم.';

  @override
  String get weeklyReviewTitle => 'المراجعة الأسبوعية';

  @override
  String get weeklyReviewDescription =>
      'مراجعة بسيطة تساعدك على ملاحظة التقدم وضبط خطة الأسبوع القادم.';

  @override
  String weeklyReviewSummary(int minutes, int tasks) {
    return 'درست هذا الأسبوع $minutes دقيقة وأنجزت $tasks مهام.';
  }

  @override
  String get profileFallbackName => 'طالب StudyFlow';

  @override
  String get editProfileAction => 'تعديل الملف الشخصي';

  @override
  String get profileOverviewTitle => 'نظرة عامة على الملف الشخصي';

  @override
  String get profileOverviewSubtitle =>
      'لقطة سريعة لهويتك الدراسية الحالية وزخمك.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get logoutAction => 'تسجيل الخروج';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get saveProfileAction => 'حفظ الملف الشخصي';

  @override
  String get languageSectionTitle => 'اللغة';

  @override
  String get englishLabel => 'الإنجليزية';

  @override
  String get turkishLabel => 'التركية';

  @override
  String get arabicLabel => 'العربية';

  @override
  String get themeSectionTitle => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get taskRemindersLabel => 'تذكيرات المهام';

  @override
  String get studyRemindersLabel => 'تذكيرات الدراسة';

  @override
  String get dailyReminderLabel => 'تذكير يومي';

  @override
  String get notificationPreviewTitle => 'تذكير StudyFlow';

  @override
  String get notificationPreviewBody =>
      'جلسة تركيز قصيرة قد تدفع يومك إلى الأمام.';

  @override
  String get previewNotificationAction => 'معاينة الإشعار';

  @override
  String get accessibilityPlaceholderTitle => 'دعم إمكانية الوصول';

  @override
  String get accessibilityPlaceholderDescription =>
      'يمكن توسيع هذا القسم لاحقًا لإعدادات النص الأكبر وتقليل الحركة ودعم التقنيات المساعدة.';
}

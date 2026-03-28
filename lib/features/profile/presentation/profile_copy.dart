import 'package:flutter/widgets.dart';

class ProfileCopy {
  const ProfileCopy(this.code);

  final String code;

  static ProfileCopy of(BuildContext context) =>
      ProfileCopy(Localizations.localeOf(context).languageCode);

  bool get _isTr => code == 'tr';
  bool get _isAr => code == 'ar';

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

  String get fallbackUserName => _pick(
        en: 'StudyFlow User',
        tr: 'StudyFlow Kullanıcısı',
        ar: 'مستخدم StudyFlow',
      );
  String get focusPlanner => _pick(
        en: 'Focus-driven planner',
        tr: 'Odak odaklı planlayıcı',
        ar: 'مخطط قائم على التركيز',
      );
  String get hciStudent => _pick(
        en: 'HCI student',
        tr: 'HCI öğrencisi',
        ar: 'طالب تفاعل إنسان وحاسوب',
      );
  String dayStreak(int days) => _pick(
        en: '$days day streak',
        tr: '$days günlük seri',
        ar: 'سلسلة $days يوم',
      );
  String get edit => _pick(
        en: 'Edit',
        tr: 'Düzenle',
        ar: 'تعديل',
      );
  String get defaultBio => _pick(
        en: 'Designing calm study weeks with focused sessions, visible progress, and low cognitive load.',
        tr: 'Odak seansları, görünür ilerleme ve düşük bilişsel yük ile sakin çalışma haftaları kuruyorum.',
        ar: 'أبني أسابيع دراسة هادئة بجلسات تركيز وتقدم واضح وحمل معرفي منخفض.',
      );
  String get weeklyFocus => _pick(
        en: 'Weekly focus',
        tr: 'Haftalık odak',
        ar: 'تركيز الأسبوع',
      );
  String get completedTasks => _pick(
        en: 'Completed tasks',
        tr: 'Tamamlanan görevler',
        ar: 'المهام المكتملة',
      );
  String get xpLevel => _pick(
        en: 'XP level',
        tr: 'XP seviyesi',
        ar: 'مستوى XP',
      );
  String get weeklyTarget => _pick(
        en: 'Weekly target',
        tr: 'Haftalık hedef',
        ar: 'هدف الأسبوع',
      );
  String get consistency => _pick(
        en: 'Consistency',
        tr: 'Tutarlılık',
        ar: 'الاستمرارية',
      );
  String get profileDepth => _pick(
        en: 'Profile depth',
        tr: 'Profil derinliği',
        ar: 'عمق الملف الشخصي',
      );
  String get taskCompletion => _pick(
        en: 'Task completion',
        tr: 'Görev tamamlama',
        ar: 'إكمال المهام',
      );
  String get habitsLocked => _pick(
        en: 'Habits completed',
        tr: 'Tamamlanan alışkanlıklar',
        ar: 'العادات المكتملة',
      );
  String get performancePulse => _pick(
        en: 'Performance pulse',
        tr: 'Performans özeti',
        ar: 'نبض الأداء',
      );
  String get performancePulseSubtitle => _pick(
        en: 'A compact summary of your weekly study rhythm and recovery capacity.',
        tr: 'Haftalık çalışma ritmini ve toparlanma kapasiteni özetleyen kompakt görünüm.',
        ar: 'ملخص مدمج لإيقاع دراستك الأسبوعي وقدرتك على الاستمرار.',
      );
  String focusMinutes(int value, int target) => _pick(
        en: '$value / $target minutes focused',
        tr: '$value / $target dakika odak',
        ar: '$value / $target دقيقة تركيز',
      );
  String get identityDetails => _pick(
        en: 'Identity details',
        tr: 'Kimlik detayları',
        ar: 'تفاصيل الهوية',
      );
  String get identityDetailsSubtitle => _pick(
        en: 'Designed to keep personal context visible without overwhelming the screen.',
        tr: 'Kişisel bağlamı ekranı yormadan görünür tutmak için tasarlandı.',
        ar: 'مصمم لإبقاء السياق الشخصي ظاهرًا من دون إرباك الشاشة.',
      );
  String get email => _pick(
        en: 'Email',
        tr: 'E-posta',
        ar: 'البريد الإلكتروني',
      );
  String get username => _pick(
        en: 'Username',
        tr: 'Kullanıcı adı',
        ar: 'اسم المستخدم',
      );
  String get university => _pick(
        en: 'University',
        tr: 'Üniversite',
        ar: 'الجامعة',
      );
  String get department => _pick(
        en: 'Department',
        tr: 'Bölüm',
        ar: 'القسم',
      );
  String get preferredLanguage => _pick(
        en: 'Preferred language',
        tr: 'Tercih edilen dil',
        ar: 'اللغة المفضلة',
      );
  String get notAddedYet => _pick(
        en: 'Not added yet',
        tr: 'Henüz eklenmedi',
        ar: 'لم تتم إضافته بعد',
      );
  String get achievementShelf => _pick(
        en: 'Achievement shelf',
        tr: 'Başarı rafı',
        ar: 'رف الإنجازات',
      );
  String get achievementSubtitle => _pick(
        en: 'Small wins stay visible so motivation becomes a system, not a memory.',
        tr: 'Küçük kazanımlar görünür kaldığında motivasyon bir sisteme dönüşür.',
        ar: 'تبقى الانتصارات الصغيرة ظاهرة حتى تصبح الدافعية نظامًا لا مجرد ذكرى.',
      );
  String get editProfile => _pick(
        en: 'Edit profile',
        tr: 'Profili düzenle',
        ar: 'تعديل الملف الشخصي',
      );
  String get editProfileSubtitle => _pick(
        en: 'Update avatar, bio, and academic identity',
        tr: 'Avatar, biyografi ve akademik kimliği güncelle',
        ar: 'حدّث الصورة والنبذة والهوية الأكاديمية',
      );
  String get passwordAndSecurity => _pick(
        en: 'Password and security',
        tr: 'Şifre ve güvenlik',
        ar: 'كلمة المرور والأمان',
      );
  String get passwordAndSecuritySubtitle => _pick(
        en: 'Theme, recovery, notifications, and account control',
        tr: 'Tema, kurtarma, bildirimler ve hesap yönetimi',
        ar: 'الثيم والاستعادة والإشعارات والتحكم بالحساب',
      );
  String get logOut => _pick(
        en: 'Log out',
        tr: 'Çıkış yap',
        ar: 'تسجيل الخروج',
      );
  String get uploading => _pick(
        en: 'Uploading...',
        tr: 'Yükleniyor...',
        ar: 'جارٍ الرفع...',
      );
  String get uploadPhoto => _pick(
        en: 'Upload photo',
        tr: 'Fotoğraf yükle',
        ar: 'رفع صورة',
      );
  String get uploadHint => _pick(
        en: 'Use a clean portrait for a stronger presentation identity.',
        tr: 'Sunumda daha güçlü bir kimlik için temiz bir portre kullan.',
        ar: 'استخدم صورة واضحة لتقديم هوية شخصية أقوى.',
      );
  String get firstName => _pick(
        en: 'First name',
        tr: 'Ad',
        ar: 'الاسم الأول',
      );
  String get lastName => _pick(
        en: 'Last name',
        tr: 'Soyad',
        ar: 'اسم العائلة',
      );
  String get bio => _pick(
        en: 'Bio',
        tr: 'Biyografi',
        ar: 'نبذة',
      );
  String get saveProfile => _pick(
        en: 'Save profile',
        tr: 'Profili kaydet',
        ar: 'حفظ الملف الشخصي',
      );
  String get managePreferences => _pick(
        en: 'Manage recovery, notifications, and theme preferences',
        tr: 'Kurtarma, bildirim ve tema tercihlerini yönet',
        ar: 'أدر الاستعادة والإشعارات وتفضيلات الثيم',
      );
  String get photoUpdatedMessage => _pick(
        en: 'Profile photo updated',
        tr: 'Profil fotoğrafı güncellendi',
        ar: 'تم تحديث صورة الملف الشخصي',
      );

  String achievementTitle(String id) {
    return switch (id) {
      'first-focus' => _pick(
          en: 'Focus Starter',
          tr: 'Odak başlangıcı',
          ar: 'بداية التركيز',
        ),
      'task-run' => _pick(
          en: 'Task Finisher',
          tr: 'Görev bitirici',
          ar: 'منهي المهام',
        ),
      'streak' => _pick(
          en: 'Consistency',
          tr: 'Tutarlılık',
          ar: 'الاستمرارية',
        ),
      'habit' => _pick(
          en: 'Ritual Builder',
          tr: 'Rutin kurucu',
          ar: 'باني العادات',
        ),
      _ => _pick(
          en: 'Achievement',
          tr: 'Başarı',
          ar: 'إنجاز',
        ),
    };
  }

  String achievementDescription(String id) {
    return switch (id) {
      'first-focus' => _pick(
          en: 'Complete 3 focus sessions',
          tr: '3 odak seansı tamamla',
          ar: 'أكمل 3 جلسات تركيز',
        ),
      'task-run' => _pick(
          en: 'Complete 5 tasks',
          tr: '5 görev tamamla',
          ar: 'أكمل 5 مهام',
        ),
      'streak' => _pick(
          en: 'Maintain a 4 day streak',
          tr: '4 günlük seriyi koru',
          ar: 'حافظ على سلسلة 4 أيام',
        ),
      'habit' => _pick(
          en: 'Complete 3 habits in one day',
          tr: 'Bir günde 3 alışkanlık tamamla',
          ar: 'أكمل 3 عادات في يوم واحد',
        ),
      _ => _pick(
          en: 'Keep progressing',
          tr: 'İlerlemeye devam et',
          ar: 'استمر في التقدم',
        ),
    };
  }
}

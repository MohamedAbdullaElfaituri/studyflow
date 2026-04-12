# Google Console + Supabase Setup

هذا هو المرجع الوحيد المعتمد لإعداد المشروع بعد التنظيف.

## 1. وضعيات التشغيل

- `Demo / Local`
  لا يحتاج مفاتيح Supabase.
  التطبيق يعمل ببيانات محلية آمنة داخل `SharedPreferences`.

- `Supabase / Cloud`
  يحتاج:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`

## 2. ملفات الإعداد المهمة

- [lib/core/constants/app_constants.dart](/c:/Users/moham/studyflow/lib/core/constants/app_constants.dart)
- [lib/core/services/supabase_service.dart](/c:/Users/moham/studyflow/lib/core/services/supabase_service.dart)
- [lib/shared/data/auth_repository.dart](/c:/Users/moham/studyflow/lib/shared/data/auth_repository.dart)
- [android/app/src/main/AndroidManifest.xml](/c:/Users/moham/studyflow/android/app/src/main/AndroidManifest.xml)
- [ios/Runner/Info.plist](/c:/Users/moham/studyflow/ios/Runner/Info.plist)

## 3. Supabase

### 3.1 إنشاء المشروع

1. افتح `https://supabase.com`
2. أنشئ مشروعًا جديدًا.
3. اختر المنطقة الأقرب لك.
4. بعد اكتمال الإنشاء افتح:
   `Project Settings -> API`

انسخ:

- `Project URL`
- `anon public key`

### 3.2 تفعيل Authentication

من داخل Supabase:

1. افتح `Authentication -> Providers`
2. فعّل `Email`
3. فعّل `Google`

لا تُكمل Google الآن قبل إنهاء قسم Google Cloud بالأسفل.

### 3.3 تشغيل الـ SQL

شغّل الملفات التالية بالترتيب داخل `SQL Editor`:

1. [supabase/migrations/001_initial_schema.sql](/c:/Users/moham/studyflow/supabase/migrations/001_initial_schema.sql)
2. [supabase/migrations/002_mobile_premium_upgrade.sql](/c:/Users/moham/studyflow/supabase/migrations/002_mobile_premium_upgrade.sql)

الملف الأول ينشئ الجداول الأساسية.
الملف الثاني يضيف الحقول الإضافية، achievements، notifications، وسياسات تخزين avatars.

### 3.4 ملف البيئة

استخدم أحد الخيارين:

`.env.example`

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
```

أو `.env.json`

```json
{
  "SUPABASE_URL": "https://your-project-ref.supabase.co",
  "SUPABASE_ANON_KEY": "your-public-anon-key"
}
```

ثم شغّل التطبيق:

```bash
flutter run --dart-define-from-file=.env.json
```

## 4. Google Cloud Console

### 4.1 إنشاء مشروع Google

1. افتح `https://console.cloud.google.com`
2. أنشئ مشروعًا جديدًا أو استخدم مشروعًا موجودًا.
3. افتح `APIs & Services`

### 4.2 OAuth Consent Screen

1. افتح `OAuth consent screen`
2. اختر `External`
3. عبئ:
   - App name
   - Support email
   - Developer contact email
4. أضف النطاقات المطلوبة إذا طلبت Google ذلك.
5. أضف حسابات الاختبار إذا كان التطبيق ما زال في وضع الاختبار.

### 4.3 إنشاء OAuth Client

من `Credentials`:

1. اختر `Create Credentials`
2. اختر `OAuth client ID`
3. اختر النوع:
   `Web application`

هذا مهم: مع Supabase Google provider نحن نستخدم `Web application` لأن Google سترجع إلى Supabase أولًا.

### 4.4 Authorized Redirect URI

أضف هذا الرابط داخل Google Cloud:

```text
https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback
```

بدّل `YOUR_PROJECT_REF` بالـ project ref الحقيقي من Supabase.

### 4.5 إدخال Google Client داخل Supabase

ارجع إلى:

`Supabase -> Authentication -> Providers -> Google`

ثم الصق:

- Google Client ID
- Google Client Secret

احفظ الإعداد.

## 5. Mobile Deep Links

التطبيق مضبوط مسبقًا على هذا الـ scheme:

```text
com.mohamedahmet.studyflow://login-callback/
```

### Android

تم ضبطه في:

- [android/app/src/main/AndroidManifest.xml](/c:/Users/moham/studyflow/android/app/src/main/AndroidManifest.xml)

القيم الحالية:

- package / application id: `com.mohamedahmet.studyflow`
- host: `login-callback`
- scheme: `com.mohamedahmet.studyflow`

### iOS

تم ضبطه في:

- [ios/Runner/Info.plist](/c:/Users/moham/studyflow/ios/Runner/Info.plist)

القيم الحالية:

- URL scheme: `com.mohamedahmet.studyflow`

إذا غيّرت اسم الحزمة أو bundle id مستقبلاً، غيّر هذه القيم في Android وiOS والكود معًا.

## 6. كيف يعمل Google Login داخل التطبيق

التدفق الحالي هو:

1. التطبيق يطلب `signInWithOAuth(Google)`
2. Supabase يفتح تدفق OAuth
3. Google ترجع إلى Supabase callback
4. Supabase يعيد الجلسة إلى التطبيق عبر:
   `com.mohamedahmet.studyflow://login-callback/`

الملف المسؤول:

- [lib/shared/data/auth_repository.dart](/c:/Users/moham/studyflow/lib/shared/data/auth_repository.dart)

## 7. Avatar Storage

سياسات التخزين الخاصة بالصور موجودة داخل migration الثاني.

الباكِت المطلوبة:

- `avatars`

والرفع يتم من:

- [lib/shared/data/auth_repository.dart](/c:/Users/moham/studyflow/lib/shared/data/auth_repository.dart)

## 8. فحص الجاهزية على iPhone و Samsung

نفّذ هذا checklist قبل أي نشر:

1. جرّب `Login`, `Signup`, `Forgot password`
2. جرّب تغيير اللغة بين `EN`, `AR`, `TR`
3. اختبر RTL كامل على العربية
4. اختبر safe areas على iPhone مع الـ bottom navigation
5. اختبر الشاشات الصغيرة على Samsung متوسطة وصغيرة الحجم
6. اختبر لوحة المفاتيح داخل `Auth`, `Task editor`, `Profile edit`
7. اختبر الإشعارات
8. اختبر رفع الصورة الشخصية
9. اختبر Google Login على جهاز حقيقي وليس emulator فقط

## 9. أوامر مفيدة

```bash
flutter pub get
flutter test
flutter analyze
flutter run
flutter run --dart-define-from-file=.env.json
flutter build apk --release
flutter build ios --release
```

## 10. مشاكل شائعة

### Google login يفتح ثم يرجع بدون جلسة

- تأكد من أن redirect URI داخل Google Cloud هو:
  `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`
- تأكد من تفعيل Google provider داخل Supabase
- تأكد من أن الـ scheme في Android وiOS يطابق الكود

### التطبيق يعمل Demo بدل Cloud

- تحقق من تمرير `--dart-define-from-file=.env.json`
- تأكد أن القيم ليست فارغة

### البيانات لا تظهر بعد تسجيل الدخول

- غالبًا الـ migrations لم تُشغّل
- أو سياسات RLS غير موجودة

### رفع الصورة لا يعمل

- تأكد من تشغيل migration الثاني
- تأكد من وجود bucket باسم `avatars`

## 11. توصية نهائية

لبيئة نظيفة:

- لا تضع أي مفاتيح حقيقية داخل `lib/`
- احتفظ بالمفاتيح داخل ملف محلي غير مرفوع
- استخدم `.env.json` محليًا فقط

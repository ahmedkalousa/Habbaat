# إعداد الخريطة في التطبيق

## المميزات المضافة:

1. **خريطة مجانية**: تم استخدام OpenStreetMap بدلاً من Google Maps لتوفير خريطة مجانية تماماً
2. **عرض موقع المساحة**: تعرض الخريطة موقع المساحة مع علامة مميزة
3. **تصميم جميل**: الخريطة محاطة بإطار جميل ومتناسق مع تصميم التطبيق

## التبعيات المضافة:

```yaml
flutter_map: ^7.0.2
latlong2: ^0.9.0
```

## كيفية الاستخدام:

### 1. إضافة إحداثيات للمساحة:
في نموذج Space، أضف حقول `latitude` و `longitude`:

```dart
final double? latitude;
final double? longitude;
```

### 2. في API Response:
أرسل الإحداثيات من السيرفر بهذا الشكل:

```json
{
  "id": 1,
  "name": "اسم المساحة",
  "latitude": 31.9539,
  "longitude": 35.9106,
  // ... باقي البيانات
}
```

### 3. عرض الخريطة:
الخريطة ستظهر تلقائياً في صفحة تفاصيل المساحة تحت الوصف.

## الأذونات المطلوبة:

### Android (android/app/src/main/AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS (ios/Runner/Info.plist):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>هذا التطبيق يحتاج إلى الوصول لموقعك لعرض الخرائط</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>هذا التطبيق يحتاج إلى الوصول لموقعك لعرض الخرائط</string>
```

## المميزات:

- ✅ خريطة مجانية تماماً
- ✅ لا تحتاج بطاقة ائتمان
- ✅ تعمل بدون إنترنت (مع التخزين المؤقت)
- ✅ تصميم جميل ومتجاوب
- ✅ دعم العربية
- ✅ علامات مميزة للمساحات

## ملاحظات:

1. إذا لم تكن الإحداثيات متوفرة، ستظهر رسالة مناسبة
2. الخريطة تستخدم OpenStreetMap وهي مجانية ومفتوحة المصدر
3. يمكن تخصيص تصميم العلامات والألوان حسب الحاجة 
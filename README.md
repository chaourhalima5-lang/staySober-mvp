# StaySober — دليل النشر (GitHub + Vercel)

منصة StaySober للتعافي من الإدمان والاندماج المهني — واجهة React متصلة بمشروع Supabase حقيقي.

---

## ⚠️ اقرئي هذا القسم أولًا — حدود ما تم التحقق منه فعليًا

هذا الهيكل (package.json، إعدادات Vite، الملف الشخصي...) **بُني الآن لأول مرة** — المشروع لم يكن له هيكل Node/npm حقيقي من قبل (كان يعمل كملف واحد داخل بيئة Claude.ai artifact). كل ملفات JSX تحققتُ من صحة صياغتها ببرنامج تحليل JS حقيقي (Sucrase)، **لكن لا أملك بيئة تشغيل فعلية لتنفيذ `npm install` أو `npm run build` والتأكد من نجاحهما 100% قبل تسليمها لك.** الخطوة الأولى الحقيقية لأي اختبار هي تنفيذ الأوامر أدناه بنفسك ومراقبة المخرجات.

---

## المتطلبات الأساسية

- **Node.js 18 أو أحدث** (تحققي بـ `node -v`)
- حساب **GitHub**
- حساب **Vercel** (يمكن الربط مباشرة بحساب GitHub)
- مشروع **Supabase** حقيقي جاهز (لديك بالفعل: قاعدة البيانات، RLS، Storage Buckets مُهيّأة من مراحل سابقة)

---

## 1) الإعداد المحلي والتحقق من نجاح البناء

```bash
# داخل مجلد المشروع
npm install
cp .env.example .env
```

افتحي `.env` وضعي القيم الحقيقية:
```
VITE_SUPABASE_URL=https://your-real-project.supabase.co
VITE_SUPABASE_ANON_KEY=sb_publishable_xxxxxxxxxxxxxxxx
```

ثم:
```bash
npm run dev
```
افتحي الرابط الذي يظهر (عادة `http://localhost:5173`) وتأكدي أن التطبيق يعمل ويتصل بمشروعك الحقيقي (جربي تسجيل الدخول بحساب حقيقي).

**قبل الرفع لأي مكان، تأكدي من نجاح البناء الفعلي:**
```bash
npm run build
```
إن ظهر أي خطأ هنا، **يجب** حله قبل المتابعة — هذا هو الاختبار الحقيقي الوحيد الذي لم أستطع إجراءه بنفسي.

---

## 2) الرفع إلى GitHub

```bash
git init
git add .
git commit -m "StaySober MVP — initial deployment-ready commit"
git branch -M main
git remote add origin https://github.com/USERNAME/REPO-NAME.git
git push -u origin main
```

**تأكدي أن ملف `.env` لم يُرفع** (هو مُستبعد بالفعل عبر `.gitignore`) — تحققي بـ:
```bash
git status
```
يجب ألا يظهر `.env` في القائمة إطلاقًا.

---

## 3) النشر على Vercel

### الطريقة الأسهل (لوحة التحكم):
1. [vercel.com/new](https://vercel.com/new) → اختاري المستودع من GitHub.
2. Vercel سيكتشف Vite تلقائيًا (بفضل `vercel.json` الموجود، ولأن Vite مدعوم افتراضيًا).
3. **قبل الضغط على Deploy** → افتحي "Environment Variables" وأضيفي:
   - `VITE_SUPABASE_URL` = رابط مشروعك الحقيقي
   - `VITE_SUPABASE_ANON_KEY` = المفتاح العام الحقيقي
4. اضغطي **Deploy**.

### أو عبر الطرفية:
```bash
npm install -g vercel
vercel login
vercel --prod
```
سيُطلب منك إدخال متغيرات البيئة نفسها أثناء الإعداد الأول.

---

## بنية المشروع

```
├── index.html          # نقطة الدخول HTML
├── src/
│   ├── main.jsx         # يُهيّئ React + طبقة توافق window.storage
│   └── App.jsx          # التطبيق كاملًا (لم يُعدَّل أي منطق أو تصميم فيه)
├── package.json
├── vite.config.js
├── vercel.json
├── .env.example
└── .gitignore
```

## ملاحظة تقنية مهمة: طبقة `window.storage`

الكود الأصلي استخدم `window.storage` — واجهة خاصة ببيئة Claude.ai، غير موجودة في أي متصفح حقيقي. أضفنا طبقة توافق صغيرة في `src/main.jsx` تُنفّذ نفس الواجهة تمامًا عبر `localStorage` الحقيقي، **دون تعديل حرف واحد** في كود `App.jsx` نفسه. النتيجة: كل بيانات الجلسة والتخزين المحلي تعمل كما كانت، لكن الآن بآلية حقيقية قابلة للنشر. ملاحظة عملية: بما أن `localStorage` مرتبط بمتصفح كل زائر على حدة، فإن أي بيانات "مشتركة" افتراضيًا في بيئة Claude.ai ستصبح خاصة بكل متصفح فرد الآن — وهذا هو السلوك الصحيح والمتوقع لتطبيق حقيقي منشور.

## التنظيف الذي تم

- إزالة كل الاعتماديات غير المستخدمة — الاعتماديات الفعلية فقط: `react`، `react-dom`، `lucide-react`، `recharts`.
- لا ملفات تجريبية أو مؤقتة في هذا الهيكل.

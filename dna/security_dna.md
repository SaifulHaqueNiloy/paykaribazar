# Security DNA [SYS-SECURITY-DNA] - [LOCKED STATUS: ACTIVE]
# নিরাপত্তা এবং সুরক্ষা প্রোটোকল (মাস্টার সংস্করণ - ১০০% ডেটা)

## ১. অথেনটিকেশন এবং রোল সিকিউরিটি [SEC-AUTH-MASTER]
- **Role-Based Access Control (RBAC):** ফায়ারস্টোর সিকিউরিটি রুলস এবং অ্যাপ লজিক উভয় লেভেলে ইউজারের রোল (Customer, Admin, Rider, etc.) চেক করা বাধ্যতামূলক।
- **JWT & Session:** ফায়ারবেস অথেনটিকেশন টোকেন ব্যবহার করে সেশন সিকিউরিটি নিশ্চিত করা হবে।
- **Sensitive Access:** অ্যাডমিন প্যানেলে প্রবেশের জন্য পুনরায় অথেনটিকেশন (Re-authentication) প্রোটোকল থাকবে।

## ২. ফায়ারস্টোর সিকিউরিটি রুলস [SEC-RULES-MASTER]
- **Ownership Rule:** ইউজার শুধুমাত্র তার নিজের ডেটা (`users/{uid}`, `orders/{uid}`) রিড/রাইট করতে পারবে।
- **Strict Lockdown:** `hub/data/` এবং `settings/` পাথে শুধুমাত্র `role == 'admin'` বা `role == 'staff'` রাইট পারমিশন পাবে।
- **Validation:** ডেটা রাইট করার সময় প্রতিটি ফিল্ডের টাইপ এবং ভ্যালু (যেমন: `price > 0`) রুলস দিয়ে ভ্যালিডেশন করা বাধ্যতামূলক।

## ৩. এআই মডারেশন এবং ফ্রড ডিটেকশন [SEC-AI-MOD]
- **Chat Moderation:** এআই রিয়েল-টাইমে চ্যাটে ব্যক্তিগত তথ্য (ফোন নম্বর, ক্রেডিট কার্ড) বা স্প্যাম লিংক ডিটেক্ট করবে এবং ব্লক করবে।
- **Rate Limiting:** `ApiQuotaService` ব্যবহার করে প্রতিটি ইউজারের জন্য এপিআই কল এবং অর্ডার লিমিট সেট করা থাকবে যাতে বোট (Bot) অ্যাটাক ঠেকানো যায়।

## ৪. সিক্রেটস এবং এনক্রিপশন [SEC-DATA-SAFE]
- **SecretsService:** এপিআই কী বা ক্লাউডিনারি সিক্রেট কখনোই হার্ডকোড করা যাবে না। এগুলো এনক্রিপ্টেড ডক হিসেবে `settings/secrets` পাথে থাকবে এবং সার্ভিস লেভেলে ডিক্রিপ্ট হবে।

## Change Log
- **2025-03-24:** Initial file lock. RBAC, Firestore Ownership Rules, AI Moderation, and Secrets Management strictly confirmed. No line removals allowed.

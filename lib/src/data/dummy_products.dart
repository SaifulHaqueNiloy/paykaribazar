import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CategoryInfo {
  final String name;
  final String nameBn;
  final IconData icon;
  final Color color;
  final List<SubCategoryInfo> subCategories;

  const CategoryInfo({
    required this.name,
    required this.nameBn,
    required this.icon,
    required this.color,
    required this.subCategories,
  });
}

class SubCategoryInfo {
  final String name;
  final String nameBn;
  final IconData icon;

  const SubCategoryInfo({
    required this.name,
    required this.nameBn,
    required this.icon,
  });
}

class DummyData {
  static const List<String> neuralSourceUrls = [
    'https://chaldal.com/',
    'https://www.shwapno.com/',
    'https://dailyshoppingbd.com/',
  ];

  static List<CategoryInfo> categories = [
    const CategoryInfo(
      name: 'Food',
      nameBn: 'খাবার',
      icon: Icons.restaurant_rounded,
      color: Colors.orange,
      subCategories: [
        SubCategoryInfo(name: 'Fruits & Vegetables', nameBn: 'ফল ও সবজি', icon: Icons.eco_rounded),
        SubCategoryInfo(name: 'Meat & Fish', nameBn: 'মাছ ও মাংস', icon: Icons.set_meal_rounded),
        SubCategoryInfo(name: 'Cooking Essentials', nameBn: 'রান্নার উপকরণ', icon: Icons.soup_kitchen_rounded),
        SubCategoryInfo(name: 'Dairy & Eggs', nameBn: 'ডিম ও দুগ্ধজাত', icon: Icons.egg_rounded),
        SubCategoryInfo(name: 'Beverages', nameBn: 'পানীয়', icon: Icons.local_drink_rounded),
        SubCategoryInfo(name: 'Snacks & Bakery', nameBn: 'নাস্তা ও বেকারি', icon: Icons.cookie_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Personal Care',
      nameBn: 'ব্যক্তিগত যত্ন',
      icon: Icons.face_rounded,
      color: Colors.teal,
      subCategories: [
        SubCategoryInfo(name: 'Skincare', nameBn: 'স্কিন কেয়ার', icon: Icons.face_retouching_natural_rounded),
        SubCategoryInfo(name: 'Haircare', nameBn: 'চুলের যত্ন', icon: Icons.brush_rounded),
        SubCategoryInfo(name: 'Oral Care', nameBn: 'ওরাল কেয়ার', icon: Icons.clean_hands_rounded),
        SubCategoryInfo(name: 'Hygiene', nameBn: 'হাইজিন', icon: Icons.sanitizer_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Cleaning Supplies',
      nameBn: 'পরিষ্কারক সামগ্রী',
      icon: Icons.cleaning_services_rounded,
      color: Colors.purple,
      subCategories: [
        SubCategoryInfo(name: 'Laundry', nameBn: 'লন্ড্রি', icon: Icons.waves_rounded),
        SubCategoryInfo(name: 'Kitchen & Floor', nameBn: 'রান্নাঘর ও ফ্লোর', icon: Icons.flatware_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Baby Care',
      nameBn: 'শিশুর যত্ন',
      icon: Icons.child_care_rounded,
      color: Colors.cyan,
      subCategories: [
        SubCategoryInfo(name: 'Diapers & Wipes', nameBn: 'ডায়াপার ও ওয়াইপস', icon: Icons.baby_changing_station_rounded),
        SubCategoryInfo(name: 'Baby Food', nameBn: 'বেবি ফুড', icon: Icons.child_friendly_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Home & Kitchen',
      nameBn: 'গৃহস্থালি',
      icon: Icons.home_rounded,
      color: Colors.brown,
      subCategories: [
        SubCategoryInfo(name: 'Electrical', nameBn: 'বৈদ্যুতিক', icon: Icons.lightbulb_rounded),
        SubCategoryInfo(name: 'Kitchen Accessories', nameBn: 'রান্নাঘরের সরঞ্জাম', icon: Icons.countertops_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Electronics',
      nameBn: 'ইলেকট্রনিক্স',
      icon: Icons.devices_other_rounded,
      color: Colors.blueAccent,
      subCategories: [
        SubCategoryInfo(name: 'Gadgets', nameBn: 'গ্যাজেট', icon: Icons.watch_rounded),
        SubCategoryInfo(name: 'Mobile Accessories', nameBn: 'মোবাইল এক্সেসরিজ', icon: Icons.phonelink_setup_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Fashion',
      nameBn: 'ফ্যাশন',
      icon: Icons.checkroom_rounded,
      color: Colors.pinkAccent,
      subCategories: [
        SubCategoryInfo(name: 'Men\'s Fashion', nameBn: 'ছেলেদের ফ্যাশন', icon: Icons.man_rounded),
        SubCategoryInfo(name: 'Women\'s Fashion', nameBn: 'মেয়েদের ফ্যাশন', icon: Icons.woman_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Stationery',
      nameBn: 'স্টেশনারি',
      icon: Icons.edit_note_rounded,
      color: Colors.blueGrey,
      subCategories: [
        SubCategoryInfo(name: 'Writing Tools', nameBn: 'লেখার সরঞ্জাম', icon: Icons.edit_rounded),
        SubCategoryInfo(name: 'Office Supplies', nameBn: 'অফিস সাপ্লাই', icon: Icons.inventory_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Health',
      nameBn: 'স্বাস্থ্য',
      icon: Icons.health_and_safety_rounded,
      color: Colors.redAccent,
      subCategories: [
        SubCategoryInfo(name: 'Wellness', nameBn: 'সুস্থতা', icon: Icons.spa_rounded),
        SubCategoryInfo(name: 'First Aid', nameBn: 'প্রাথমিক চিকিৎসা', icon: Icons.medical_services_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Toys & Games',
      nameBn: 'খেলনা ও গেম',
      icon: Icons.toys_rounded,
      color: Colors.indigo,
      subCategories: [
        SubCategoryInfo(name: 'Educational Toys', nameBn: 'শিক্ষামূলক খেলনা', icon: Icons.psychology_rounded),
        SubCategoryInfo(name: 'Outdoor Games', nameBn: 'বাইরের খেলা', icon: Icons.sports_kabaddi_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Sports',
      nameBn: 'খেলাধুলা',
      icon: Icons.sports_soccer_rounded,
      color: Colors.green,
      subCategories: [
        SubCategoryInfo(name: 'Fitness', nameBn: 'ফিটনেস', icon: Icons.fitness_center_rounded),
        SubCategoryInfo(name: 'Outdoor Sports', nameBn: 'আউটডোর স্পোর্টস', icon: Icons.terrain_rounded),
      ],
    ),
    const CategoryInfo(
      name: 'Pet Supplies',
      nameBn: 'পোষা প্রাণীর সামগ্রী',
      icon: Icons.pets_rounded,
      color: Colors.deepOrange,
      subCategories: [
        SubCategoryInfo(name: 'Pet Food', nameBn: 'পোষা প্রাণীর খাবার', icon: Icons.set_meal_rounded),
        SubCategoryInfo(name: 'Pet Accessories', nameBn: 'এক্সেসরিজ', icon: Icons.cruelty_free_rounded),
      ],
    ),
  ];

  static List<Product> products = [
    ..._generateFoodProducts(),
    ..._generatePersonalCareProducts(),
    ..._generateCleaningProducts(),
    ..._generateBabyCareProducts(),
    ..._generateHomeKitchenProducts(),
    ..._generateElectronicsProducts(),
    ..._generateFashionProducts(),
    ..._generateStationeryProducts(),
    ..._generateHealthProducts(),
    ..._generateToyProducts(),
    ..._generateSportProducts(),
    ..._generatePetProducts(),
    ..._generateGroceryProductsWithVariants(),
  ];

  static List<Product> _generateFoodProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final fv = [
      ('fv_1', 'Onion (Deshi)', 'দেশি পেঁয়াজ', 110.0, 120.0, '1 kg', '১ কেজি', 'Fruits & Vegetables', [
        'https://images.unsplash.com/photo-1508747703725-719777637510?q=80&w=500',
        'https://images.unsplash.com/photo-1618512496248-a07fe83aa830?q=80&w=500',
        'https://images.unsplash.com/photo-1587049633562-ad3002f38a7a?q=80&w=500'
      ]),
      ('fv_2', 'Potato (Goal Alu)', 'গোল আলু', 65.0, 75.0, '1 kg', '১ কেজি', 'Fruits & Vegetables', [
        'https://images.unsplash.com/photo-1518977676601-b53f02bad177?q=80&w=500',
        'https://images.unsplash.com/photo-1590165482129-1b8b27698780?q=80&w=500',
        'https://images.unsplash.com/photo-1552056752-088191955ec1?q=80&w=500'
      ]),
      ('fv_3', 'Tomato (Fresh)', 'তাজা টমেটো', 140.0, 160.0, '1 kg', '১ কেজি', 'Fruits & Vegetables', [
        'https://images.unsplash.com/photo-1546473427-e1ad63bb639a?q=80&w=500',
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?q=80&w=500',
        'https://images.unsplash.com/photo-1558818498-28c1e002b655?q=80&w=500'
      ]),
      ('fv_4', 'Apple (Gala)', 'গালা আপেল', 320.0, 350.0, '1 kg', '১ কেজি', 'Fruits & Vegetables', [
        'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?q=80&w=500',
        'https://images.unsplash.com/photo-1570913149827-d2ac84ab3f9a?q=80&w=500',
        'https://images.unsplash.com/photo-1619546813926-a78fa6372cd2?q=80&w=500'
      ]),
      ('fv_5', 'Banana (Sagor)', 'সাগর কলা', 120.0, 140.0, '12 pcs', '১২ পিস', 'Fruits & Vegetables', [
        'https://images.unsplash.com/photo-1571771894821-ad9b5886479b?q=80&w=500',
        'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?q=80&w=500',
        'https://images.unsplash.com/photo-1528825831135-339165883daa?q=80&w=500'
      ]),
      ('mf_1', 'Broiler Chicken', 'ব্রয়লার মুরগি', 190.0, 210.0, '1 kg', '১ কেজি', 'Meat & Fish', [
        'https://images.unsplash.com/photo-1587593817647-17c09132699a?q=80&w=500',
        'https://images.unsplash.com/photo-1604503468506-a8da13d82791?q=80&w=500',
        'https://images.unsplash.com/photo-1606728035253-49e196711593?q=80&w=500'
      ]),
      ('mf_2', 'Beef (Standard)', 'গরুর মাংস', 750.0, 800.0, '1 kg', '১ কেজি', 'Meat & Fish', [
        'https://images.unsplash.com/photo-1588168333986-5078d3ae3973?q=80&w=500',
        'https://images.unsplash.com/photo-1603048588665-791ca8aea617?q=80&w=500',
        'https://images.unsplash.com/photo-1602470520998-f4a52199a3d6?q=80&w=500'
      ]),
      ('ce_1', 'Soyabean Oil', 'সয়াবিন তেল', 165.0, 175.0, '1 L', '১ লিটার', 'Cooking Essentials', [
        'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?q=80&w=500',
        'https://images.unsplash.com/photo-1466633393038-c25340bc63d0?q=80&w=500',
        'https://images.unsplash.com/photo-1589330694653-ded6df53f6ee?q=80&w=500'
      ]),
      ('de_1', 'Farm Eggs', 'মুরগির ডিম', 145.0, 155.0, '12 pcs', '১২ পিস', 'Dairy & Eggs', [
        'https://images.unsplash.com/photo-1506976785307-8732e854ad03?q=80&w=500',
        'https://images.unsplash.com/photo-1582722872445-44c501f30801?q=80&w=500',
        'https://images.unsplash.com/photo-1518569109129-ef487771cc43?q=80&w=500'
      ]),
    ];
    for (var item in fv) {
      list.add(Product(
        id: item.$1, sku: 'FOOD-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 500, categoryId: 'food', categoryName: 'Food', subCategoryName: item.$8,
        description: 'Premium quality ${item.$2}.', descriptionBn: 'উন্নত মানের ${item.$3}।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generatePersonalCareProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final pc = [
      ('pc_1', 'Lifebuoy Soap', 'লাইফবয় সাবান', 75.0, 85.0, '150 g', '১৫০ গ্রাম', 'Hygiene', [
        'https://images.unsplash.com/photo-1554462418-c5446df81b8e?q=80&w=500',
        'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?q=80&w=500',
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=500'
      ]),
      ('pc_2', 'Sunsilk Shampoo', 'সানসিল্ক শ্যাম্পু', 350.0, 380.0, '375 ml', '৩৭৫ মিলি', 'Haircare', [
        'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?q=80&w=500',
        'https://images.unsplash.com/photo-1526947425960-945c6e72858f?q=80&w=500',
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=500'
      ]),
      ('pc_3', 'Pepsodent Toothpaste', 'পেপসোডেন্ট টুথপেস্ট', 185.0, 210.0, '200 g', '২০০ গ্রাম', 'Oral Care', [
        'https://images.unsplash.com/photo-1559591937-e68d063d863f?q=80&w=500',
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?q=80&w=500',
        'https://images.unsplash.com/photo-1563453392212-326f5e854473?q=80&w=500'
      ]),
    ];
    for (var item in pc) {
      list.add(Product(
        id: item.$1, sku: 'PC-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 300, categoryId: 'personal_care', categoryName: 'Personal Care', subCategoryName: item.$8,
        description: 'Authentic ${item.$2}.', descriptionBn: 'আসল ${item.$3}।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generateCleaningProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final cs = [
      ('cs_1', 'Wheel Powder', 'হুইল পাউডার', 110.0, 125.0, '1 kg', '১ কেজি', 'Laundry', [
        'https://images.unsplash.com/photo-1584622781564-1d9876a13d00?q=80&w=500',
        'https://images.unsplash.com/photo-1551462147-37885acc3c41?q=80&w=500'
      ]),
      ('cs_2', 'Vim Liquid', 'ভিম লিকুইড', 120.0, 135.0, '500 ml', '৫০০ মিলি', 'Kitchen & Floor', [
        'https://images.unsplash.com/photo-1563453392212-326f5e854473?q=80&w=500',
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=500'
      ]),
    ];
    for (var item in cs) {
      list.add(Product(
        id: item.$1, sku: 'CS-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 400, categoryId: 'cleaning_supplies', categoryName: 'Cleaning Supplies', subCategoryName: item.$8,
        description: 'Effective cleaning with ${item.$2}.', descriptionBn: '${item.$3} দিয়ে কার্যকর পরিষ্কার।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generateBabyCareProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final bc = [
      ('bc_1', 'Pampers L', 'প্যাম্পার্স ডায়াপার', 1450.0, 1600.0, '44 pcs', '৪৪ পিস', 'Diapers & Wipes', [
        'https://images.unsplash.com/photo-1544126592-807daa215a75?q=80&w=500',
        'https://images.unsplash.com/photo-1617331721458-bd3bd3f9c7f8?q=80&w=500'
      ]),
    ];
    for (var item in bc) {
      list.add(Product(
        id: item.$1, sku: 'BC-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 200, categoryId: 'baby_care', categoryName: 'Baby Care', subCategoryName: item.$8,
        description: 'Gentle care for your baby with ${item.$2}.', descriptionBn: '${item.$3} দিয়ে আপনার শিশুর কোমল যত্ন।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generateHomeKitchenProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final hk = [
      ('hk_1', 'LED Bulb 12W', 'এলইডি বাল্ব', 180.0, 220.0, '1 pc', '১ পিস', 'Electrical', [
        'https://images.unsplash.com/photo-1550985616-10810253b84d?q=80&w=500',
        'https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?q=80&w=500'
      ]),
    ];
    for (var item in hk) {
      list.add(Product(
        id: item.$1, sku: 'HK-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 300, categoryId: 'home_kitchen', categoryName: 'Home & Kitchen', subCategoryName: item.$8,
        description: 'Essential ${item.$2} for home.', descriptionBn: 'গৃহের জন্য প্রয়োজনীয় ${item.$3}।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generateElectronicsProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final el = [
      ('el_1', 'Smart Watch 8', 'স্মার্ট ওয়াচ', 2500.0, 3000.0, '1 pc', '১ পিস', 'Gadgets', [
        'https://images.unsplash.com/photo-1544117518-30dd5ff7a986?q=80&w=500',
        'https://images.unsplash.com/photo-1508685096489-77a4ad2ba220?q=80&w=500'
      ]),
    ];
    for (var item in el) {
      list.add(Product(
        id: item.$1, sku: 'EL-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 100, categoryId: 'electronics', categoryName: 'Electronics', subCategoryName: item.$8,
        description: 'High tech ${item.$2}.', descriptionBn: 'আধুনিক প্রযুক্তির ${item.$3}।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generateFashionProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final fashion = [
      ('fa_1', 'Men\'s T-Shirt', 'ছেলেদের টি-শার্ট', 450.0, 600.0, '1 pc', '১ পিস', 'Men\'s Fashion', [
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=500',
        'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?q=80&w=500'
      ]),
    ];
    for (var item in fashion) {
      list.add(Product(
        id: item.$1, sku: 'FA-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 150, categoryId: 'fashion', categoryName: 'Fashion', subCategoryName: item.$8,
        description: 'Stylish ${item.$2}.', descriptionBn: 'স্টাইলিশ ${item.$3}।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generateStationeryProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final st = [
      ('st_1', 'Ballpoint Pen', 'বলপয়েন্ট কলম', 10.0, 12.0, '1 pc', '১ পিস', 'Writing Tools', [
        'https://images.unsplash.com/photo-1585336261022-69c66d11d2b2?q=80&w=500'
      ]),
    ];
    for (var item in st) {
      list.add(Product(
        id: item.$1, sku: 'ST-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 500, categoryId: 'stationery', categoryName: 'Stationary', subCategoryName: item.$8,
        description: 'Useful ${item.$2} for study and work.', descriptionBn: 'পড়ালেখা ও কাজের জন্য দরকারী ${item.$3}।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generateHealthProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final hl = [
      ('hl_1', 'Vitamin C', 'ভিটামিন সি', 150.0, 180.0, '30 tabs', '৩০ ট্যাব', 'Wellness', [
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=500'
      ]),
    ];
    for (var item in hl) {
      list.add(Product(
        id: item.$1, sku: 'HL-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 250, categoryId: 'health', categoryName: 'Health', subCategoryName: item.$8,
        description: 'Health and wellness product: ${item.$2}.', descriptionBn: 'স্বাস্থ্য ও সুস্থতার পণ্য: ${item.$3}।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generateToyProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final toys = [
      ('ty_1', 'Building Blocks', 'বিল্ডিং ব্লক', 850.0, 1200.0, '1 set', '১ সেট', 'Educational Toys', [
        'https://images.unsplash.com/photo-1587654780291-39c9404d746b?q=80&w=500'
      ]),
    ];
    for (var item in toys) {
      list.add(Product(
        id: item.$1, sku: 'TOY-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 100, categoryId: 'toys_games', categoryName: 'Toys & Games', subCategoryName: item.$8,
        description: 'Fun and safe ${item.$2}.', descriptionBn: 'মজাদার ও নিরাপদ ${item.$3}।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generateSportProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final sports = [
      ('sp_1', 'Yoga Mat', 'ইয়োগা ম্যাট', 650.0, 850.0, '1 pc', '১ পিস', 'Fitness', [
        'https://images.unsplash.com/photo-1592432676556-26d1773e3b7c?q=80&w=500'
      ]),
    ];
    for (var item in sports) {
      list.add(Product(
        id: item.$1, sku: 'SP-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 200, categoryId: 'sports', categoryName: 'Sports', subCategoryName: item.$8,
        description: 'Professional ${item.$2}.', descriptionBn: 'পেশাদারী ${item.$3}।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generatePetProducts() {
    final List<Product> list = [];
    final now = DateTime.now();
    final pets = [
      ('pt_1', 'Cat Food (1.2kg)', 'বিড়ালের খাবার', 450.0, 550.0, '1 pack', '১ প্যাক', 'Pet Food', [
        'https://images.unsplash.com/photo-1589924691106-07a21a4d5357?q=80&w=500'
      ]),
    ];
    for (var item in pets) {
      list.add(Product(
        id: item.$1, sku: 'PET-${item.$1.toUpperCase()}', name: item.$2, nameBn: item.$3,
        price: item.$4, oldPrice: item.$5, unit: item.$6, unitBn: item.$7, imageUrl: 'https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all',
        imageUrls: ['https://loremflickr.com/600/600/product,${item.$2.replaceAll(' ', ',')}/all'],
        stock: 150, categoryId: 'pet_supplies', categoryName: 'Pet Supplies', subCategoryName: item.$8,
        description: 'High quality ${item.$2}.', descriptionBn: 'উন্নত মানের ${item.$3}।',
        createdAt: now, updatedAt: now,
      ));
    }
    return list;
  }

  static List<Product> _generateGroceryProductsWithVariants() {
    final List<Product> list = [];
    final now = DateTime.now();
    list.add(Product(
      id: 'gro_oil_1',
      sku: 'GRO-OIL-RUP',
      name: 'Rupchanda Oil',
      nameBn: 'রুপচাঁদা তেল',
      description: 'Healthy soyabean oil.',
      descriptionBn: 'স্বাস্থ্যকর সয়াবিন তেল।',
      price: 165.0, 
      oldPrice: 175.0,
      stock: 500,
      unit: '1 L',
      unitBn: '১ লিটার',
      imageUrl: 'https://loremflickr.com/600/600/product,rupchanda,oil/all',
      imageUrls: [
        'https://loremflickr.com/600/600/product,rupchanda,oil/all',
      ],
      categoryId: 'food',
      categoryName: 'Food',
      subCategoryName: 'Cooking Essentials',
      variants: [
        Variant(id: 'v1', name: '1 L', nameBn: '১ লিটার', price: 165.0, stock: 200),
        Variant(id: 'v2', name: '2 L', nameBn: '২ লিটার', price: 325.0, stock: 150),
        Variant(id: 'v3', name: '5 L', nameBn: '৫ লিটার', price: 810.0, stock: 100),
      ],
      createdAt: now,
      updatedAt: now,
    ));
    list.add(Product(
      id: 'gro_milk_1',
      sku: 'GRO-MILK-DANO',
      name: 'Dano Milk',
      nameBn: 'ডানো দুধ',
      description: 'Full cream milk powder.',
      descriptionBn: 'ফুল ক্রিম দুধের গুঁড়ো।',
      price: 450.0,
      oldPrice: 480.0,
      stock: 300,
      unit: '500 g',
      unitBn: '৫০০ গ্রাম',
      imageUrl: 'https://loremflickr.com/600/600/product,dano,milk/all',
      imageUrls: [
        'https://loremflickr.com/600/600/product,dano,milk/all',
      ],
      categoryId: 'food',
      categoryName: 'Food',
      subCategoryName: 'Dairy & Eggs',
      variants: [
        Variant(id: 'mv1', name: '500 g', nameBn: '৫০০ গ্রাম', price: 450.0, stock: 100),
        Variant(id: 'mv2', name: '1 kg', nameBn: '১ কেজি', price: 880.0, stock: 80),
      ],
      createdAt: now,
      updatedAt: now,
    ));
    return list;
  }
}

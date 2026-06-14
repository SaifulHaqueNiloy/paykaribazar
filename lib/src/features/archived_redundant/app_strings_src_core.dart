class AppStrings {
  // Admin Section
  static const String adminDashboard = 'Admin Dashboard';
  static const String analytics = 'Analytics';
  static const String categories = 'Categories';
  static const String products = 'Products';
  static const String orders = 'Orders';
  static const String users = 'Users';
  static const String settings = 'Settings';
  
  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  
  // Analytics
  static const String totalSales = 'Total Sales';
  static const String totalOrders = 'Total Orders';
  static const String totalUsers = 'Total Users';
  static const String lowStockAlert = 'Low Stock Alert';
  static const String restockLevelsStable = 'Restock levels are stable.';

  // Localization map
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'adminDashboard': 'Admin Dashboard',
      'analytics': 'Analytics',
      'categories': 'Categories',
      'products': 'Products',
      'orders': 'Orders',
      'users': 'Users',
      'settings': 'Settings',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'totalSales': 'Total Sales',
      'totalOrders': 'Total Orders',
      'totalUsers': 'Total Users',
      'lowStockAlert': 'Low Stock Alert',
      'restockLevelsStable': 'Restock levels are stable.',
      'sales_overview': 'Sales Overview',
      'myOrders': 'My Orders',
      'noOrdersFound': 'No orders found',
    },
    'bn': {
      'adminDashboard': 'অ্যাডমিন ড্যাশবোর্ড',
      'analytics': 'অ্যানালিটিক্স',
      'categories': 'ক্যাটাগরি',
      'products': 'পণ্যসমূহ',
      'orders': 'অর্ডারসমূহ',
      'users': 'ব্যবহারকারী',
      'settings': 'সেটিংস',
      'save': 'সংরক্ষণ করুন',
      'cancel': 'বাতিল করুন',
      'delete': 'মুছে ফেলুন',
      'edit': 'সম্পাদনা করুন',
      'add': 'যোগ করুন',
      'search': 'খুঁজুন',
      'loading': 'লোড হচ্ছে...',
      'error': 'ত্রুটি',
      'success': 'সফল হয়েছে',
      'totalSales': 'মোট বিক্রি',
      'totalOrders': 'মোট অর্ডার',
      'totalUsers': 'মোট ব্যবহারকারী',
      'lowStockAlert': 'অল্প স্টকের সতর্কতা',
      'restockLevelsStable': 'স্টক লেভেল স্থিতিশীল আছে।',
      'sales_overview': 'বিক্রির ওভারভিউ',
      'myOrders': 'আমার অর্ডারসমূহ',
      'noOrdersFound': 'কোনো অর্ডার পাওয়া যায়নি',
    }
  };

  static String get(String key, String lang) {
    return _localizedValues[lang]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

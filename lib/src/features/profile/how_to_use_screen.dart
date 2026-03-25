import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../services/language_provider.dart';
import '../../utils/styles.dart';

class HowToUseScreen extends StatefulWidget {
  const HowToUseScreen({super.key});

  @override
  State<HowToUseScreen> createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = ProviderScope.containerOf(context).read(languageProvider).languageCode == 'bn';

    final List<Map<String, String>> steps = [
      {
        'title': isBn ? 'কেনাকাটা শুরু করুন' : 'Start Shopping',
        'desc': isBn 
            ? 'হোম পেজ থেকে আপনার পছন্দের পণ্য বেছে নিন এবং সরাসরি কার্টে যোগ করুন।' 
            : 'Explore our vast catalog and add products to your cart with one tap.',
        'icon': 'assets/lottie/welcome.json', // Placeholder, use existing or generic
      },
      {
        'title': isBn ? 'এআই সার্চ ব্যবহার করুন' : 'AI Powered Search',
        'desc': isBn 
            ? 'ভয়েস বা ইমেজ দিয়ে খুব সহজে কাঙ্ক্ষিত পণ্যটি খুঁজে বের করুন।' 
            : 'Find what you need faster using Voice or Image-based AI search.',
        'icon': 'assets/lottie/welcome.json',
      },
      {
        'title': isBn ? 'জরুরি সেবা' : 'Emergency Services',
        'desc': isBn 
            ? 'রক্তের প্রয়োজন বা জরুরি ঔষধের জন্য আমাদের ডেডিকেটেড ট্যাব ব্যবহার করুন।' 
            : 'Get instant access to blood donors and medicine delivery when it matters most.',
        'icon': 'assets/lottie/welcome.json',
      },
      {
        'title': isBn ? 'পয়েন্ট ও রিওয়ার্ড' : 'Loyalty & Rewards',
        'desc': isBn 
            ? 'প্রতিটি অর্ডারে পয়েন্ট পান এবং পরবর্তী কেনাকাটায় ডিসকাউন্ট উপভোগ করুন।' 
            : 'Earn loyalty points on every purchase and redeem them for massive discounts.',
        'icon': 'assets/lottie/welcome.json',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: steps.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, i) => _buildPage(steps[i], isDark),
          ),
          
          // Navigation Controls
          Positioned(
            bottom: 50,
            left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isBn ? 'বাদ দিন' : 'Skip', style: const TextStyle(color: Colors.grey)),
                ),
                Row(
                  children: List.generate(steps.length, (i) => _buildIndicator(i == _currentPage)),
                ),
                CircleAvatar(
                  backgroundColor: AppStyles.primaryColor,
                  radius: 28,
                  child: IconButton(
                    icon: Icon(_currentPage == steps.length - 1 ? Icons.check : Icons.arrow_forward_rounded, color: Colors.white),
                    onPressed: () {
                      if (_currentPage < steps.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, String> step, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(step['icon']!, height: 250),
          const SizedBox(height: 40),
          Text(
            step['title']!,
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.w900, 
              color: isDark ? Colors.white : Colors.black87
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            step['desc']!,
            style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: active ? 24 : 8,
      decoration: BoxDecoration(
        color: active ? AppStyles.primaryColor : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

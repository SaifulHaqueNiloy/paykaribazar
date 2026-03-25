class SearchUtils {
  static const Map<String, String> _phoneticMap = {
    // Vowels & Variations
    'aa': 'আ', 'a': 'অ', 'i': 'ই', 'ee': 'ঈ', 'u': 'উ', 'oo': 'ঊ',
    'ri': 'ঋ', 'e': 'এ', 'oi': 'ঐ', 'o': 'ও', 'ou': 'ঔ',
    
    // Consonants with common Banglish variations
    'kh': 'খ', 'k': 'ক', 'gh': 'ঘ', 'g': 'গ', 'ng': 'ঙ',
    'chh': 'ছ', 'ch': 'চ', 'jh': 'ঝ', 'j': 'জ', 'ny': 'ঞ',
    'th': 'ঠ', 't': 'ট', 'dh': 'ঢ', 'd': 'ড', 'n': 'ণ',
    'Th': 'থ', 'T': 'ত', 'Dh': 'ধ', 'D': 'দ', 'N': 'ন',
    'ph': 'ফ', 'p': 'প', 'bh': 'ভ', 'b': 'ব', 'm': 'ম',
    'sh': 'শ', 'S': 'ষ', 's': 'স', 'h': 'হ',
    'rh': 'ঢ়', 'r': 'র', 'y': 'য়', 'l': 'ল',
    
    // Extra Banglish common patterns
    'v': 'ভ', 'f': 'ফ', 'z': 'জ', 'w': 'ও', 'x': 'ক্স',
  };

  /// Advanced Phonetic Converter for Banglish to Bangla
  static String toBangla(String input) {
    String output = input.toLowerCase();
    
    // Handle double-character sounds first to prevent single-character overwrite
    final sortedKeys = _phoneticMap.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    
    for (var key in sortedKeys) {
      output = output.replaceAll(key, _phoneticMap[key]!);
    }
    
    // Clean up Jukto-Borno hints (simplified)
    output = output.replaceAll('্', ''); 
    
    return output;
  }

  /// Pro-active Smart Match with higher Banglish priority
  static bool smartMatch(String query, String name, String nameBn) {
    if (query.isEmpty) return true;
    
    final q = query.toLowerCase().trim();
    final n = name.toLowerCase();
    final nBn = nameBn.trim();

    // 1. Exact Match in English or Bangla (Highest Priority)
    if (n.contains(q) || nBn.contains(q)) return true;

    // 2. Advanced Phonetic Match (Banglish)
    final phonetic = toBangla(q);
    if (nBn.contains(phonetic)) return true;

    // 3. Normalized Match (Remove spaces/special chars for messy typers)
    final normalizedQ = q.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final normalizedN = n.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (normalizedN.contains(normalizedQ)) return true;

    // 4. Word-by-word Match (If user types "Dettol Sabun" for "Dettol Soap")
    final queryWords = q.split(' ');
    if (queryWords.length > 1) {
      bool allWordsMatch = true;
      for (var word in queryWords) {
        if (!smartMatch(word, name, nameBn)) {
          allWordsMatch = false;
          break;
        }
      }
      if (allWordsMatch) return true;
    }

    return false;
  }
}

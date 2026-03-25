import 'package:flutter_test/flutter_test.dart';
import 'package:paykari_bazar/src/core/services/encryption_service.dart';

void main() {
  group('EncryptionService Unit Tests', () {
    late EncryptionService encryptionService;

    setUp(() {
      encryptionService = EncryptionService();
    });

    test('Encrypt and Decrypt String', () {
      const plainText = 'Hello Paykari Bazar!';
      final encrypted = encryptionService.encrypt(plainText);
      final decrypted = encryptionService.decrypt(encrypted);

      expect(decrypted, equals(plainText));
      expect(encrypted, isNot(equals(plainText)));
    });

    test('Encrypt and Decrypt JSON', () {
      final data = {
        'id': '123',
        'name': 'Niloy',
        'points': 100,
      };
      
      final encrypted = encryptionService.encryptJson(data);
      final decrypted = encryptionService.decryptJson(encrypted);

      expect(decrypted['id'], equals(data['id']));
      expect(decrypted['name'], equals(data['name']));
      expect(decrypted['points'], equals(data['points']));
    });

    test('PII Data Encryption', () {
      const email = 'test@example.com';
      const phone = '01712345678';
      
      final encrypted = encryptionService.encryptPII(
        userId: 'user_1',
        email: email,
        phone: phone,
      );
      
      final decrypted = encryptionService.decryptPII(encrypted);
      
      expect(decrypted['email'], equals(email));
      expect(decrypted['phone'], equals(phone));
    });
  });
}

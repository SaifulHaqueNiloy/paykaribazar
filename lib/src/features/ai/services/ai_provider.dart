import '../domain/ai_work_type.dart';

abstract class AIProvider {
  String get name;
  Future<bool> healthCheck();
  Future<String> generate(String prompt, {AiWorkType? type});
  Stream<String> generateStream(String prompt, {AiWorkType? type});
}

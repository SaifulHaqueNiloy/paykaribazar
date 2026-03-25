import '../exports.dart';
import '../mixins/common_methods.dart';

abstract class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key});
}

abstract class BaseScreenState<T extends BaseScreen> extends ConsumerState<T> with CommonMethods {
  bool get tapOutsideToDismissKeyboard => false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapOutsideToDismissKeyboard ? () => FocusScope.of(context).unfocus() : null,
      child: buildScreen(context),
    );
  }

  Widget buildScreen(BuildContext context);
  
  void showLoading() {
    // Implement global loading overlay logic
  }

  void hideLoading() {
    // Implement global loading overlay logic
  }
}

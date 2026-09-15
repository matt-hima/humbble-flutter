import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

enum AppLanguage { zhTw, en, ja }

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.zhTw;
  void select(AppLanguage language) => state = language;
}

class Strings {
  const Strings(this.language);
  final AppLanguage language;
  String get code => switch (language) {
    AppLanguage.zhTw => '繁中',
    AppLanguage.en => 'EN',
    AppLanguage.ja => '日本語',
  };
  String get appName => '交友台北';
  String get poweredBy => '美圖境界 Glass&Frame';
  String get signIn => _t('登入', 'Sign in', 'ログイン');
  String get signUp => _t('建立帳號', 'Create account', 'アカウント作成');
  String get welcome => _t('歡迎回來', 'Welcome back', 'おかえりなさい');
  String get photoRule => _t(
    '個人照片僅限在美圖境界拍貼機現場拍攝。',
    'Profile photos can only be captured at the 美圖境界 photobooth.',
    'プロフィール写真は美圖境界のフォトブースでのみ撮影できます。',
  );
  String get capturePhoto => _t('現場拍攝照片', 'Capture booth photo', 'ブースで撮影');
  String get locationRequired => _t(
    '請在頂好名店城 4 樓的美圖境界拍貼機現場拍攝。',
    'Please capture at the 美圖境界 photobooth on the 4th floor of 頂好名店城.',
    '頂好名店城4階の美圖境界フォトブースで撮影してください。',
  );
  String get discover => _t('探索', 'Discover', '見つける');
  String get people => _t('交友', 'People', '出会い');
  String get chats => _t('聊天', 'Chats', 'チャット');
  String get profile => _t('個人檔案', 'Profile', 'プロフィール');
  String get email => _t('電子郵件', 'Email', 'メール');
  String get password => _t('密碼', 'Password', 'パスワード');
  String get name => _t('你的名字', 'Your name', 'お名前');
  String _t(String zh, String en, String ja) => switch (language) {
    AppLanguage.zhTw => zh,
    AppLanguage.en => en,
    AppLanguage.ja => ja,
  };
}

class LanguageMenu extends ConsumerWidget {
  const LanguageMenu({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    return PopupMenuButton<AppLanguage>(
      tooltip: 'Language',
      initialValue: language,
      onSelected: (value) => ref.read(languageProvider.notifier).select(value),
      itemBuilder: (_) => const [
        PopupMenuItem(value: AppLanguage.zhTw, child: Text('繁體中文')),
        PopupMenuItem(value: AppLanguage.en, child: Text('English')),
        PopupMenuItem(value: AppLanguage.ja, child: Text('日本語')),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(Strings(language).code),
      ),
    );
  }
}

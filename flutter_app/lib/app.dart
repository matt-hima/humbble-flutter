import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization.dart';
import 'data/models.dart';
import 'app_photo_capture.dart';
import 'data/repositories.dart';

class HumbbleApp extends ConsumerWidget {
  const HumbbleApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: Strings(ref.watch(languageProvider)).appName,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffffb000)),
      scaffoldBackgroundColor: const Color(0xfffffbf5),
      useMaterial3: true,
    ),
    home: const AuthGate(),
  );
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(authStateProvider);
    return a.when(
      data: (u) => u == null ? const SignInPage() : HomePage(user: u),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Authentication unavailable: $e'))),
    );
  }
}

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});
  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final email = TextEditingController(), password = TextEditingController();
  bool loading = false;
  String? error;
  Future<void> submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(email.text, password.text);
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: Strings(ref.watch(languageProvider)).welcome,
    subtitle: 'Find people who match your vibe.',
    children: [
      Field(
        controller: email,
        label: Strings(ref.watch(languageProvider)).email,
        type: TextInputType.emailAddress,
      ),
      Field(
        controller: password,
        label: Strings(ref.watch(languageProvider)).password,
        obscure: true,
      ),
      if (error != null) ErrorText(error!),
      FilledButton(
        onPressed: loading ? null : submit,
        child: Text(
          loading ? '…' : Strings(ref.watch(languageProvider)).signIn,
        ),
      ),
      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignUpPage()),
        ),
        child: const Text('New to Humbble? Create an account'),
      ),
      TextButton(
        onPressed: () async {
          if (email.text.isNotEmpty) {
            await ref.read(authRepositoryProvider).resetPassword(email.text);
          }
        },
        child: const Text('Send password reset email'),
      ),
    ],
  );
}

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});
  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  bool loading = false;
  String? error;
  Future<void> submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(name.text, email.text, password.text);
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: Strings(ref.watch(languageProvider)).signUp,
    subtitle: 'Start a kinder way to date.',
    children: [
      Field(controller: name, label: Strings(ref.watch(languageProvider)).name),
      Field(
        controller: email,
        label: Strings(ref.watch(languageProvider)).email,
        type: TextInputType.emailAddress,
      ),
      Field(
        controller: password,
        label: Strings(ref.watch(languageProvider)).password,
        obscure: true,
      ),
      if (error != null) ErrorText(error!),
      FilledButton(
        onPressed: loading ? null : submit,
        child: Text(
          loading ? '…' : Strings(ref.watch(languageProvider)).signUp,
        ),
      ),
    ],
  );
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final String title, subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: LanguageMenu(),
                ),
                const SizedBox(height: 80),
                Text(
                  '交友台北',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xffff9f00),
                  ),
                ),
                const Text('powered by 美圖境界 Glass&Frame'),
                const SizedBox(height: 36),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle),
                const SizedBox(height: 28),
                ...children,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class Field extends StatelessWidget {
  const Field({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.type,
  });
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? type;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

class ErrorText extends StatelessWidget {
  const ErrorText(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.user});
  final User user;
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      DiscoverPage(uid: widget.user.uid),
      PeoplePage(uid: widget.user.uid),
      LikesPage(uid: widget.user.uid),
      ProfilePage(user: widget.user),
    ];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'People',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class PageShell extends StatelessWidget {
  const PageShell({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });
  final String title;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            const LanguageMenu(),
            action ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(child: child),
      ],
    ),
  );
}

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key, required this.uid});
  final String uid;
  @override
  Widget build(BuildContext context, WidgetRef ref) => PageShell(
    title: 'Discover',
    child: StreamBuilder<List<Profile>>(
      stream: ref.read(profileRepositoryProvider).discover(uid),
      builder: (_, s) {
        if (s.hasError) {
          return Empty(
            'Add profiles in Firestore to begin discovering people.',
          );
        }
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final p = s.data!;
        return ListView(
          children: [
            const Chip(label: Text('Fresh connections, every day')),
            const SizedBox(height: 12),
            const Text(
              'Connect over shared interests and dating goals.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              '${p.length} people nearby',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...p.map((v) => ProfileTile(profile: v)),
          ],
        );
      },
    ),
  );
}

class PeoplePage extends ConsumerWidget {
  const PeoplePage({super.key, required this.uid});
  final String uid;
  @override
  Widget build(BuildContext context, WidgetRef ref) => PageShell(
    title: 'People',
    action: const Icon(Icons.tune),
    child: StreamBuilder<List<Profile>>(
      stream: ref.read(profileRepositoryProvider).discover(uid),
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        if (s.data!.isEmpty) {
          return Empty(
            'Create another profile in Firestore to test the swipe experience.',
          );
        }
        return PageView.builder(
          itemCount: s.data!.length,
          itemBuilder: (_, i) => SwipeProfile(profile: s.data![i], uid: uid),
        );
      },
    ),
  );
}

class SwipeProfile extends ConsumerWidget {
  const SwipeProfile({super.key, required this.profile, required this.uid});
  final Profile profile;
  final String uid;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      Expanded(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              profile.photoUrl.isEmpty
                  ? const ColoredBox(color: Color(0xffffc34f))
                  : Image.network(profile.photoUrl, fit: BoxFit.cover),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.black54,
                  child: Text(
                    '${profile.name}, ${profile.age}\n${profile.bio}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => ref
                .read(matchRepositoryProvider)
                .react(from: uid, to: profile.id, liked: false),
            icon: const Icon(Icons.close, color: Colors.red),
          ),
          FilledButton(
            onPressed: () => ref
                .read(matchRepositoryProvider)
                .react(from: uid, to: profile.id, liked: true),
            child: const Icon(Icons.favorite),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.star, color: Colors.amber),
          ),
        ],
      ),
    ],
  );
}

class LikesPage extends ConsumerWidget {
  const LikesPage({super.key, required this.uid});
  final String uid;
  @override
  Widget build(BuildContext context, WidgetRef ref) => PageShell(
    title: 'Chats',
    child: StreamBuilder<List<Conversation>>(
      stream: ref.read(matchRepositoryProvider).conversations(uid),
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        if (s.data!.isEmpty) {
          return Empty('When you match, your conversations will appear here.');
        }
        return ListView(
          children: s.data!
              .map(
                (c) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(c.title),
                  subtitle: Text(c.lastMessage),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(conversation: c, uid: uid),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        );
      },
    ),
  );
}

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.conversation, required this.uid});
  final Conversation conversation;
  final String uid;
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final text = TextEditingController();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.conversation.title)),
    body: Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: ref
                .read(matchRepositoryProvider)
                .messages(widget.conversation.id),
            builder: (_, s) {
              final docs = s.data?.docs ?? [];
              return ListView(
                children: docs.map((d) {
                  final x = d.data();
                  return ListTile(
                    title: Text(x['text'] ?? ''),
                    subtitle: Text(
                      x['senderId'] == widget.uid
                          ? 'You'
                          : widget.conversation.title,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: text,
                decoration: const InputDecoration(hintText: 'Message…'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (text.text.trim().isNotEmpty) {
                  ref
                      .read(matchRepositoryProvider)
                      .send(widget.conversation.id, widget.uid, text.text);
                  text.clear();
                }
              },
            ),
          ],
        ),
      ],
    ),
  );
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, required this.user});
  final User user;
  @override
  Widget build(BuildContext context, WidgetRef ref) => PageShell(
    title: 'Profile',
    action: IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () => ref.read(authRepositoryProvider).signOut(),
    ),
    child: StreamBuilder<Profile?>(
      stream: ref.read(profileRepositoryProvider).watch(user.uid),
      builder: (_, s) {
        final p = s.data;
        if (p == null) return const Center(child: CircularProgressIndicator());
        return ListView(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundImage: p.photoUrl.isEmpty
                  ? null
                  : NetworkImage(p.photoUrl),
              child: p.photoUrl.isEmpty
                  ? Text(
                      p.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 32),
                    )
                  : null,
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                '${p.name}, ${p.age}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(child: Text(p.bio)),
            const SizedBox(height: 16),
            PhotoBoothCapture(profile: p),
            const SizedBox(height: 28),
            Card(
              child: ListTile(
                title: const Text('Dating goal'),
                subtitle: Text(p.goal),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Interests'),
                subtitle: Text(
                  p.interests.isEmpty
                      ? 'Add interests in Firestore'
                      : p.interests.join(' · '),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class ProfileTile extends StatelessWidget {
  const ProfileTile({super.key, required this.profile});
  final Profile profile;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text('${profile.name}, ${profile.age}'),
      subtitle: Text(profile.bio),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class Empty extends StatelessWidget {
  const Empty(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

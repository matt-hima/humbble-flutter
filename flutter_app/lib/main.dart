import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // The app remains usable until project credentials are generated.
  }
  runApp(const HumbbleApp());
}

class HumbbleApp extends StatelessWidget {
  const HumbbleApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Humbble',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xfff8a900)),
      scaffoldBackgroundColor: const Color(0xfffffbf5),
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _pages = const [
    DiscoverPage(),
    PeoplePage(),
    LikesPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: _pages[_tab]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
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
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Liked you',
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

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });
  final String title;
  final Widget child;
  final IconData? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            if (action != null) Icon(action),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: child),
      ],
    ),
  );
}

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Discover',
    action: Icons.help_outline,
    child: ListView(
      children: const [
        Chip(
          label: Text('See new people in 15 hours'),
          backgroundColor: Color(0xffffc34f),
        ),
        SizedBox(height: 12),
        Text(
          'Connect over common groups with people who match your vibe, refreshed every day.',
          style: TextStyle(fontSize: 16),
        ),
        Section(title: 'Recommendations for you'),
        Section(title: 'Same dating goal'),
        Section(title: 'Communities in common'),
      ],
    ),
  );
}

class Section extends StatelessWidget {
  const Section({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: people.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (_, i) => PersonCard(person: people[i]),
          ),
        ),
      ],
    ),
  );
}

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Humbble',
    action: Icons.tune,
    child: PageView.builder(
      itemCount: people.length,
      itemBuilder: (_, i) => SwipeCard(person: people[i]),
    ),
  );
}

class SwipeCard extends StatelessWidget {
  const SwipeCard({super.key, required this.person});
  final Person person;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(person.image, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 20,
                child: Text(
                  '${person.name}, ${person.age}\n${person.bio}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(Icons.close, color: Colors.red),
            ),
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xffffc34f),
              child: Icon(Icons.favorite, color: Colors.black),
            ),
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(Icons.star, color: Colors.amber),
            ),
          ],
        ),
      ),
    ],
  );
}

class LikesPage extends StatelessWidget {
  const LikesPage({super.key});
  @override
  Widget build(BuildContext context) => const AppPage(
    title: 'Liked you',
    action: Icons.tune,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 92, color: Color(0xffffb000)),
          SizedBox(height: 18),
          Text(
            'Get Spotlight for more likes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'You’ll be shown ahead of other people for 30 minutes.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Profile',
    action: Icons.settings_outlined,
    child: ListView(
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundImage: NetworkImage(
                'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=300',
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prakash, 27',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Complete profile'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),
        _plan('Premium+', 'Get the VIP treatment and better ways to connect.'),
        const SizedBox(height: 14),
        _plan('Spotlight', 'Stand out and fast track your likes.'),
      ],
    ),
  );
  Widget _plan(String title, String copy) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xffffb000),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(copy),
      ],
    ),
  );
}

class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.person});
  final Person person;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 135,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(person.image, fit: BoxFit.cover),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black54,
              padding: const EdgeInsets.all(8),
              child: Text(
                '${person.name}, ${person.age}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class Person {
  const Person(this.name, this.age, this.bio, this.image);
  final String name;
  final int age;
  final String bio;
  final String image;
}

const people = [
  Person(
    'Maya',
    26,
    'Coffee, hikes & good playlists',
    'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=900',
  ),
  Person(
    'Aarav',
    28,
    'Here for something real',
    'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=900',
  ),
  Person(
    'Zoe',
    25,
    'Bookshops and beach days',
    'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=900',
  ),
];

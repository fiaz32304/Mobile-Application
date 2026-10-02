import 'package:flutter/material.dart';

// =============================================================================
// 1. ABSTRACTION (ایبسٹریکشن)
// =============================================================================
abstract class TasbeehCounter {
  // Encapsulated Private Variables (انکیپسولیشن)
  String _dhikrName;
  int _count = 0;
  int _target;

  TasbeehCounter(this._dhikrName, [this._target = 33]);

  // Getters (Encapsulation)
  String get dhikrName => _dhikrName;
  int get count => _count;
  int get target => _target;
  bool get isTargetReached => _target > 0 && _count >= _target;

  // Setter with validation
  set target(int newTarget) {
    if (newTarget >= 0) {
      _target = newTarget;
    }
  }

  set dhikrName(String name) {
    if (name.trim().isNotEmpty) {
      _dhikrName = name.trim();
    }
  }

  // Abstract methods to be implemented by child classes (Polymorphism)
  void increment();
  void reset();
  double get progressPercentage => _target > 0 ? (_count / _target).clamp(0.0, 1.0) : 0.0;
  String get extraInfo;
}

// =============================================================================
// 2. MIXIN (Reusability)
// =============================================================================
mixin TargetAlertMixin {
  String getAlertMessage(String dhikr, int count) {
    return 'MashaAllah! Target ($count) Mukammal ho gaya for "$dhikr"!';
  }
}

// =============================================================================
// 3. INHERITANCE: SimpleTasbeeh
// =============================================================================
class SimpleTasbeeh extends TasbeehCounter with TargetAlertMixin {
  SimpleTasbeeh({String dhikr = 'SubhanAllah (سُبْحَانَ اللَّهِ)', int target = 33})
      : super(dhikr, target);

  @override
  void increment() {
    _count++;
  }

  @override
  void reset() {
    _count = 0;
  }

  @override
  String get extraInfo => target > 0 ? 'Target: $target' : 'Free Mode (Unlimited)';
}

// =============================================================================
// 4. INHERITANCE: SmartTasbeeh (Cycles / Rounds Tracker)
// =============================================================================
class SmartTasbeeh extends TasbeehCounter with TargetAlertMixin {
  int _completedRounds = 0;
  int _totalLifetimeCount = 0;

  SmartTasbeeh({String dhikr = 'Astaghfirullah (أَسْتَغْفِرُ اللّٰهَ)', int target = 100})
      : super(dhikr, target);

  int get completedRounds => _completedRounds;
  int get totalLifetimeCount => _totalLifetimeCount;

  @override
  void increment() {
    _count++;
    _totalLifetimeCount++;

    if (target > 0 && _count >= target) {
      _completedRounds++;
      _count = 0; // Auto-reset for the next round
    }
  }

  @override
  void reset() {
    _count = 0;
    _completedRounds = 0;
  }

  @override
  String get extraInfo => 'Rounds: $_completedRounds | Total: $_totalLifetimeCount';
}

// =============================================================================
// 5. INHERITANCE: FatimaTasbeeh (Phase Switching State Machine)
// =============================================================================
class FatimaTasbeeh extends TasbeehCounter with TargetAlertMixin {
  static const List<Map<String, dynamic>> _phases = [
    {'name': 'SubhanAllah (سُبْحَانَ اللَّهِ)', 'target': 33},
    {'name': 'Alhamdulillah (الْحَمْدُ لِلَّهِ)', 'target': 33},
    {'name': 'Allahu Akbar (اللَّهُ أَكْبَرُ)', 'target': 34},
  ];

  int _phaseIndex = 0;
  int _completedCycles = 0;

  FatimaTasbeeh()
      : super(_phases[0]['name'] as String, _phases[0]['target'] as int);

  int get currentPhase => _phaseIndex + 1;
  int get completedCycles => _completedCycles;

  @override
  void increment() {
    _count++;
    if (_count >= target) {
      if (_phaseIndex < _phases.length - 1) {
        _phaseIndex++;
        _dhikrName = _phases[_phaseIndex]['name'] as String;
        _target = _phases[_phaseIndex]['target'] as int;
        _count = 0;
      } else {
        _completedCycles++;
        _phaseIndex = 0;
        _dhikrName = _phases[0]['name'] as String;
        _target = _phases[0]['target'] as int;
        _count = 0;
      }
    }
  }

  @override
  void reset() {
    _count = 0;
    _phaseIndex = 0;
    _dhikrName = _phases[0]['name'] as String;
    _target = _phases[0]['target'] as int;
  }

  @override
  String get extraInfo => 'Phase: $currentPhase/3 | Completed Cycles: $_completedCycles';
}

// =============================================================================
// FLUTTER GUI APPLICATION
// =============================================================================
void main() {
  runApp(const TasbeehApp());
}

class TasbeehApp extends StatelessWidget {
  const TasbeehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Tasbeeh Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981), // Emerald Green
          secondary: Color(0xFFF59E0B), // Amber Gold
          surface: Color(0xFF1E293B), // Slate 800
        ),
      ),
      home: const TasbeehHomeScreen(),
    );
  }
}

class TasbeehHomeScreen extends StatefulWidget {
  const TasbeehHomeScreen({super.key});

  @override
  State<TasbeehHomeScreen> createState() => _TasbeehHomeScreenState();
}

class _TasbeehHomeScreenState extends State<TasbeehHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Polymorphic counters list
  late final List<TasbeehCounter> _counters;
  int _activeCounterIndex = 0;

  @override
  void initState() {
    super.initState();
    _counters = [
      FatimaTasbeeh(),
      SmartTasbeeh(dhikr: 'Astaghfirullah (أَسْتَغْفِرُ اللّٰهَ)', target: 100),
      SimpleTasbeeh(dhikr: 'Darood Sharif (اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ)', target: 33),
    ];
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeCounterIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TasbeehCounter get _currentCounter => _counters[_activeCounterIndex];

  void _incrementCount() {
    setState(() {
      _currentCounter.increment();
    });
  }

  void _resetCount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Reset Counter?', style: TextStyle(color: Colors.white)),
        content: const Text('Kya aap counter ko 0 par reset karna chahte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _currentCounter.reset();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOopInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.code, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text('OOP Architecture', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Abstraction (ایبسٹریکشن):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              Text('abstract class TasbeehCounter jo common blueprint define karti hai.\n'),
              Text('2. Encapsulation (انکیپسولیشن):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              Text('Private variables (_count, _target, _dhikrName) with Getters & Setters.\n'),
              Text('3. Inheritance (انہیریٹنس):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              Text('FatimaTasbeeh, SmartTasbeeh, aur SimpleTasbeeh ne TasbeehCounter ko extend kiya.\n'),
              Text('4. Polymorphism (پولی مارفزم):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              Text('Har child class ka increment() aur reset() method polymorphic tareeqay se call hota hai.\n'),
              Text('5. Mixin:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              Text('TargetAlertMixin alert logic provide karta hai.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Samajh Gaya', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counter = _currentCounter;
    final progress = counter.progressPercentage;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 10),
            Text(
              'Digital Tasbeeh Counter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'OOP Explanation',
            icon: const Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
            onPressed: _showOopInfoDialog,
          ),
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _resetCount,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Fatima Mode', icon: Icon(Icons.spa_outlined, size: 20)),
            Tab(text: 'Smart Mode', icon: Icon(Icons.auto_mode, size: 20)),
            Tab(text: 'Custom Mode', icon: Icon(Icons.edit_note, size: 20)),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          counter.dhikrName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF34D399),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            counter.extraInfo,
                            style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Middle Circular LED Counter Dial
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress Circle
                      SizedBox(
                        width: 230,
                        height: 230,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: const Color(0xFF334155),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        ),
                      ),
                      // Inner LED Display Box
                      Container(
                        width: 195,
                        height: 195,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E293B),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              blurRadius: 25,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${counter.count}',
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              counter.target > 0 ? '/ ${counter.target}' : 'UNLIMITED',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Bottom Click / Count Button
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _incrementCount,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.touch_app_rounded, size: 50, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Count karne ke liye tap / click karein',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


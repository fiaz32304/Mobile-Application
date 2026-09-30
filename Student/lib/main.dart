import 'package:flutter/material.dart';

void main() {
  runApp(const StudentCampusApp());
}

class StudentCampusApp extends StatelessWidget {
  const StudentCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Campus Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController noteController = TextEditingController();

  final String studentName = 'Fiaz Ahmad';
  final String rollNo = 'FA24-BSE-127';
  final String department = 'Software Engineering';
  final String semester = '5th Semester';

  final List<String> courses = [
    'Mobile Application Development',
    'Multi-variable',
    'Computer organization and Assembly Languagge',
    'Web technology',
    'Software Design and architecture',
    'Operating System',
  ];

  String submittedNote = '';

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        title: const Text(
          'Campus Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CourseSearchDelegate(courses),
              );
            },
          ),
        ],
      ),

      // =========================
      // DRAWER
      // =========================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.indigo,
              ),
              accountName: Text(
                studentName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(rollNo),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 45,
                  color: Colors.indigo,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Student Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Digital ID Card'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('My Courses'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // =========================
      // BODY
      // =========================
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // =========================
            // WELCOME
            // =========================
            const Text(
              'Welcome, Fiaz! 👋',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Your student information and campus activities',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // DIGITAL ID CARD
            // =========================
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.indigo,
                      Colors.blue,
                    ],
                  ),
                ),
                child: Column(
                  children: [

                    // ID CARD TITLE
                    const Row(
                      children: [
                        Icon(
                          Icons.school,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'STUDENT DIGITAL ID',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // PROFILE + ACTIVE DOT
                    // =========================
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 65,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        Positioned(
                          right: 2,
                          bottom: 5,
                          child: Container(
                            width: 23,
                            height: 23,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // STUDENT NAME
                    Text(
                      studentName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'ACTIVE STUDENT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // STUDENT DETAILS
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          studentInfoRow(
                            Icons.confirmation_number,
                            'Roll No',
                            rollNo,
                          ),

                          const SizedBox(height: 12),

                          studentInfoRow(
                            Icons.school,
                            'Department',
                            department,
                          ),

                          const SizedBox(height: 12),

                          studentInfoRow(
                            Icons.calendar_month,
                            'Semester',
                            semester,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // COURSES
            // =========================
            const Text(
              'Current Semester Courses',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 12),

            // ListView.builder requirement
            SizedBox(
              height: 360,
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade100,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        courses[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Enrolled Course',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.indigo,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // QUICK NOTES
            // =========================
            const Text(
              'Quick Notes',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your quick note here...',
                prefixIcon: const Icon(Icons.note_alt),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // SUBMIT BUTTON
            // =========================
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text(
                  'Submit Note',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (noteController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter a note first.',
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    submittedNote = noteController.text;
                  });

                  noteController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Note submitted successfully!',
                      ),
                    ),
                  );
                },
              ),
            ),

            // =========================
            // SHOW SUBMITTED NOTE
            // =========================
            if (submittedNote.isNotEmpty) ...[
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          submittedNote,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================
  // STUDENT INFO ROW
  // =========================
  Widget studentInfoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),

        const SizedBox(width: 10),

        Text(
          '$title:',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// SEARCH
// =====================================================

class CourseSearchDelegate extends SearchDelegate<String> {
  final List<String> courses;

  CourseSearchDelegate(this.courses);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = courses
        .where(
          (course) => course
          .toLowerCase()
          .contains(query.toLowerCase()),
    )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(
            Icons.menu_book,
            color: Colors.indigo,
          ),
          title: Text(results[index]),
          onTap: () {
            close(context, results[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = courses
        .where(
          (course) => course
          .toLowerCase()
          .contains(query.toLowerCase()),
    )
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}
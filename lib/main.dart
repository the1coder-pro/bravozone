import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightGreen, brightness: Brightness.dark),
        useMaterial3: true,

        /* dark theme settings */
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}

int randomint(int min, int max) {
  return min + Random().nextInt(max - min);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  int _counter = 0;

  final List<String> _labels = ['Home', 'Leaderboard', 'Employee', 'Tasks'];

  int targetnumber = randomint(1, 20);

  void _increment() {
    setState(() {
      ++_counter;
    });
  }

  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Icon(Icons.settings_outlined), Text('Settings')],
                ))
              ];
            },
          ),
          centerTitle: true,
          title: Text(_labels[currentPageIndex]),
          actions: [
            Switch(
                thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Icon(Icons.dark_mode);
                  }
                  return const Icon(Icons
                      .light_mode); // All other states will use the default thumbIcon.
                }),
                value: MyApp.of(context)._themeMode == ThemeMode.light
                    ? false
                    : true,
                onChanged: (value) {
                  setState(() {
                    if (value == false) {
                      MyApp.of(context).changeTheme(ThemeMode.light);
                    } else if (value == true) {
                      MyApp.of(context).changeTheme(ThemeMode.dark);
                    }
                  });
                }),
            IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const ProfilePage();
                    })))
          ]),
      bottomNavigationBar: NavigationBar(
        labelBehavior: labelBehavior,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
            _counter = 0;
            targetnumber = randomint(1, 20);
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.leaderboard),
            icon: Icon(Icons.leaderboard_outlined),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt),
            label: 'Employee',
          ),
          NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Tasks')
        ],
      ),
      body: Center(
          child: Column(
              children: currentPageIndex == 0
                  ? [
                      OutlinedButton(
                          onPressed: () {}, child: const Text('Click me')),
                    ]
                  : currentPageIndex == 1
                      ? [Text(_labels[currentPageIndex])]
                      : currentPageIndex == 2
                          ? [
                              Text('$_counter',
                                  style: const TextStyle(fontSize: 40)),
                            ]
                          : currentPageIndex == 3
                              ? [
                                  Text(
                                      'You have to count until: $targetnumber'),
                                  Text('You have counted: $_counter'),
                                  _counter == targetnumber
                                      ? const Text(
                                          'Good Job :)',
                                          style: TextStyle(
                                              fontSize: 50, color: Colors.blue),
                                        )
                                      : Container()
                                ]
                              : [])),
      floatingActionButton: currentPageIndex == 2 ||
              currentPageIndex == 3 && _counter != targetnumber
          ? FloatingActionButton(
              onPressed: _increment,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "mhmd",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          )
        ]),
      ),
    );
  }
}

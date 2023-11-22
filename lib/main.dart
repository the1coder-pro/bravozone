import 'package:bravozone/person.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

var dbName = 'bravozonedb';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<Person>(PersonAdapter());
  Hive.registerAdapter<Role>(RoleAdapter());
  await Hive.openBox<Person>(dbName);

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BravoZone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff73dd6e), brightness: Brightness.dark),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  final List<String> _labels = ['Home', 'Leaderboard', 'Employee', 'Tasks'];

  List<String> _people = ["MHMD", "AHMD"];

  Widget bodyPages(BuildContext context, int pageIndex) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Center(
                      child: RichText(
                          text: TextSpan(
                              style: Theme.of(context).textTheme.displaySmall,
                              children: const [
                            TextSpan(text: "Welcome Back, "),
                            TextSpan(
                                text: "Mhmd",
                                style: TextStyle(fontWeight: FontWeight.bold))
                          ])),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AspectRatio(
            aspectRatio: 2,
            child: BarChart(
              BarChartData(
                backgroundColor: Theme.of(context).colorScheme.surface,
                titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (i, _) =>
                                Text(_people[i.toInt()])))),
                barGroups: [
                  generateGroupData(0, 10),
                  generateGroupData(1, 15),
                ],
                barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: false,
                    touchCallback: (event, response) {
                      if (response != null &&
                          response.spot != null &&
                          event is FlTapUpEvent) {
                        setState(() {
                          final x = response.spot!.touchedBarGroup.x;
                          final isShowing = showingTooltip == x;
                          if (isShowing) {
                            showingTooltip = -1;
                          } else {
                            showingTooltip = x;
                          }
                        });
                      }
                    },
                    mouseCursorResolver: (event, response) {
                      return response == null || response.spot == null
                          ? MouseCursor.defer
                          : SystemMouseCursors.click;
                    }),
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
            valueListenable: Hive.box<Person>(dbName).listenable(),
            builder: (context, Box<Person> box, _) {
              if (box.values.isEmpty) {
                return const Center(child: Text("No contacts"));
              }
              return ListView.separated(
                itemCount: box.values.length,
                separatorBuilder: (context, _) => const Divider(),
                itemBuilder: (context, index) {
                  Person? currentPerson = box.getAt(index);

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        tileColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            currentPerson!.name.substring(0, 1),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                        title: Text(currentPerson.name),
                        subtitle: Text(currentPerson.email.toString()),
                      ),
                    ),
                  );
                },
              );
            }),
      ),
      const Column(
        children: [Text("hi 3")],
      )
    ][pageIndex];
  }

  late int showingTooltip;

  @override
  void initState() {
    showingTooltip = -1;
    super.initState();
  }

  BarChartGroupData generateGroupData(int x, int y) {
    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: showingTooltip == x ? [0] : [],
      barRods: [
        BarChartRodData(
            toY: y.toDouble(),
            width: 20,
            borderRadius: BorderRadius.circular(2),
            color: Theme.of(context).colorScheme.primary),
      ],
    );
  }

  Future<void> _registerEmployee() async {
    var box = await Hive.openBox<Person>(dbName);
    var person =
        Person('Mhmd', 00404044, 'hello', Role.admin, 'mhmd@gmail.com');

    box.add(person);
  }

  void _assignAssignment() {}

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
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
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
            )
          : null,
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Center(child: bodyPages(context, currentPageIndex));
        } else {
          return Row(
            children: <Widget>[
              NavigationRail(
                selectedIndex: currentPageIndex,
                groupAlignment: 1.0,
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.selected,
                leading: floatingButton(),
                trailing: IconButton(
                  icon: Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
                destinations: const <NavigationRailDestination>[
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.home),
                    icon: Icon(Icons.home_outlined),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.leaderboard),
                    icon: Icon(Icons.leaderboard_outlined),
                    label: Text('Leaderboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_alt_outlined),
                    selectedIcon: Icon(Icons.people_alt),
                    label: Text('Employee'),
                  ),
                  NavigationRailDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment),
                      label: Text('Tasks')),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              // This is the main content.
              Expanded(child: bodyPages(context, currentPageIndex))
            ],
          );
        }
      }),
      floatingActionButton:
          MediaQuery.of(context).size.width < 600 ? floatingButton() : null,
    );
  }

  Widget? floatingButton() {
    if (currentPageIndex == 2 || currentPageIndex == 3) {
      return FloatingActionButton(
        elevation: MediaQuery.of(context).size.width < 600 ? 6 : 0,
        onPressed:
            currentPageIndex == 2 ? _registerEmployee : _assignAssignment,
        tooltip:
            currentPageIndex == 2 ? 'Add an Employee' : 'Asign an Assignment',
        child: Icon(
            currentPageIndex == 2 ? Icons.person_add : Icons.assignment_add),
      );
    } else {
      return null;
    }
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

import 'package:bravozone/assign_task.dart';
import 'package:bravozone/person.dart';
import 'package:bravozone/register_employee.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

var dbName = 'bravozonedb';

class DarkThemePreference {
  static const THEME_STATUS = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ?? false;
  }
}

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }
}

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<Person>(PersonAdapter());
  Hive.registerAdapter<Role>(RoleAdapter());
  Hive.registerAdapter<Task>(TaskAdapter());
  await Hive.openBox<Person>(dbName);

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(builder:
          (BuildContext context, DarkThemeProvider value, Widget? child) {
        return MaterialApp(
          title: 'BravoZone',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.lightGreen, brightness: Brightness.light),
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          themeMode:
              themeChangeProvider.darkTheme ? ThemeMode.dark : ThemeMode.light,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff73dd6e),
                brightness: Brightness.dark),
            useMaterial3: true,

            /* dark theme settings */
          ),
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(),
        );
      }),
    );
  }
}

class _Example01Tile extends StatelessWidget {
  const _Example01Tile({this.background, this.iconData, this.child});
  final Color? background;
  final IconData? iconData;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: background ?? Theme.of(context).colorScheme.background,
      child: InkWell(
        onTap: () {},
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: iconData != null
                ? Icon(
                    iconData,
                    size: 30,
                    color: Theme.of(context).colorScheme.onSurface,
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  final List<String> _labels = ['Home', 'Leaderboard', 'Employees', 'Tasks'];

  List<String> _people = ["MHMD", "AHMD"];
  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  Widget bodyPages(BuildContext context, int pageIndex) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
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
                              style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 50,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                              children: [
                            TextSpan(text: "Good ${greeting()}, "),
                            const TextSpan(
                                text: "Mhmd",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ])),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.width,
                child: StaggeredGrid.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: _Example01Tile(
                          background: themeChange.darkTheme == true
                              ? const Color.fromARGB(255, 40, 63, 82)
                              : const Color.fromARGB(255, 178, 220, 255),
                          child: const SizedBox(
                            height: 150,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("1", style: TextStyle(fontSize: 80)),
                                  Text("Row"),
                                ]),
                          )),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 1,
                      child: _Example01Tile(
                        background: themeChange.darkTheme == true
                            ? const Color.fromARGB(255, 91, 132, 45)
                            : Colors.lightGreenAccent,
                        child: const SizedBox(
                          height: 130,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("\$40", style: TextStyle(fontSize: 30)),
                                Text("Expenses"),
                              ]),
                        ),
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1,
                      child: _Example01Tile(
                        background: Colors.white,
                        child:
                            Image.network('https://picsum.photos/250?image=9'),
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1,
                      child: _Example01Tile(
                          iconData: Icons.people, background: Colors.redAccent),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 4,
                      mainAxisCellCount: 2,
                      child: _Example01Tile(
                        // iconData: Icons.image_outlined,
                        child: barchartWidget(context),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AspectRatio(
            aspectRatio: 2,
            child: barchartWidget(context),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
            valueListenable: Hive.box<Person>(dbName).listenable(),
            builder: (context, Box<Person> box, _) {
              if (box.values.isEmpty) {
                return const Center(
                    child: Text("There's No Registered Employees :("));
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
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Scaffold(
                              appBar: AppBar(
                                title: const Text("Info"),
                              ),
                              body: Column(
                                children: [
                                  Text(currentPerson.name),
                                  Text(currentPerson.bio!),
                                  Text(currentPerson.phoneNumber!.toString()),
                                  Text(currentPerson.email!),
                                  if (currentPerson.role == Role.employee)
                                    const Icon(Icons.person),
                                  if (currentPerson.role == Role.admin)
                                    const Icon(Icons.manage_accounts),
                                  IconButton(
                                      onPressed: () {
                                        box.deleteAt(index);
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(
                                          Icons.delete_forever_outlined)),
                                ],
                              ));
                        })),
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

  BarChart barchartWidget(BuildContext context) {
    return BarChart(
      BarChartData(
        backgroundColor: Theme.of(context).colorScheme.surface,
        titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (i, _) => Text(_people[i.toInt()])))),
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
    );
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
            color: Theme.of(context).colorScheme.primaryContainer),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width < 600
          ? AppBar(
              leading: PopupMenuButton(
                icon: const Icon(Icons.settings_outlined),
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.settings_outlined),
                        Text('Settings')
                      ],
                    ))
                  ];
                },
              ),
              centerTitle: true,
              title: Text(_labels[currentPageIndex]),
              actions: [
                  themeModeSwitch(context),
                  IconButton(
                      icon: const Icon(Icons.account_circle_outlined),
                      onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const ProfilePage();
                          })))
                ])
          : null,
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
                trailing: themeModeSwitch(context),
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

  Switch themeModeSwitch(BuildContext context) {
    final themeChangeProvider = Provider.of<DarkThemeProvider>(context);
    return Switch(
        thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return const Icon(Icons.dark_mode);
          }
          return const Icon(Icons
              .light_mode); // All other states will use the default thumbIcon.
        }),
        value: themeChangeProvider.darkTheme,
        onChanged: (value) {
          setState(() {
            themeChangeProvider.darkTheme = !themeChangeProvider.darkTheme;
          });
        });
  }

  Widget? floatingButton() {
    if (currentPageIndex == 2 || currentPageIndex == 3) {
      return FloatingActionButton(
        elevation: MediaQuery.of(context).size.width < 600 ? 6 : 0,
        onPressed: () {
          if (currentPageIndex == 2) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegisterEmployeePage()));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AssignTaskPage()));
          }
        },
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
          ),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'features/diary/data/models/food_entry_model.dart';
import 'features/diary/data/repositories/diary_repository_impl.dart';
import 'features/diary/domain/usecases/add_food_entry.dart';
import 'features/diary/domain/usecases/get_today_entries.dart';
import 'features/diary/domain/usecases/calculate_daily_total.dart';
import 'features/diary/presentation/providers/diary_provider.dart';
import 'features/diary/presentation/screens/diary_screen.dart';
import 'features/diary/presentation/screens/home_screen.dart';

import 'features/scan/presentation/screens/ocr_scan_screen.dart';
import 'features/scan/presentation/screens/scan_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/diary/domain/usecases/get_custom_foods.dart';
import 'features/diary/domain/usecases/delete_food_entry.dart';
import 'features/diary/domain/usecases/update_food_entry.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/diary/domain/usecases/delete_all_entries.dart';
import 'features/custom_foods/data/models/custom_food_model.dart';
import 'features/custom_foods/data/repositories/custom_food_repository_impl.dart';
import 'features/custom_foods/presentation/providers/custom_food_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FoodEntryModelAdapter());
  Hive.registerAdapter(CustomFoodModelAdapter());
  final box = await Hive.openBox<FoodEntryModel>('food_entries');
  final customFoodsBox = await Hive.openBox<CustomFoodModel>('custom_foods');
  final settingsBox = await Hive.openBox('settings');
  final repository = DiaryRepositoryImpl(box);
  final customFoodRepository = CustomFoodRepositoryImpl(customFoodsBox);

  runApp(CalorieScanApp(
    repository: repository,
    customFoodRepository: customFoodRepository,
    settingsBox: settingsBox,
  ));
}

class CalorieScanApp extends StatelessWidget {
  final DiaryRepositoryImpl repository;
  final CustomFoodRepositoryImpl customFoodRepository;
  final Box settingsBox;

  const CalorieScanApp({
    super.key,
    required this.repository,
    required this.customFoodRepository,
    required this.settingsBox,
  });
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DiaryProvider(
            addFoodEntryUseCase: AddFoodEntry(repository),
            getTodayEntriesUseCase: GetTodayEntries(repository),
            calculateDailyTotalUseCase: CalculateDailyTotal(),
            getCustomFoodsUseCase: GetCustomFoods(repository),
            deleteFoodEntryUseCase: DeleteFoodEntry(repository),
            updateFoodEntryUseCase: UpdateFoodEntry(repository),
            deleteAllEntriesUseCase: DeleteAllEntries(repository),
          )..loadTodayEntries(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsBox),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomFoodProvider(customFoodRepository),
        ),
      ],
      child: MaterialApp(
        title: 'CalorieScan',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF34C759),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF9F9F7),
          textTheme: GoogleFonts.interTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            foregroundColor: Colors.black,
          ),
        ),
        home: const RootScreen(),
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    DiaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text('Search food'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Scan photo'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ScanScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.document_scanner),
                    title: const Text('Scan label'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OcrScanScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home,
                  color: _currentIndex == 0 ? Colors.green : Colors.grey),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.book,
                  color: _currentIndex == 1 ? Colors.green : Colors.grey),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
          ],
        ),
      ),
    );
  }
}
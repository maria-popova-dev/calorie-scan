import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
import 'features/premium/presentation/providers/premium_provider.dart';
import 'features/diary/domain/usecases/get_history_by_day.dart';
import 'features/settings/presentation/screens/onboarding_screen.dart';

import 'features/water/data/models/water_entry_model.dart';
import 'features/water/data/repositories/water_repository_impl.dart';
import 'features/water/domain/usecases/add_water_entry.dart';
import 'features/water/domain/usecases/get_today_water_entries.dart';
import 'features/water/domain/usecases/delete_water_entry.dart';
import 'features/water/domain/usecases/calculate_water_goal.dart';
import 'features/water/presentation/providers/water_provider.dart';

import 'features/weight/data/models/weight_entry_model.dart';
import 'features/weight/data/repositories/weight_repository_impl.dart';
import 'features/weight/domain/usecases/add_weight_entry.dart';
import 'features/weight/domain/usecases/get_weight_history.dart';
import 'features/weight/domain/usecases/delete_weight_entry.dart';
import 'features/weight/presentation/providers/weight_provider.dart';

import 'package:yandex_mobileads/mobile_ads.dart';
void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await YandexAds.initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(FoodEntryModelAdapter());
  Hive.registerAdapter(CustomFoodModelAdapter());
  Hive.registerAdapter(WaterEntryModelAdapter());
  Hive.registerAdapter(WeightEntryModelAdapter());
  final box = await Hive.openBox<FoodEntryModel>('food_entries');
  final customFoodsBox = await Hive.openBox<CustomFoodModel>('custom_foods');
  final waterBox = await Hive.openBox<WaterEntryModel>('water_entries');
  final weightBox = await Hive.openBox<WeightEntryModel>('weight_entries');
  final settingsBox = await Hive.openBox('settings');
  final repository = DiaryRepositoryImpl(box);
  final customFoodRepository = CustomFoodRepositoryImpl(customFoodsBox);
  final waterRepository = WaterRepositoryImpl(waterBox);
  final weightRepository = WeightRepositoryImpl(weightBox);

  runApp(CalorieScanApp(
    repository: repository,
    customFoodRepository: customFoodRepository,
    waterRepository: waterRepository,
    weightRepository: weightRepository,
    settingsBox: settingsBox,
  ));
}

class CalorieScanApp extends StatelessWidget {
  final DiaryRepositoryImpl repository;
  final CustomFoodRepositoryImpl customFoodRepository;
  final WaterRepositoryImpl waterRepository;
  final WeightRepositoryImpl weightRepository;
  final Box settingsBox;

  const CalorieScanApp({
    super.key,
    required this.repository,
    required this.customFoodRepository,
    required this.waterRepository,
    required this.weightRepository,
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
            getHistoryByDayUseCase: GetHistoryByDay(repository),
          )..loadTodayEntries(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsBox),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomFoodProvider(customFoodRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PremiumProvider(settingsBox),
        ),
        ChangeNotifierProvider(
          create: (_) => WaterProvider(
            addWaterEntryUseCase: AddWaterEntry(waterRepository),
            getTodayWaterEntriesUseCase: GetTodayWaterEntries(waterRepository),
            deleteWaterEntryUseCase: DeleteWaterEntry(waterRepository),
            calculateWaterGoalUseCase: CalculateWaterGoal(),
            settingsBox: settingsBox,
          )..loadTodayEntries(),
        ),
        ChangeNotifierProvider(
          create: (_) => WeightProvider(
            addWeightEntryUseCase: AddWeightEntry(weightRepository),
            getWeightHistoryUseCase: GetWeightHistory(weightRepository),
            deleteWeightEntryUseCase: DeleteWeightEntry(weightRepository),
          )..loadHistory(),
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
          fontFamily: 'Satoshi',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            foregroundColor: Colors.black,
          ),
        ),
        home: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (!settings.hasCompletedOnboarding) {
      return OnboardingScreen(
        onComplete: () {
          // Экран сам пересоберётся, когда settings.hasCompletedOnboarding
          // станет true — Provider уведомит об изменении.
        },
      );
    }

    return const RootScreen();
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

  void _openScan(Widget screen) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
  void _openAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(LucideIcons.search),
              title: const Text('Search food'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Scan photo'),
              onTap: () => _openScan(const ScanScreen()),
            ),
            ListTile(
              leading: const Icon(LucideIcons.scanLine),
              title: const Text('Scan label'),
              onTap: () => _openScan(const OcrScanScreen()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavIcon(
                  icon: LucideIcons.home,
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _AddButton(onTap: _openAddMenu),
                _NavIcon(
                  icon: LucideIcons.bookOpen,
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          icon,
          size: 26,
          color: isActive ? const Color(0xFF34C759) : Colors.grey[400],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFF34C759),
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 22),
      ),
    );
  }
}
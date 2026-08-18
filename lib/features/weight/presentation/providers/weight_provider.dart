import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/usecases/add_weight_entry.dart';
import '../../domain/usecases/get_weight_history.dart';
import '../../domain/usecases/delete_weight_entry.dart';

class WeightProvider extends ChangeNotifier {
  final AddWeightEntry addWeightEntryUseCase;
  final GetWeightHistory getWeightHistoryUseCase;
  final DeleteWeightEntry deleteWeightEntryUseCase;

  WeightProvider({
    required this.addWeightEntryUseCase,
    required this.getWeightHistoryUseCase,
    required this.deleteWeightEntryUseCase,
  });

  List<WeightEntry> _history = [];
  List<WeightEntry> get history => _history;

  WeightEntry? get latest => _history.isEmpty ? null : _history.last;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    _history = await getWeightHistoryUseCase();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWeight(double weightKg) async {
    final entry = WeightEntry(
      id: const Uuid().v4(),
      weightKg: weightKg,
      timestamp: DateTime.now(),
    );
    await addWeightEntryUseCase(entry);
    await loadHistory();
  }

  Future<void> deleteEntry(String id) async {
    await deleteWeightEntryUseCase(id);
    await loadHistory();
  }
}
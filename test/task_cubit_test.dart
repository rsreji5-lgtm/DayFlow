import 'package:dayflow/cubits/auth/task_cubit.dart';
import 'package:dayflow/repositories/task_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTaskRepository extends TaskRepository {}

void main() {
  group('TaskCubit filter state', () {
    late TaskCubit cubit;

    setUp(() {
      cubit = TaskCubit(FakeTaskRepository());
    });

    tearDown(() {
      cubit.close();
    });

    test('exposes default filter values as All', () {
      expect(cubit.priority, 'All');
      expect(cubit.completion, 'All');
    });

    test('updates getters when filters change and reset', () {
      cubit.filterPriority('Medium');
      expect(cubit.priority, 'Medium');

      cubit.filterCompletion('Completed');
      expect(cubit.completion, 'Completed');

      cubit.resetFilters();
      expect(cubit.priority, 'All');
      expect(cubit.completion, 'All');
    });
  });
}

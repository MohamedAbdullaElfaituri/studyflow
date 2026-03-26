import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/shared/models/app_models.dart';

void main() {
  test('task model preserves json shape for subtasks', () {
    final now = DateTime(2026, 3, 26, 9, 0);
    final task = TaskModel(
      id: 'task-1',
      userId: 'user-1',
      courseId: 'course-1',
      title: 'Prepare HCI demo',
      description: 'Create polished visuals and walkthrough notes.',
      dueDateTime: now,
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      estimatedMinutes: 90,
      isArchived: false,
      subtasks: [
        SubtaskModel(
          id: 'subtask-1',
          taskId: 'task-1',
          title: 'Finish dashboard polish',
          isCompleted: true,
          createdAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    final decoded = TaskModel.fromJson(task.toJson());

    expect(decoded.id, task.id);
    expect(decoded.title, task.title);
    expect(decoded.priority, TaskPriority.high);
    expect(decoded.status, TaskStatus.inProgress);
    expect(decoded.subtasks.length, 1);
    expect(decoded.subtasks.first.title, 'Finish dashboard polish');
  });
}

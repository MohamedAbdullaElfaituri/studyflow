import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';
import '../../exams/presentation/exams_screens.dart';
import '../../notes/presentation/notes_screens.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  static const routePath = '/search';

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      child: data.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const LoadingColumn(itemCount: 3),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final query = _controller.text.trim().toLowerCase();
          final courses = studyData.courses
              .where((item) =>
                  item.title.toLowerCase().contains(query) ||
                  item.description.toLowerCase().contains(query))
              .toList();
          final tasks = studyData.tasks
              .where((item) =>
                  item.title.toLowerCase().contains(query) ||
                  item.description.toLowerCase().contains(query))
              .toList();
          final notes = studyData.notes
              .where((item) =>
                  item.title.toLowerCase().contains(query) ||
                  item.content.toLowerCase().contains(query))
              .toList();
          final exams = studyData.exams
              .where((item) =>
                  item.title.toLowerCase().contains(query) ||
                  item.description.toLowerCase().contains(query))
              .toList();
          final hasResults = courses.isNotEmpty ||
              tasks.isNotEmpty ||
              notes.isNotEmpty ||
              exams.isNotEmpty;

          return ListView(
            children: [
              PageHeader(
                title: _searchTitle(context),
                subtitle: _searchSubtitle(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              SearchTextField(
                controller: _controller,
                hintText: _searchHint(context),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (query.isEmpty)
                EmptyState(
                  title: context.copy.emptySearchTitle,
                  description: _searchEmptyDescription(context),
                  icon: Icons.travel_explore_rounded,
                )
              else if (!hasResults)
                EmptyState(
                  title: context.copy.emptySearchTitle,
                  description: _searchEmptyDescription(context),
                  icon: Icons.search_off_rounded,
                )
              else ...[
                _SearchSection(
                  title: context.copy.searchCoursesSection,
                  count: courses.length,
                  children: courses
                      .map(
                        (course) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.menu_book_rounded),
                          title: Text(course.title),
                          subtitle: Text(
                            course.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => context.push('/course/${course.id}'),
                        ),
                      )
                      .toList(),
                ),
                _SearchSection(
                  title: context.copy.searchTasksSection,
                  count: tasks.length,
                  children: tasks
                      .map(
                        (task) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.checklist_rtl_rounded),
                          title: Text(task.title),
                          subtitle: Text(
                            task.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => context.push('/task/${task.id}'),
                        ),
                      )
                      .toList(),
                ),
                _SearchSection(
                  title: context.copy.searchNotesSection,
                  count: notes.length,
                  children: notes
                      .map(
                        (note) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.note_alt_rounded),
                          title: Text(note.title),
                          subtitle: Text(
                            note.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => context.push(
                            '${NoteEditorScreen.routePath}?noteId=${note.id}',
                          ),
                        ),
                      )
                      .toList(),
                ),
                _SearchSection(
                  title: context.copy.searchExamsSection,
                  count: exams.length,
                  children: exams
                      .map(
                        (exam) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_note_rounded),
                          title: Text(exam.title),
                          subtitle: Text(
                            exam.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => context.push(
                            '${ExamEditorScreen.routePath}?examId=${exam.id}',
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _searchTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Arama',
      'ar' => 'البحث',
      _ => 'Search',
    };
  }

  String _searchSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Dersleri, görevleri, notları ve sınavları tek yerden ara.',
      'ar' => 'ابحث في المواد والمهام والملاحظات والاختبارات من مكان واحد.',
      _ => 'Search courses, tasks, notes, and exams from one place.',
    };
  }

  String _searchHint(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Çalışma içeriğinde ara',
      'ar' => 'ابحث في محتوى الدراسة',
      _ => 'Search your study content',
    };
  }

  String _searchEmptyDescription(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Yazdıkça sonuçlar burada görünecek.',
      'ar' => 'ستظهر النتائج هنا أثناء الكتابة.',
      _ => 'Results will appear here as you type.',
    };
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.title,
    required this.count,
    required this.children,
  });

  final String title;
  final int count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('$count'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...children,
          ],
        ),
      ),
    );
  }
}

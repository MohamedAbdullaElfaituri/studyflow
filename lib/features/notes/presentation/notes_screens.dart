import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  static const routePath = '/notes';

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(NoteEditorScreen.routePath),
        label: Text(context.l10n.addNoteAction),
        icon: const Icon(Icons.add_rounded),
      ),
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
          final query = _searchController.text.trim().toLowerCase();
          final notes = studyData.notes.where((note) {
            if (query.isEmpty) return true;
            return note.title.toLowerCase().contains(query) ||
                note.content.toLowerCase().contains(query);
          }).toList()
            ..sort((a, b) {
              if (a.isPinned == b.isPinned) {
                return b.updatedAt.compareTo(a.updatedAt);
              }
              return a.isPinned ? -1 : 1;
            });

          return ListView(
            children: [
              PageHeader(
                title: context.l10n.notesTitle,
                subtitle: context.l10n.emptyNotesDescription,
              ),
              const SizedBox(height: AppSpacing.md),
              SearchTextField(
                controller: _searchController,
                hintText: context.l10n.searchNotesHint,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (notes.isEmpty)
                EmptyState(
                  title: context.l10n.emptyNotesTitle,
                  description: context.l10n.emptyNotesDescription,
                  icon: Icons.note_alt_rounded,
                  action: FilledButton.tonal(
                    onPressed: () => context.push(NoteEditorScreen.routePath),
                    child: Text(context.l10n.addNoteAction),
                  ),
                )
              else
                ...notes.map(
                  (note) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      onTap: () => context.push(
                        '${NoteEditorScreen.routePath}?noteId=${note.id}',
                      ),
                      borderRadius: BorderRadius.circular(24),
                      child: SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                if (note.isPinned)
                                  const Icon(Icons.push_pin_rounded, size: 18),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              note.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (note.courseId != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                studyData.courseById(note.courseId)?.title ??
                                    '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({
    super.key,
    this.noteId,
  });

  static const routePath = '/note/edit';

  final String? noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPinned = false;
  String? _courseId;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      child: data.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const LoadingColumn(itemCount: 2),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final existing =
              widget.noteId == null ? null : studyData.noteById(widget.noteId!);
          final selectedCourseId = studyData.courses.any(
            (course) => course.id == _courseId,
          )
              ? _courseId
              : null;

          if (!_initialized) {
            _initialized = true;
            if (existing != null) {
              _titleController.text = existing.title;
              _contentController.text = existing.content;
              _isPinned = existing.isPinned;
              _courseId = existing.courseId;
            }
          }

          return ListView(
            children: [
              PageHeader(
                title: existing == null
                    ? context.l10n.addNoteTitle
                    : context.l10n.editNoteTitle,
                trailing: existing == null
                    ? null
                    : IconButton(
                        onPressed: () async {
                          try {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .deleteNote(existing.id);
                            if (!mounted) return;
                            context.showSuccessNotification(
                              context.copy.noteDeletedMessage,
                            );
                            context.pop();
                          } catch (error) {
                            if (!mounted) return;
                            context.showErrorNotification(
                              context.resolveError(error),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration:
                            InputDecoration(labelText: context.l10n.titleLabel),
                        validator: (value) => context.validationMessage(
                          Validators.requiredField(value),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String?>(
                        initialValue: selectedCourseId,
                        decoration: InputDecoration(
                            labelText: context.l10n.courseLabel),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(context.l10n.optionalCourseLabel),
                          ),
                          ...studyData.courses.map(
                            (course) => DropdownMenuItem<String?>(
                              value: course.id,
                              child: Text(course.title),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() => _courseId = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _contentController,
                        minLines: 8,
                        maxLines: 12,
                        decoration: InputDecoration(
                          labelText: context.l10n.contentLabel,
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile(
                        value: _isPinned,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) => setState(() => _isPinned = value),
                        title: Text(context.l10n.pinNoteLabel),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final user = ref.read(currentUserProvider);
                          if (user == null) return;

                          final now = DateTime.now();
                          final note = NoteModel(
                            id: existing?.id ?? const Uuid().v4(),
                            userId: user.id,
                            courseId: selectedCourseId,
                            title: _titleController.text.trim(),
                            content: _contentController.text.trim(),
                            isPinned: _isPinned,
                            createdAt: existing?.createdAt ?? now,
                            updatedAt: now,
                          );

                          try {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .saveNote(note);
                            if (!mounted) return;
                            context.showSuccessNotification(
                              context.copy.noteSavedMessage(
                                isNew: existing == null,
                              ),
                            );
                            context.pop();
                          } catch (error) {
                            if (!mounted) return;
                            context.showErrorNotification(
                              context.resolveError(error),
                            );
                          }
                        },
                        child: Text(context.l10n.saveNoteAction),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

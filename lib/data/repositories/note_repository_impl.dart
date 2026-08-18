import '../../domain/models/note_model.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_datasource.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;

  NoteRepositoryImpl({required this.localDataSource});

  @override
  Future<List<NoteModel>> getAllNotes() async {
    return await localDataSource.getNotes();
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    return await localDataSource.getNote(id);
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    await localDataSource.saveNote(note);
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await localDataSource.saveNote(note);
  }

  @override
  Future<void> deleteNote(String id) async {
    await localDataSource.deleteNote(id);
  }

  @override
  Future<void> togglePinNote(String id) async {
    final note = await localDataSource.getNote(id);
    if (note != null) {
      final updatedNote = note.copyWith(isPinned: !note.isPinned);
      await localDataSource.saveNote(updatedNote);
    }
  }

  @override
  Future<List<NoteModel>> searchNotes(String query, {String? categoryId}) async {
    final notes = await localDataSource.getNotes();
    final lowerQuery = query.toLowerCase().trim();

    return notes.where((note) {
      final matchesCategory = categoryId == null ||
          categoryId.isEmpty ||
          categoryId == 'todas' ||
          note.categoryId == categoryId;

      if (!matchesCategory) return false;

      if (lowerQuery.isEmpty) return true;

      final titleMatch = note.title.toLowerCase().contains(lowerQuery);
      final contentMatch = note.content.toLowerCase().contains(lowerQuery);
      final tagMatch = note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));

      return titleMatch || contentMatch || tagMatch;
    }).toList();
  }

  @override
  Future<void> clearAll() async {
    await localDataSource.clearAllNotes();
  }
}

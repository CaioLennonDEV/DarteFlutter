import '../../core/services/local_storage_service.dart';
import '../../domain/models/note_model.dart';

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel?> getNote(String id);
  Future<void> saveNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<void> clearAllNotes();
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  @override
  Future<List<NoteModel>> getNotes() async {
    final box = LocalStorageService.notesBox;
    final List<NoteModel> notes = [];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data is Map) {
        notes.add(NoteModel.fromMap(data));
      }
    }

    // Sort notes: Pinned first, then newest updated first
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return notes;
  }

  @override
  Future<NoteModel?> getNote(String id) async {
    final box = LocalStorageService.notesBox;
    final data = box.get(id);
    if (data is Map) {
      return NoteModel.fromMap(data);
    }
    return null;
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    final box = LocalStorageService.notesBox;
    await box.put(note.id, note.toMap());
  }

  @override
  Future<void> deleteNote(String id) async {
    final box = LocalStorageService.notesBox;
    await box.delete(id);
  }

  @override
  Future<void> clearAllNotes() async {
    final box = LocalStorageService.notesBox;
    await box.clear();
  }
}

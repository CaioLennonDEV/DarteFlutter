import '../models/note_model.dart';

abstract class NoteRepository {
  Future<List<NoteModel>> getAllNotes();
  Future<NoteModel?> getNoteById(String id);
  Future<void> saveNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<void> togglePinNote(String id);
  Future<List<NoteModel>> searchNotes(String query, {String? categoryId});
  Future<void> clearAll();
}

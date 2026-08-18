import 'package:flutter/material.dart';
import '../../core/services/local_storage_service.dart';
import '../../domain/models/note_model.dart';
import '../../domain/repositories/note_repository.dart';

class NotesController extends ChangeNotifier {
  final NoteRepository repository;

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'todas';
  bool _isGridView = true;
  NoteModel? _lastDeletedNote;

  NotesController({required this.repository}) {
    _isGridView = LocalStorageService.isGridView();
    loadNotes();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isGridView => _isGridView;
  NoteModel? get lastDeletedNote => _lastDeletedNote;

  List<NoteModel> get allNotes => _notes;

  List<NoteModel> get filteredNotes {
    final query = _searchQuery.toLowerCase().trim();

    return _notes.where((note) {
      final matchesCategory = _selectedCategory == 'todas' ||
          note.categoryId == _selectedCategory;

      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      final titleMatch = note.title.toLowerCase().contains(query);
      final contentMatch = note.content.toLowerCase().contains(query);
      final tagMatch = note.tags.any((tag) => tag.toLowerCase().contains(query));

      return titleMatch || contentMatch || tagMatch;
    }).toList();
  }

  List<NoteModel> get pinnedNotes =>
      filteredNotes.where((note) => note.isPinned).toList();

  List<NoteModel> get unpinnedNotes =>
      filteredNotes.where((note) => !note.isPinned).toList();

  int get totalNotesCount => _notes.length;

  // Actions
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await repository.getAllNotes();
    } catch (e) {
      debugPrint('Erro ao carregar notas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(NoteModel note) async {
    try {
      await repository.saveNote(note);
      await loadNotes();
    } catch (e) {
      debugPrint('Erro ao adicionar nota: $e');
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      await repository.updateNote(note);
      await loadNotes();
    } catch (e) {
      debugPrint('Erro ao atualizar nota: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      _lastDeletedNote = _notes.firstWhere((n) => n.id == id);
      await repository.deleteNote(id);
      await loadNotes();
    } catch (e) {
      debugPrint('Erro ao deletar nota: $e');
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedNote != null) {
      await repository.saveNote(_lastDeletedNote!);
      _lastDeletedNote = null;
      await loadNotes();
    }
  }

  Future<void> togglePin(String id) async {
    try {
      await repository.togglePinNote(id);
      await loadNotes();
    } catch (e) {
      debugPrint('Erro ao alternar fixação: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void setSelectedCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    LocalStorageService.setGridView(_isGridView);
    notifyListeners();
  }

  Future<void> clearAllNotes() async {
    await repository.clearAll();
    await loadNotes();
  }
}

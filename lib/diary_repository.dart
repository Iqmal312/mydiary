import 'database_helper.dart';
import 'diary_entry.dart';

class DiaryRepository {
  final DatabaseHelper _dbHelper;

  DiaryRepository(this._dbHelper);

  Future<List<DiaryEntry>> getAllEntries() => _dbHelper.getAllEntries();
  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) => 
      _dbHelper.getEntriesForDate(date);
  Future<int> addEntry(DiaryEntry entry) => _dbHelper.insertEntry(entry);
  Future<int> updateEntry(DiaryEntry entry) => _dbHelper.updateEntry(entry);
  Future<int> deleteEntry(String id) => _dbHelper.deleteEntry(id);
  Future<List<DiaryEntry>> searchEntries(String query) => 
      _dbHelper.searchEntries(query);
}
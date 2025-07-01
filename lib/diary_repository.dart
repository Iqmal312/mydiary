import 'database_helper.dart';
import 'diary_entry.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class DiaryRepository {
  final DatabaseHelper _dbHelper;

  DiaryRepository(this._dbHelper);

  Future<List<DiaryEntry>> getAllEntries() async {
    try {
      return await _dbHelper.getAllEntries();
    } catch (e) {
      debugPrint('Error getting all entries: $e');
      return [];
    }
  }

  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) async {
    try {
      return await _dbHelper.getEntriesForDate(date);
    } catch (e) {
      debugPrint('Error getting entries for date: $e');
      return [];
    }
  }

  Future<void> addEntry(DiaryEntry entry) async {
  try {
    await _dbHelper.insertEntry(entry);
  } catch (e) {
    debugPrint('Error adding entry: $e');
  }
}


  Future<int> updateEntry(DiaryEntry entry) async {
    try {
      return await _dbHelper.updateEntry(entry);
    } catch (e) {
      debugPrint('Error updating entry: $e');
      return 0;
    }
  }

  Future<int> deleteEntry(String id) async {
    try {
      return await _dbHelper.deleteEntry(id);
    } catch (e) {
      debugPrint('Error deleting entry: $e');
      return 0;
    }
  }

  Future<List<DiaryEntry>> searchEntries(String query) async {
    try {
      return await _dbHelper.searchEntries(query);
    } catch (e) {
      debugPrint('Error searching entries: $e');
      return [];
    }
  }
}
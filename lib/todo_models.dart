import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// ========================================
// TODO MODELS
// Data models and persistence for the tasks section
// ========================================

// Todo Model - Simple task with title and creation time
class Todo {
  final String id;          // Unique identifier
  final String title;       // Task description
  final String section;     // 'personal' or 'shared'
  final DateTime createdAt; // When task was created

  Todo({
    required this.id,
    required this.title,
    required this.section,
    required this.createdAt,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'section': section,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from stored JSON
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      section: json['section'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Create modified copy of todo
  Todo copyWith({
    String? id,
    String? title,
    String? section,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      section: section ?? this.section,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Todo Data Manager - Handles saving/loading tasks to device storage
class TodoDataManager {
  static const String _fileName = 'todos.json';
  
  // Get app's document directory path
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get the todos file
  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // Save all todos to file
  static Future<void> saveTodos(List<Todo> todos) async {
    try {
      final file = await _localFile;
      final todosJson = todos.map((todo) => todo.toJson()).toList();
      await file.writeAsString(jsonEncode(todosJson));
    } catch (e) {
      print('Error saving todos: $e');
    }
  }

  // Load all todos from file
  static Future<List<Todo>> loadTodos() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return []; // Return empty list if no file exists
      }
      
      final contents = await file.readAsString();
      final List<dynamic> todosJson = jsonDecode(contents);
      return todosJson.map((json) => Todo.fromJson(json)).toList();
    } catch (e) {
      print('Error loading todos: $e');
      return [];
    }
  }

  // Delete all todos (clear storage)
  static Future<void> clearTodos() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing todos: $e');
    }
  }
}

// ========================================
// NOTES DATA MANAGER
// Handles saving/loading text notes to device storage
// ========================================

// Notes Data Manager - Simpler than todos, just stores text strings
class NotesDataManager {
  static const String _fileName = 'notes.json';
  
  // Get app's document directory path
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get the notes file
  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // Save notes as simple key-value pairs
  static Future<void> saveNotes(Map<String, String> notes) async {
    try {
      final file = await _localFile;
      await file.writeAsString(jsonEncode(notes));
    } catch (e) {
      print('Error saving notes: $e');
    }
  }

  // Load notes from file, return empty strings if no file
  static Future<Map<String, String>> loadNotes() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return {'personal': '', 'shared': ''}; // Default empty notes
      }
      
      final contents = await file.readAsString();
      final Map<String, dynamic> notesJson = jsonDecode(contents);
      return {
        'personal': notesJson['personal'] ?? '',
        'shared': notesJson['shared'] ?? '',
      };
    } catch (e) {
      print('Error loading notes: $e');
      return {'personal': '', 'shared': ''}; // Return empty on error
    }
  }

  // Delete all notes (clear storage)
  static Future<void> clearNotes() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing notes: $e');
    }
  }
}

// ========================================
// SPENDING MODELS
// Data models and persistence for the money section
// ========================================

// Spending Item Model - Represents a single expense
class SpendingItem {
  final String id;          // Unique identifier  
  final String description; // What was bought
  final double amount;      // How much it cost
  final String currency;    // PLN, EUR, USD etc.
  final String section;     // 'personal' or 'shared'
  final DateTime createdAt; // When expense was added

  SpendingItem({
    required this.id,
    required this.description,
    required this.amount,
    required this.currency,
    required this.section,
    required this.createdAt,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'currency': currency,
      'section': section,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory SpendingItem.fromJson(Map<String, dynamic> json) {
    return SpendingItem(
      id: json['id'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      section: json['section'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  SpendingItem copyWith({
    String? id,
    String? description,
    double? amount,
    String? currency,
    String? section,
    DateTime? createdAt,
  }) {
    return SpendingItem(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      section: section ?? this.section,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Spending Data Manager - Handles persistence for expenses
class SpendingDataManager {
  static const String _fileName = 'expenses.json';
  
  // Get the file path
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // Save expenses to JSON file
  static Future<void> saveExpenses(List<SpendingItem> expenses) async {
    try {
      final file = await _localFile;
      final expensesJson = expenses.map((expense) => expense.toJson()).toList();
      await file.writeAsString(jsonEncode(expensesJson));
    } catch (e) {
      print('Error saving expenses: $e');
    }
  }

  // Load expenses from JSON file
  static Future<List<SpendingItem>> loadExpenses() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      
      final contents = await file.readAsString();
      final List<dynamic> expensesJson = jsonDecode(contents);
      return expensesJson.map((json) => SpendingItem.fromJson(json)).toList();
    } catch (e) {
      print('Error loading expenses: $e');
      return [];
    }
  }

  // Delete all expenses (clear storage)
  static Future<void> clearExpenses() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing expenses: $e');
    }
  }
}

import 'dart:math'; // For sin and pi functions in animations
import 'package:flutter/material.dart';
import 'design_system.dart';
import 'todo_models.dart';
import 'todo_widgets.dart';

// Entry point of the app
void main() => runApp(LiterallyHomeApp());

// Main app widget - sets up the overall theme and navigation
class LiterallyHomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiterallyHome',
      theme: AppDesign.lightTheme,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Home screen with bottom navigation between three sections
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track which section is active

  // The three main sections of the app
  final List<Widget> _pages = [
    NotesScreen(),    // literally text
    TodoScreen(),     // literally tasks  
    SpendingScreen(), // literally money
  ];

  // Switch between sections
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Show the selected section
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(AppDesign.spaceMd),
        color: AppDesign.background,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavButton('TEXT', Icons.edit_note, 0),
              _buildBottomNavButton('TASKS', Icons.check_box_outlined, 1),
              _buildBottomNavButton('MONEY', Icons.receipt_long, 2),
            ],
          ),
        ),
      ),
    );
  }

  // Build individual navigation button (white pill with icon)
  Widget _buildBottomNavButton(String label, IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(index),
        child: Container(
          padding: EdgeInsets.all(AppDesign.spaceMd),
          margin: EdgeInsets.symmetric(horizontal: AppDesign.spaceXs),
          decoration: BoxDecoration(
            color: isSelected ? AppDesign.surfaceSelected : AppDesign.surface,
            borderRadius: BorderRadius.circular(AppDesign.radiusMd),
            border: Border.all(color: AppDesign.border),
          ),
          child: Icon(
            icon,
            color: AppDesign.text,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _personalController = TextEditingController();
  final TextEditingController _sharedController = TextEditingController();
  
  String get _currentSection => _tabController.index == 0 ? 'personal' : 'shared';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotes();
  }

  // Load notes from storage
  Future<void> _loadNotes() async {
    final notes = await NotesDataManager.loadNotes();
    setState(() {
      _personalController.text = notes['personal'] ?? '';
      _sharedController.text = notes['shared'] ?? '';
    });
  }

  // Save notes to storage
  Future<void> _saveNotes() async {
    await NotesDataManager.saveNotes({
      'personal': _personalController.text,
      'shared': _sharedController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('literally text'),
        ),
      ),
      body: Column(
        children: [
          // Tab Buttons
          Container(
            padding: EdgeInsets.all(AppDesign.spaceMd),
            color: AppDesign.background, // Gray background, no border
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('PERSONAL', 0),
                ),
                SizedBox(width: AppDesign.spaceSm),
                Expanded(
                  child: _buildTabButton('SHARED', 1),
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotesEditor(_personalController),
                _buildNotesEditor(_sharedController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesEditor(TextEditingController controller) {
    return Container(
      padding: EdgeInsets.all(AppDesign.spaceMd),
      child: TextField(
        controller: controller,
        style: AppDesign.body,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: 'Start writing your ${_currentSection} notes...',
          hintStyle: AppDesign.bodySmall.copyWith(color: AppDesign.textMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusMd),
            borderSide: BorderSide(color: AppDesign.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusMd),
            borderSide: BorderSide(color: AppDesign.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusMd),
            borderSide: BorderSide(color: AppDesign.text, width: 2),
          ),
          filled: true,
          fillColor: AppDesign.surface,
          contentPadding: EdgeInsets.all(AppDesign.spaceMd),
        ),
        onChanged: (_) => _saveNotes(), // Auto-save on every change
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return _AnimatedTabButton(
      text: text,
      isSelected: isSelected,
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _personalController.dispose();
    _sharedController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

class TodoScreen extends StatefulWidget {
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with SingleTickerProviderStateMixin {
  List<Todo> _todos = [];
  final TextEditingController _taskController = TextEditingController();
  late TabController _tabController;
  
  String get _currentSection => _tabController.index == 0 ? 'personal' : 'shared';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodos();
  }

  // Load todos from storage
  Future<void> _loadTodos() async {
    final todos = await TodoDataManager.loadTodos();
    setState(() {
      _todos = todos;
    });
  }

  // Save todos to storage
  Future<void> _saveTodos() async {
    await TodoDataManager.saveTodos(_todos);
  }

  // Add new todo
  void _addTodo() {
    if (_taskController.text.trim().isEmpty) return;
    
    setState(() {
      _todos.add(Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _taskController.text.trim(),
        section: _currentSection,
        createdAt: DateTime.now(),
      ));
      _taskController.clear();
    });
    _saveTodos();
  }

  // Delete todo
  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
    _saveTodos();
  }

  // Edit todo
  void _editTodo(Todo updatedTodo) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
      }
    });
    _saveTodos();
  }

  // Get todos by section
  List<Todo> _getTodosBySection(String section) {
    return _todos.where((todo) => todo.section == section).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    final personalTodos = _getTodosBySection('personal');
    final sharedTodos = _getTodosBySection('shared');

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('literally tasks'),
        ),
      ),
      body: Column(
        children: [
          // Tab Buttons moved to body for consistent AppBar height
          Container(
            padding: EdgeInsets.all(AppDesign.spaceMd),
            color: AppDesign.background, // Gray background, no border
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('PERSONAL (${personalTodos.length})', 0),
                ),
                SizedBox(width: AppDesign.spaceSm),
                Expanded(
                  child: _buildTabButton('SHARED (${sharedTodos.length})', 1),
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTodoList(personalTodos),
                _buildTodoList(sharedTodos),
              ],
            ),
          ),
          
          // Bottom Add Task Bar
          Container(
            padding: EdgeInsets.all(AppDesign.spaceMd),
            color: AppDesign.background, // Gray background, no border
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      style: AppDesign.body,
                      decoration: AppDesign.inputDecoration(
                        hintText: 'Add to ${_currentSection.toUpperCase()}...',
                      ),
                      onSubmitted: (_) => _addTodo(),
                    ),
                  ),
                  SizedBox(width: AppDesign.spaceSm),
                  SizedBox(
                    height: AppDesign.buttonHeight,
                    width: AppDesign.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _addTodo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesign.addButton, // Nothing-style red
                        foregroundColor: Colors.white, // White icon on red background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        animationDuration: Duration.zero, // Remove animations
                        splashFactory: NoSplash.splashFactory, // No splash
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NO TASKS',
              style: AppDesign.label.copyWith(color: AppDesign.textMuted),
            ),
            SizedBox(height: AppDesign.spaceXs),
            Text(
              'Add a task to get started',
              style: AppDesign.bodySmall.copyWith(color: AppDesign.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppDesign.spaceMd),
      itemCount: todos.length,
      separatorBuilder: (context, index) => SizedBox(height: AppDesign.spaceSm),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _TodoCard(
          todo: todo,
          onComplete: () => _deleteTodo(todo.id),
          onEdit: _editTodo,
        );
      },
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return _AnimatedTabButton(
      text: text,
      isSelected: isSelected,
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

// Updated Todo Card Widget with inline editing and letter jump animation
class _TodoCard extends StatefulWidget {
  final Todo todo;
  final VoidCallback onComplete;
  final Function(Todo) onEdit;

  const _TodoCard({
    required this.todo,
    required this.onComplete,
    required this.onEdit,
  });

  @override
  State<_TodoCard> createState() => __TodoCardState();
}

class __TodoCardState extends State<_TodoCard> with TickerProviderStateMixin {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  List<Animation<double>> _letterAnimations = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todo.title);
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _setupLetterAnimations();
  }

  void _setupLetterAnimations() {
    _letterAnimations.clear();
    final letterCount = widget.todo.title.length;
    
    for (int i = 0; i < letterCount; i++) {
      final startTime = (i * 0.1).clamp(0.0, 0.6); // Stagger each letter
      final endTime = (startTime + 0.3).clamp(0.0, 1.0);
      
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(startTime, endTime, curve: Curves.elasticOut),
        ),
      );
      
      _letterAnimations.add(animation);
    }
  }

  void _startEditing() {
    // Play the letter jump animation first
    _animationController.forward().then((_) {
      // Reset animation for next time
      _animationController.reset();
      
      // Then start editing
      setState(() {
        _isEditing = true;
      });
      _focusNode.requestFocus();
    });
  }

  void _saveEdit() {
    if (_controller.text.trim().isNotEmpty && _controller.text.trim() != widget.todo.title) {
      widget.onEdit(widget.todo.copyWith(title: _controller.text.trim()));
      // Update animations for the new text
      _setupLetterAnimations();
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _cancelEdit() {
    _controller.text = widget.todo.title; // Reset to original
    setState(() {
      _isEditing = false;
    });
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Wrap(
          children: widget.todo.title.split('').asMap().entries.map((entry) {
            final index = entry.key;
            final letter = entry.value;
            
            // Get animation value for this letter (default to 0 if not enough animations)
            final animationValue = index < _letterAnimations.length 
                ? _letterAnimations[index].value 
                : 0.0;
            
            // Calculate jump offset
            final jumpOffset = sin(animationValue * pi) * 8; // Jump up to 8 pixels
            
            return Transform.translate(
              offset: Offset(0, -jumpOffset),
              child: Text(
                letter,
                style: AppDesign.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesign.background,
        border: Border.all(color: AppDesign.border),
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDesign.spaceMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Complete button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onComplete,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppDesign.border, width: 2),
                    borderRadius: BorderRadius.circular(AppDesign.radiusSm),
                    color: AppDesign.surface,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppDesign.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: AppDesign.spaceMd),
            
            // Content - editable or display with animation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEditing)
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: AppDesign.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _saveEdit(),
                      onTapOutside: (_) => _saveEdit(),
                    )
                  else
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _startEditing,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          width: double.infinity,
                          child: _buildAnimatedTitle(),
                        ),
                      ),
                    ),
                  SizedBox(height: AppDesign.spaceXs),
                  Text(
                    _formatDate(widget.todo.createdAt),
                    style: AppDesign.bodySmall.copyWith(
                      color: AppDesign.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'YESTERDAY';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}D AGO';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class TodoEditScreen extends StatelessWidget {
  final Todo todo;
  final Function(Todo) onSave;
  final VoidCallback onDelete;

  const TodoEditScreen({
    required this.todo,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController(text: todo.title);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Todo'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              onDelete();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDesign.spaceMd),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: AppDesign.body.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                  borderSide: BorderSide(color: AppDesign.border, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                  borderSide: BorderSide(color: AppDesign.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                  borderSide: BorderSide(color: AppDesign.text, width: 2),
                ),
                filled: true,
                fillColor: AppDesign.surface,
                contentPadding: EdgeInsets.all(AppDesign.spaceMd),
              ),
              onSubmitted: (_) {
                final updatedTodo = todo.copyWith(title: _controller.text.trim());
                onSave(updatedTodo);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TodoDataManager {
  static Future<List<Todo>> loadTodos() async {
    // Simulate loading from storage with a delay
    await Future.delayed(Duration(seconds: 1));
    return [];
  }

  static Future<void> saveTodos(List<Todo> todos) async {
    // Simulate saving to storage with a delay
    await Future.delayed(Duration(seconds: 1));
  }
}

class SpendingScreen extends StatefulWidget {
  @override
  State<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen> with SingleTickerProviderStateMixin {
  List<SpendingItem> _expenses = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late TabController _tabController;
  String _selectedCurrency = 'PLN';
  
  String get _currentSection => _tabController.index == 0 ? 'personal' : 'shared';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExpenses();
  }

  // Load expenses from storage
  Future<void> _loadExpenses() async {
    final expenses = await SpendingDataManager.loadExpenses();
    setState(() {
      _expenses = expenses;
    });
  }

  // Save expenses to storage
  Future<void> _saveExpenses() async {
    await SpendingDataManager.saveExpenses(_expenses);
  }

  // Add new expense
  void _addExpense() {
    if (_descriptionController.text.trim().isEmpty || _amountController.text.trim().isEmpty) return;
    
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    
    setState(() {
      _expenses.add(SpendingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descriptionController.text.trim(),
        amount: amount,
        currency: _selectedCurrency,
        section: _currentSection,
        createdAt: DateTime.now(),
      ));
      _descriptionController.clear();
      _amountController.clear();
    });
    _saveExpenses();
  }

  // Delete expense
  void _deleteExpense(String id) {
    setState(() {
      _expenses.removeWhere((expense) => expense.id == id);
    });
    _saveExpenses();
  }

  // Get expenses by section
  List<SpendingItem> _getExpensesBySection(String section) {
    return _expenses.where((expense) => expense.section == section).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    final personalExpenses = _getExpensesBySection('personal');
    final sharedExpenses = _getExpensesBySection('shared');

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('literally money'),
        ),
      ),
      body: Column(
        children: [
          // Tab Buttons
          Container(
            padding: EdgeInsets.all(AppDesign.spaceMd),
            color: AppDesign.background, // Gray background, no border
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('PERSONAL (${personalExpenses.length})', 0),
                ),
                SizedBox(width: AppDesign.spaceSm),
                Expanded(
                  child: _buildTabButton('SHARED (${sharedExpenses.length})', 1),
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExpenseList(personalExpenses),
                _buildExpenseList(sharedExpenses),
              ],
            ),
          ),
          
          // Bottom Add Expense Bar
          Container(
            padding: EdgeInsets.all(AppDesign.spaceMd),
            color: AppDesign.background, // Gray background, no border
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Description field
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _descriptionController,
                      style: AppDesign.body,
                      decoration: AppDesign.inputDecoration(
                        hintText: 'Description...',
                      ),
                      onSubmitted: (_) => _addExpense(),
                    ),
                  ),
                  SizedBox(width: AppDesign.spaceSm),
                  
                  // Amount field
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _amountController,
                      style: AppDesign.body,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: AppDesign.inputDecoration(
                        hintText: '0.00',
                      ),
                      onSubmitted: (_) => _addExpense(),
                    ),
                  ),
                  SizedBox(width: AppDesign.spaceSm),
                  
                  // Currency selector
                  Container(
                    height: AppDesign.buttonHeight,
                    padding: EdgeInsets.symmetric(horizontal: AppDesign.spaceSm),
                    decoration: BoxDecoration(
                      color: AppDesign.surface,
                      borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                      border: Border.all(color: AppDesign.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCurrency,
                        style: AppDesign.body,
                        items: ['PLN', 'EUR', 'USD'].map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: AppDesign.spaceSm),
                  
                  // Add button
                  SizedBox(
                    height: AppDesign.buttonHeight,
                    width: AppDesign.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _addExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesign.addButton, // Nothing-style red
                        foregroundColor: Colors.white, // White icon on red background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        animationDuration: Duration.zero, // Remove animations
                        splashFactory: NoSplash.splashFactory, // No splash
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<SpendingItem> expenses) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NO EXPENSES',
              style: AppDesign.label.copyWith(color: AppDesign.textMuted),
            ),
            SizedBox(height: AppDesign.spaceXs),
            Text(
              'Add an expense to get started',
              style: AppDesign.bodySmall.copyWith(color: AppDesign.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppDesign.spaceMd),
      itemCount: expenses.length,
      separatorBuilder: (context, index) => SizedBox(height: AppDesign.spaceSm),
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _SpendingCard(
          expense: expense,
          onDelete: () => _deleteExpense(expense.id),
        );
      },
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return _AnimatedTabButton(
      text: text,
      isSelected: isSelected,
      onTap: () {
        _tabController.animateTo(index);
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

// Spending Card Widget
class _SpendingCard extends StatelessWidget {
  final SpendingItem expense;
  final VoidCallback onDelete;

  const _SpendingCard({
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesign.background,
        border: Border.all(color: AppDesign.border),
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDesign.spaceMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Delete button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDelete,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppDesign.border, width: 2),
                    borderRadius: BorderRadius.circular(AppDesign.radiusSm),
                    color: AppDesign.surface,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppDesign.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: AppDesign.spaceMd),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    expense.description,
                    style: AppDesign.body.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppDesign.spaceXs),
                  Text(
                    _formatDate(expense.createdAt),
                    style: AppDesign.bodySmall.copyWith(
                      color: AppDesign.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            
            // Amount
            Text(
              '${expense.amount.toStringAsFixed(2)} ${expense.currency}',
              style: AppDesign.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppDesign.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'YESTERDAY';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}D AGO';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

// Animated Tab Button with Stadium Wave Effect
class _AnimatedTabButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedTabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedTabButton> createState() => __AnimatedTabButtonState();
}

class __AnimatedTabButtonState extends State<_AnimatedTabButton> with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<Animation<double>> _letterAnimations = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _setupLetterAnimations();
  }

  void _setupLetterAnimations() {
    _letterAnimations.clear();
    final letterCount = widget.text.length;
    
    for (int i = 0; i < letterCount; i++) {
      // Each letter starts its animation 50ms after the previous one
      final startTime = (i * 0.08).clamp(0.0, 0.6); // Wave timing
      final endTime = (startTime + 0.2).clamp(0.0, 1.0); // Quick bounce
      
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(startTime, endTime, curve: Curves.easeInOut),
        ),
      );
      
      _letterAnimations.add(animation);
    }
  }

  void _triggerWaveAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(_AnimatedTabButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _setupLetterAnimations();
    }
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.text.split('').asMap().entries.map((entry) {
            final index = entry.key;
            final letter = entry.value;
            
            // Skip spaces to avoid weird positioning
            if (letter == ' ') {
              return SizedBox(width: 4); // Space width
            }
            
            // Get animation value for this letter
            final animationValue = index < _letterAnimations.length 
                ? _letterAnimations[index].value 
                : 0.0;
            
            // Calculate jump offset - half letter height up and down
            final jumpOffset = sin(animationValue * pi) * 8; // 8px jump (roughly half letter height)
            
            return Transform.translate(
              offset: Offset(0, -jumpOffset),
              child: Text(
                letter,
                style: AppDesign.button.copyWith(color: AppDesign.text),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _triggerWaveAnimation();
        widget.onTap();
      },
      child: Container(
        height: AppDesign.buttonHeight,
        padding: EdgeInsets.symmetric(
          horizontal: AppDesign.spaceMd,
          vertical: AppDesign.spaceSm,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected ? AppDesign.surfaceSelected : AppDesign.surface,
          borderRadius: BorderRadius.circular(AppDesign.radiusMd),
          border: Border.all(color: AppDesign.border),
        ),
        child: Center(
          child: _buildAnimatedText(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}


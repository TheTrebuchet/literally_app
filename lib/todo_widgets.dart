import 'package:flutter/material.dart';
import 'design_system.dart';
import 'todo_models.dart';

// Todo Card Widget - Simplified
class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoCard({
    Key? key,
    required this.todo,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: AppDesign.body,
                  ),
                  SizedBox(height: AppDesign.spaceXs),
                  Text(
                    _formatDate(todo.createdAt),
                    style: AppDesign.bodySmall.copyWith(
                      color: AppDesign.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: AppDesign.spaceSm),
            
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: EdgeInsets.all(AppDesign.spaceXs),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppDesign.textSecondary,
                    ),
                  ),
                ),
                SizedBox(width: AppDesign.spaceXs),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: EdgeInsets.all(AppDesign.spaceXs),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppDesign.error,
                    ),
                  ),
                ),
              ],
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

// Edit Todo Dialog
class EditTodoDialog extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onSave;

  const EditTodoDialog({
    Key? key,
    required this.todo,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  late TextEditingController _titleController;
  late String _selectedSection;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _selectedSection = widget.todo.section;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppDesign.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        side: const BorderSide(color: AppDesign.border),
      ),
      title: Text('EDIT TASK', style: AppDesign.heading2),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: AppDesign.body,
              decoration: AppDesign.inputDecoration(labelText: 'TASK TITLE'),
              autofocus: true,
            ),
            SizedBox(height: AppDesign.spaceMd),
            DropdownButtonFormField<String>(
              value: _selectedSection,
              style: AppDesign.bodySmall,
              decoration: AppDesign.inputDecoration(labelText: 'SECTION'),
              items: ['personal', 'shared'].map((section) {
                return DropdownMenuItem(
                  value: section,
                  child: Text(section.toUpperCase(), style: AppDesign.bodySmall),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSection = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: AppDesign.secondaryButtonStyle,
          child: Text('CANCEL'),
        ),
        SizedBox(width: AppDesign.spaceSm),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isNotEmpty) {
              widget.onSave(widget.todo.copyWith(
                title: _titleController.text.trim(),
                section: _selectedSection,
              ));
              Navigator.of(context).pop();
            }
          },
          style: AppDesign.primaryButtonStyle,
          child: Text('SAVE'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

// Add Task Bottom Sheet
class AddTaskBottomSheet extends StatefulWidget {
  final Function(String title, String section) onAdd;

  const AddTaskBottomSheet({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedSection = 'personal';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDesign.spaceMd,
        right: AppDesign.spaceMd,
        top: AppDesign.spaceMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDesign.spaceMd,
      ),
      decoration: BoxDecoration(
        color: AppDesign.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDesign.radiusLg),
          topRight: Radius.circular(AppDesign.radiusLg),
        ),
        border: Border.all(color: AppDesign.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ADD TASK', style: AppDesign.heading2),
          SizedBox(height: AppDesign.spaceMd),
          TextField(
            controller: _titleController,
            style: AppDesign.body,
            decoration: AppDesign.inputDecoration(hintText: 'Task title...'),
            autofocus: true,
          ),
          SizedBox(height: AppDesign.spaceMd),
          DropdownButtonFormField<String>(
            value: _selectedSection,
            style: AppDesign.bodySmall,
            decoration: AppDesign.inputDecoration(labelText: 'SECTION'),
            items: ['personal', 'shared'].map((section) {
              return DropdownMenuItem(
                value: section,
                child: Text(section.toUpperCase(), style: AppDesign.bodySmall),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSection = value!;
              });
            },
          ),
          SizedBox(height: AppDesign.spaceLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: AppDesign.secondaryButtonStyle,
                  child: Text('CANCEL'),
                ),
              ),
              SizedBox(width: AppDesign.spaceMd),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.trim().isNotEmpty) {
                      widget.onAdd(_titleController.text.trim(), _selectedSection);
                      Navigator.of(context).pop();
                    }
                  },
                  style: AppDesign.primaryButtonStyle,
                  child: Text('ADD'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

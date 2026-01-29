import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notu/models/todo.dart';
import 'package:notu/utils/database_helper.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<Todo>> _todosFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _todosFuture = dbHelper.getTodos();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  void _addTodo(String title) async {
    if (title.isNotEmpty) {
      await dbHelper.insertTodo(Todo(title: title, createdAt: DateTime.now()));
      setState(() {
        _todosFuture = dbHelper.getTodos();
        _searchController.clear(); // Clear search on new item
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$title" added to your list.')),
        );
      }
    }
  }

  void _editTodo(Todo todo) async {
    await dbHelper.updateTodo(todo);
    setState(() {
      _todosFuture = dbHelper.getTodos();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To-do item updated.')),
      );
    }
  }

  void _toggleTodo(Todo todo) async {
    await dbHelper.updateTodo(Todo(
        id: todo.id,
        title: todo.title,
        isDone: !todo.isDone,
        createdAt: todo.createdAt));
    setState(() {
      _todosFuture = dbHelper.getTodos();
    });
  }

  void _deleteTodo(int id) async {
    await dbHelper.deleteTodo(id);
    setState(() {
      _todosFuture = dbHelper.getTodos();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To-do item removed.')),
      );
    }
  }

  void _clearCompleted() async {
    final todos = await _todosFuture;
    for (var todo in todos) {
      if (todo.isDone) {
        await dbHelper.deleteTodo(todo.id!);
      }
    }
    setState(() {
      _todosFuture = dbHelper.getTodos();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cleared all completed tasks.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearCompleted,
            tooltip: 'Clear Completed Tasks',
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface.withAlpha(128),
        child: Column(
          children: [
            _buildSearchField(),
            Expanded(child: _buildTodoList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New To-Do'),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search your to-dos...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    return FutureBuilder<List<Todo>>(
      future: _todosFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final allTodos = snapshot.data!;
        final activeTodos = allTodos
            .where((todo) =>
                !todo.isDone &&
                todo.title.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
        final completedTodos = allTodos
            .where((todo) =>
                todo.isDone &&
                todo.title.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        if (allTodos.isEmpty) {
          return _buildEmptyState();
        }

        if (activeTodos.isEmpty &&
            completedTodos.isEmpty &&
            _searchQuery.isNotEmpty) {
          return _buildNoResultsState();
        }

        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final todo = activeTodos[index];
                  return _buildTodoItem(todo);
                },
                childCount: activeTodos.length,
              ),
            ),
            if (completedTodos.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Completed (${completedTodos.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final todo = completedTodos[index];
                  return _buildTodoItem(todo);
                },
                childCount: completedTodos.length,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showTodoContextMenu(context, todo, details.globalPosition);
      },
      child: Dismissible(
        key: Key(todo.id.toString()),
        onDismissed: (direction) => _deleteTodo(todo.id!),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
            title: Text(
              todo.title,
              style: TextStyle(
                fontSize: 16,
                decoration: todo.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: todo.isDone
                    ? Theme.of(context).textTheme.bodySmall?.color
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: todo.createdAt != null
                ? Text(
                    DateFormat.yMMMd().add_jm().format(todo.createdAt!),
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : null,
            leading: Checkbox(
              value: todo.isDone,
              onChanged: (value) => _toggleTodo(todo),
              activeColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            onTap: () => _toggleTodo(todo), // Toggle on tap anywhere
          ),
        ),
      ),
    );
  }

  void _showTodoContextMenu(
      BuildContext context, Todo todo, Offset tapPosition) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: const Text('Edit'),
          onTap: () => _showEditTodoDialog(context, todo),
        ),
        PopupMenuItem(
          child: const Text('Delete'),
          onTap: () => _deleteTodo(todo.id!),
        ),
      ],
    );
  }

  void _showEditTodoDialog(BuildContext context, Todo todo) {
    final controller = TextEditingController(text: todo.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit To-Do'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g., Buy groceries',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              _editTodo(Todo(
                  id: todo.id,
                  title: value,
                  isDone: todo.isDone,
                  createdAt: todo.createdAt));
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _editTodo(Todo(
                    id: todo.id,
                    title: controller.text,
                    isDone: todo.isDone,
                    createdAt: todo.createdAt));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_box_outline_blank,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withAlpha(128)),
          const SizedBox(height: 20),
          Text(
            'Your to-do list is empty',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the "New To-Do" button to get started.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'No results found for "$_searchQuery"',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddTodoDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add a New To-Do'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g., Buy groceries',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              _addTodo(value);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addTodo(controller.text);
                Navigator.pop(context);
              },
              child: const Text(
                'Add',
              ),
            )
          ],
        );
      },
    );
  }
}

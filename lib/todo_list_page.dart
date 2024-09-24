import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _taskController = TextEditingController();
  final CollectionReference _todoCollection =
      FirebaseFirestore.instance.collection('todo');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Column(
        children: [
          _buildTaskInputField(),
          Expanded(child: _buildTodoList()),
        ],
      ),
    );
  }

  Widget _buildTaskInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: 'New Task'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTask,
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _todoCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final listTodo = snapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: listTodo.length,
          itemBuilder: (context, index) {
            final todo = listTodo[index];
            return ListTile(
              title: Text(todo['task']),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTask(todo.id),
              ),
            );
          },
        );
      },
    );
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      _todoCollection.add({'task': _taskController.text});
      _taskController.clear();
    }
  }

  void _deleteTask(String id) {
    _todoCollection.doc(id).delete();
  }
}

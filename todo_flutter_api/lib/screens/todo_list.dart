import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_flutter_api/screens/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage>{
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
       onRefresh: fetchTodo,
       child: ListView.builder( 
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items [index] as Map;
          final id = item['_id'] as String;
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(item['title']),
            subtitle: Text(item['description']),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if(value == 'edit'){
                  //Open Edit Page
                  navigateToEditPage(item);
                }else if(value == 'delete'){
                  // Delete and remove the item
                  deleteById(id);
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text('Editar'),
                    value: 'edit',
                  ),
                  PopupMenuItem(
                    child: Text('Eliminar'),
                    value: 'delete',
                  ),
                ];
              },
            ),
          );
        },
       ),
      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage, 
        label: Text('Agregar Tarea')
      ),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    //Delete the item
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if(response.statusCode ==200){
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    }else{
      showErrorMessage('Deletion Failed');
    }
  }

  Future<void> fetchTodo() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

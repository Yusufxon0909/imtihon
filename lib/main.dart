import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TodoListPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'Rasm/11.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Map<String, dynamic>> personalTasks = [];
  List<Map<String, dynamic>> defaultTasks = [];
  List<Map<String, dynamic>> studyTasks = [];
  List<Map<String, dynamic>> workTasks = [];
  int _currentTabIndex = 0;
  String task = '';
  String description = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  List<Map<String, dynamic>> get currentTaskList {
    switch (_currentTabIndex) {
      case 0:
        return personalTasks;
      case 1:
        return defaultTasks;
      case 2:
        return studyTasks;
      case 3:
        return workTasks;
      default:
        return [];
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('personalTasks', jsonEncode(personalTasks));
    await prefs.setString('defaultTasks', jsonEncode(defaultTasks));
    await prefs.setString('studyTasks', jsonEncode(studyTasks));
    await prefs.setString('workTasks', jsonEncode(workTasks));
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      personalTasks = _decodeTaskList(prefs.getString('personalTasks') ?? '[]');
      defaultTasks = _decodeTaskList(prefs.getString('defaultTasks') ?? '[]');
      studyTasks = _decodeTaskList(prefs.getString('studyTasks') ?? '[]');
      workTasks = _decodeTaskList(prefs.getString('workTasks') ?? '[]');
    });
  }

  List<Map<String, dynamic>> _decodeTaskList(String encoded) {
    return List<Map<String, dynamic>>.from(jsonDecode(encoded));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => task = value,
                  decoration: InputDecoration(labelText: 'Task'),
                ),
                TextField(
                  onChanged: (value) => description = value,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Pick Date',
                          style: TextStyle(color: Colors.green)),
                    ),
                    TextButton(
                      onPressed: () => _selectTime(context),
                      child: Text('Pick Time',
                          style: TextStyle(color: Colors.green)),
                    ),
                  ],
                ),
                if (selectedDate != null)
                  Text(
                      'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
                if (selectedTime != null)
                  Text('Selected Time: ${selectedTime!.format(context)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.purple)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentTaskList.add({
                    'task': task,
                    'description': description,
                    'date': selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    'time': selectedTime != null
                        ? selectedTime!.format(context)
                        : TimeOfDay.now().format(context),
                    'completed': false,
                  });
                });
                _saveTasks();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      currentTaskList[index]['completed'] =
          !currentTaskList[index]['completed'];
    });
    _saveTasks();
  }

  void _navigateToTaskDetails(BuildContext context, Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(task: task),
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      currentTaskList.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Today's Tasks",
            style: TextStyle(color: Colors.green),
          ),
          centerTitle: true,
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            tabs: [
              Tab(
                  child:
                      Text('Personal', style: TextStyle(color: Colors.green))),
              Tab(
                  child:
                      Text('Default', style: TextStyle(color: Colors.green))),
              Tab(child: Text('Study', style: TextStyle(color: Colors.green))),
              Tab(child: Text('Work', style: TextStyle(color: Colors.green))),
            ],
          ),
        ),
        body: currentTaskList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset('Rasm/11.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: currentTaskList.length,
                itemBuilder: (context, index) {
                  final task = currentTaskList[index];
                  final isCompleted = task['completed'];

                  return Dismissible(
                    key: Key(task['task']),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteTask(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Task deleted'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    // background: Container(
                    //   color: Colors.red,
                    //   alignment: Alignment.centerRight,
                    //   padding: EdgeInsets.symmetric(horizontal: 20),
                    //   child: Icon(Icons.delete, color: Colors.white),
                    // ),
                    child: ListTile(
                      title: Text(
                        task['task'],
                        style: TextStyle(
                          color: Colors.green,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text('${task['date']}  ${task['time']}'),
                      trailing: Checkbox(
                        value: isCompleted,
                        onChanged: (bool? value) {
                          _toggleTaskCompletion(index);
                        },
                        activeColor: Colors.green,
                      ),
                      onTap: () => _navigateToTaskDetails(context, task),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTodoDialog(context),
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}

class TaskDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  TaskDetailsScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: TextStyle(color: Colors.green),
        ),
        leading: BackButton(color: Colors.green),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task:', style: _boldGreenTextStyle()),
            SizedBox(height: 8),
            Text(task['task'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Description:', style: _boldGreenTextStyle()),
            SizedBox(height: 8),
            Text(task['description'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Date:', style: _boldGreenTextStyle()),
            SizedBox(height: 8),
            Text(task['date'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Time:', style: _boldGreenTextStyle()),
            SizedBox(height: 8),
            Text(task['time'], style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  TextStyle _boldGreenTextStyle() {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    );
  }
}

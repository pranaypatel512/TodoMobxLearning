import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:todo_mobx_learning/todolist.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const TodoExample(),
    );
  }
}

class TodoExample extends StatelessWidget {
  const TodoExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Provider<TodoList>(
      create: (_) => TodoList(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Todos'),
          ),
          body: Column(
            children: <Widget>[
              AddTodo(),
              const ActionBar(),
              const Description(),
              const TodoListView()
            ],
          )));
}

/*Add to do widget*/
class AddTodo extends StatelessWidget {
  final _textController = TextEditingController(text: '');

  AddTodo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<TodoList>(context);

    return TextField(
      autofocus: true,
      decoration: const InputDecoration(
          labelText: "Add new Todo", contentPadding: EdgeInsets.all(8)),
      controller: _textController,
      textInputAction: TextInputAction.done,
      onSubmitted: (String value) {
        list.addTodo(value);
        _textController.clear();
      },
    );
  }
}

/*Action bar widget*/

class ActionBar extends StatelessWidget {
  const ActionBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<TodoList>(context);

    return Column(
      children: <Widget>[
        Observer(
          builder: (_) {
            final selections = VisibilityFilter.values
                .map((e) => e == list.filter)
                .toList(growable: false);

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    onPressed: (index) {
                      list.filter = VisibilityFilter.values[index];
                    },
                    isSelected: selections,
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Text("All"),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Text("Pending"),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Text("Completed"),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ),
        Observer(builder: (_) =>
            ButtonBar(children: <Widget>[
              ElevatedButton(onPressed: list.canRemoveAllCompleted
                  ? list.removeCompleted
                  : null, child: const Text('Remove Completed')),
              ElevatedButton(onPressed: list.canMarkAllCompleted
                  ? list.markAllAsCompleted
                  : null, child: const Text('Mark All Completed'))
            ],)
        )
      ],
    );
  }
}


class TodoListView extends StatelessWidget {
  const TodoListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<TodoList>(context);

    return Observer(
        builder: (_) => Flexible(
            child: ListView.builder(
                itemCount: list.visibleTodos.length,
                itemBuilder: (_, index) {
                  final todo = list.visibleTodos[index];
                  return Observer(
                      builder: (_) => CheckboxListTile(
                            value: todo.done,
                            onChanged: (flag) => todo.done = flag!,
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Text(
                                  todo.description,
                                  overflow: TextOverflow.ellipsis,
                                )),
                                IconButton(
                                    onPressed: () => list.removeTodo(todo),
                                    icon: const Icon(Icons.delete))
                              ],
                            ),
                          ));
                })));
  }
}

/*Description widget*/
class Description extends StatelessWidget {
  const Description({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<TodoList>(context);

    return Observer(
        builder: (_) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              list.itemDescription,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )));
  }
}
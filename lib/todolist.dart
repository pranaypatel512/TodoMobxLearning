import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:todo_mobx_learning/todo.dart';

part 'todolist.g.dart';

enum VisibilityFilter {all,pending,completed}

@JsonSerializable()
class TodoList = _TodoList with _$TodoList;

abstract class _TodoList with Store{
  @observable
  @ObservableTodoListConverter()
  ObservableList<Todo> todos = ObservableList<Todo>();

  @observable
  VisibilityFilter filter = VisibilityFilter.all;

  @computed
  ObservableList<Todo> get pendingTodos => ObservableList.of(todos.where((element) => element.done!=true));

  @computed
  ObservableList<Todo> get completedTodos => ObservableList.of(todos.where((element) => element.done==true));

  @computed
  bool get hasCompletedTodos => completedTodos.isNotEmpty;

  @computed
  bool get hasPendingTodos => pendingTodos.isNotEmpty;

  @computed
  String get itemDescription {
    if(todos.isEmpty){
      return "There are no Todos here. Why don't you add one?.";
    }
    final suffix = pendingTodos.length == 1? 'todo' : 'todos';
    return '${pendingTodos.length} pending $suffix, ${completedTodos.length} completed';
  }

  @computed
  @JsonKey(ignore: true)
  ObservableList<Todo> get visibleTodos {
    switch(filter){
      case VisibilityFilter.pending:
        return pendingTodos;
      case VisibilityFilter.completed:
        return completedTodos;
      default:
        return todos;
    }
  }

  @computed
  bool get canRemoveAllCompleted =>
      hasCompletedTodos && filter != VisibilityFilter.pending;

  @computed
  bool get canMarkAllCompleted =>
      hasPendingTodos && filter != VisibilityFilter.completed;

  @action
  void addTodo(String description){
    todos.add(Todo(description));
  }

  @action
  void removeTodo(Todo todo){
    todos.removeWhere((item)=>item==todo);
  }

  @action
  void changeFilter(VisibilityFilter filter) => this.filter=filter;

  @action
  void removeCompleted(){
    todos.removeWhere((element) => element.done);
  }

  @action
  void markAllAsCompleted(){
    for (final todo in todos) {
      todo.done = true;
    }
  }

}

class ObservableTodoListConverter extends JsonConverter<ObservableList<Todo>,Iterable<Map<String,dynamic>>> {
  const ObservableTodoListConverter();
  @override
  ObservableList<Todo> fromJson(Iterable<Map<String, dynamic>> json) {
    return ObservableList.of(json.map(Todo.fromJson));
  }

  @override
  Iterable<Map<String, dynamic>> toJson(ObservableList<Todo> object) {
      return object.map((element) => element.toJson());
  }

}
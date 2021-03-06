import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_task/bloc/business_logic/todo_state.dart';
import 'package:todo_task/constant.dart';
import 'package:todo_task/data/datasources/local/storage_pref.dart';
import 'package:todo_task/data/datasources/remot/sign_mail_firebase.dart';
import 'package:todo_task/data/model/todo_model.dart';
import 'package:todo_task/data/repository/todo_repository.dart';

enum TodoState { ACTIVE, DONE, FINISH }

class TodoCubit extends Cubit<TodoAppState> {
  TodoCubit() : super(InitialViewTodoScreen());

  static TodoCubit get(BuildContext context) => BlocProvider.of(context);

  final TodoRepository _todoRepository = TodoRepository();
  List<TodoModel> activeTodo = [];
  List<TodoModel> finishTodo = [];
  List<TodoModel> allTodo = [];

  Map<int, String> stateTodo = {};
  Map<int, Color> colorStateTodo = {};

  Future<bool> signIn({
    @required String email,
    @required String password,
  }) async {
    bool isLogin;
    final result =
        await SignMailFirebase.signIn(email: email, password: password);
    result.fold((l) {
      emit(ErrorSignState(message: l));
      isLogin = false;
    }, (r) {
      isLogin = true;
    });
    return isLogin;
  }

  Future<bool> signUp({
    @required String email,
    @required String password,
  }) async {
    bool isRegister;
    final result =
        await SignMailFirebase.signUp(email: email, password: password);
    result.fold((l) {
      emit(ErrorSignState(message: l));
      isRegister = false;
    }, (r) {
      isRegister = true;
    });
    return isRegister;
  }

  void getAllDataFromDB() {
    _todoRepository.queryDb().then((data) {
      if (allTodo.isNotEmpty) resetData();
      allTodo.addAll(data);
      allTodo = allTodo.reversed.toList();
      addDataInTaskAndFinish();
      for (final todo in allTodo) {
        stateTodo.addAll(
          {
            todo.id: splitText(todo.date, todo.isFinish),
          },
        );
        colorStateTodo.addAll(
          {
            todo.id: setColorToText(stateTodo[todo.id]),
          },
        );
      }
      emit(SuccessDataState(allTodo, activeTodo, finishTodo));
    }).catchError((error) {
      print(error.toString());
      emit(ErrorDataState());
    });
  }

  void addDataInTaskAndFinish() {
    const int taskNotDone = 0;
    allTodo.where((todo) {
      if (todo.isFinish == taskNotDone) {
        addActiveDataAndFinished(todo);
        return true;
      } else {
        finishTodo.add(todo);
        return true;
      }
    }).toList();
  }

  void resetData() {
    allTodo.clear();
    activeTodo.clear();
    finishTodo.clear();
    stateTodo.clear();
    colorStateTodo.clear();
  }

  void addActiveDataAndFinished(TodoModel model) {
    final bool isFinish =
        compareDate(model.date) == TodoState.FINISH ? true : false;
    if (isFinish) {
      finishTodo.add(model);
    } else {
      activeTodo.add(model);
    }
  }

  TodoState compareDate(String firstData, [int isDone]) {
    const finishTaskEqual = 1;
    if (isDone == finishTaskEqual) {
      return TodoState.DONE;
    }
    final String nowDate = DateFormat('y-MM-dd').format(DateTime.now());
    final DateTime saveDate = DateTime.parse(firstData);
    final DateTime currentNowDate = DateTime.parse(nowDate);
    if (saveDate.isAfter(currentNowDate)) {
      return TodoState.ACTIVE;
    } else if (saveDate.isBefore(currentNowDate)) {
      return TodoState.FINISH;
    } else {
      return TodoState.ACTIVE;
    }
  }

  String splitText(String firstData, [int isDone]) {
    final TodoState state = compareDate(firstData, isDone);
    return state.toString().split('.').last;
  }

  Color setColorToText(String state) {
    Color color;
    switch (state) {
      case 'DONE':
        color = Colors.amber[400];
        break;
      case 'ACTIVE':
        color = Colors.green[400];
        break;
      case 'FINISH':
        color = Colors.red[400];
        break;
    }
    return color;
  }

  Future<bool> insertItem(TodoModel model) async {
    emit(ConnectLoadingDBState());
    bool isUpdate;
    try {
      final int index = await _todoRepository.insertDb(model);
      if (index > 0) {
        isUpdate = true;
        emit(SuccessInsertState(message: 'Successfully Add'));
      } else {
        isUpdate = false;
        emit(ErrorInsertState(message: 'Error Add'));
      }
    } on Exception {
      isUpdate = false;
      emit(ErrorInsertState(message: 'Error Add'));
    }
    return isUpdate;
  }

  Future<bool> updateItem(TodoModel model) async {
    emit(ConnectLoadingDBState());
    bool isUpdate;
    try {
      final int index = await _todoRepository.updateDb(model);
      if (index > 0) {
        isUpdate = true;
        emit(SuccessUpdateState(message: 'Successfully Update'));
      } else {
        isUpdate = false;
        emit(ErrorUpdateState(message: 'Error Update'));
      }
    } on Exception {
      isUpdate = false;
      emit(ErrorUpdateState(message: 'Error Update'));
    }
    return isUpdate;
  }

  void deleteItemFromDB(TodoModel model) {
    _todoRepository.deleteDb(model).then((value) {
      emit(SuccessDeleteData(message: 'Successfully Delete'));
    }).catchError((error) {
      print(error.toString());
      emit(ErrorDeleteData(message: 'Error Delete'));
    });
  }

  Future<void> changeStyle(bool value) async {
    switchState = value;
    await StoragePref.setValue('isDark', switchState);
    emit(ChangeStyleMode(styleMode: switchState));
  }
}

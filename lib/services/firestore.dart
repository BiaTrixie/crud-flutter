import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //get collection of todo
  final CollectionReference todos = FirebaseFirestore.instance.collection('todos');
  
  //CREATE
  Future<void> addTask(String task) {
    return todos.add({
      'createdOn': Timestamp.now(),
      'isDone': false,
      'task': task,
      'updateOn': Timestamp.now(),
    });
  }

  //READ
  Stream<QuerySnapshot> getTaskStream() {
    final tasksStream = todos.orderBy('createdOn', descending: true).snapshots();
    return tasksStream;
  }

  //UPDATE
  Future<void> updateTask(String docID, String newTask) {
    return todos.doc(docID).update({
      'task': newTask,
      'updateOn': Timestamp.now(),
    });
  }

  //UPDATE task status (isDone)
  Future<void> updateTaskStatus(String docID, bool isDone) {
    return todos.doc(docID).update({
      'isDone': isDone,
      'updateOn': Timestamp.now(),
    });
  }

  //DELETE
  Future<void> deletedTask(String docID) {
    return todos.doc(docID).delete();
  }
}

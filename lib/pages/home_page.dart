import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taskscrud/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();
  //text controller
  final TextEditingController textController = TextEditingController();

  //open a dialog to add a note
  void openTaskBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //button to save
          ElevatedButton(
            onPressed: () {
              //add new task
              if (docID == null) {
                firestoreService.addTask(textController.text);
              }
              //update an existing task
              else {
                firestoreService.updateTask(docID, textController.text);
              }
              //clear the text controller
              textController.clear();
              //close the box
              Navigator.pop(context);
            },
            child: const Text("Adicionar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faxinex")),
      floatingActionButton: FloatingActionButton(
        onPressed: openTaskBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getTaskStream(),
        builder: (context, snapshot) {
          //if we have data, get all the docs
          if (snapshot.hasData) {
            List todosList = snapshot.data!.docs;

            //display as a list
            return ListView.builder(
              itemCount: todosList.length,
              itemBuilder: (context, index) {
                //get each individual doc
                DocumentSnapshot document = todosList[index];
                String docID = document.id;
                //get task from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String taskText = data['task'];
                bool isDone = data['isDone'];

                //display as a list tile
                return ListTile(
                  title: Text(
                    taskText,
                    style: TextStyle(
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Checkbox to mark as done
                      Checkbox(
                        value: isDone,
                        onChanged: (bool? value) {
                          if (value != null) {
                            firestoreService.updateTaskStatus(docID, value);
                          }
                        },
                      ),
                      // Update button
                      IconButton(
                        onPressed: () => openTaskBox(docID: docID),
                        icon: const Icon(Icons.settings),
                      ),
                      // Delete button
                      IconButton(
                        onPressed: () => firestoreService.deletedTask(docID),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Text("Não há tasks cadastradas");
          }
        },
      ),
    );
  }
}

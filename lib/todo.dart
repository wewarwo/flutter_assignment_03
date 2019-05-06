import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  int id;
  String title;
  int done;
  final DocumentReference reference;

  Todo.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['_id'] != null),
        assert(map['title'] != null),
        assert(map['done'] != null),
        id = map['_id'],
        title = map['title'],
        done = map['done'];
  Todo.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "$id <$title:$done>";
}

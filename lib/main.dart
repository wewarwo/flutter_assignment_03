import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_assignment_03/todo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => Home(),
      },
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }
}

String nametitle = "New Subject";

class _HomeState extends State<Home> {
  String nametitle = "Todo";
  int _currentIndex = 0;
  int lenall = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> listbtn = [
      IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          print("Pressed +");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Add(len: lenall),
            ),
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          final QuerySnapshot result =
              await Firestore.instance.collection('todo').getDocuments();
          final List<DocumentSnapshot> documents = result.documents;
          for (var i = 0; i < documents.length; i++) {
            if (documents[i]['done'] == 1) {
              Firestore.instance
                  .collection('todo')
                  .document(documents[i].documentID)
                  .delete();
            }
          }
        },
      ),
    ];
    final List<Widget> _children = [
      Center(
        child: _buildtodoBody(context),
      ),
      Center(
        child: Center(
          child: _buildundoBody(context),
        ),
      )
    ];
    return Scaffold(
      appBar: AppBar(
          title: Text("$nametitle"), actions: <Widget>[listbtn[_currentIndex]]),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            title: new Text('Task'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.done_all),
            title: new Text('Completed'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildtodoBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('todo').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return new Center(
            child: Text("No data found..."),
          );
        int countlen = 0;
        lenall = snapshot.data.documents.length;
        for (var i = 0; i < snapshot.data.documents.length; i++) {
          if (snapshot.data.documents[i]['done'] == 0) {
            countlen += 1;
          }
        }
        if (countlen == 0) {
          return new Center(
            child: Text("No data found..."),
          );
        } else {
          return _buildtodoList(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget _buildundoBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('todo').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return new Center(
            child: Text("No data found..."),
          );
        int countlen = 0;
        lenall = snapshot.data.documents.length;
        for (var i = 0; i < snapshot.data.documents.length; i++) {
          if (snapshot.data.documents[i]['done'] == 1) {
            countlen += 1;
          }
        }
        if (countlen == 0) {
          return new Center(
            child: Text("No data found..."),
          );
        } else {
          return _buildundoList(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget _buildtodoList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildTodoItem(context, data)).toList(),
    );
  }

  Widget _buildundoList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildUndoItem(context, data)).toList(),
    );
  }

  Widget _buildTodoItem(BuildContext context, DocumentSnapshot data) {
    final todo = Todo.fromSnapshot(data);
    if (todo.done == 0) {
      return Padding(
        key: ValueKey(todo.id),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: ListTile(
            title: Text(todo.title),
            trailing: Checkbox(
              value: false,
            ),
            onTap: () => Firestore.instance.runTransaction((transaction) async {
                  final freshSnapshot = await transaction.get(todo.reference);
                  final fresh = Todo.fromSnapshot(freshSnapshot);

                  await transaction
                      .update(todo.reference, {'done': fresh.done = 1});
                }),
          ),
        ),
      );
    } else {
      return Column();
    }
  }

  Widget _buildUndoItem(BuildContext context, DocumentSnapshot data) {
    final todo = Todo.fromSnapshot(data);
    if (todo.done == 1) {
      return Padding(
        key: ValueKey(todo.id),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: ListTile(
            title: Text(todo.title),
            trailing: Checkbox(
              value: true,
            ),
            onTap: () => Firestore.instance.runTransaction((transaction) async {
                  final freshSnapshot = await transaction.get(todo.reference);
                  final fresh = Todo.fromSnapshot(freshSnapshot);

                  await transaction
                      .update(todo.reference, {'done': fresh.done = 0});
                }),
          ),
        ),
      );
    } else {
      return Column();
    }
  }
}

class Add extends StatefulWidget {
  final int len;

  Add({Key key, @required this.len}) : super(key: key);
  AddfromState createState() {
    // TODO: implement createState
    return AddfromState();
  }
}

class AddfromState extends State<Add> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("New Subject"),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Subject",
                  hintText: "Please fill Subject",
                  // icon: Icon(Icons.person),
                ),
                controller: _title,
                keyboardType: TextInputType.text,
                onSaved: (subject) => print(subject),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please fill Subject";
                  }
                },
              ),
              RaisedButton(
                child: Text('Save'),
                onPressed: () {
                  print("save");

                  Firestore.instance
                      .runTransaction((Transaction transaction) async {
                    CollectionReference reference =
                        Firestore.instance.collection('todo');

                    await reference.add({
                      "_id": widget.len + 1,
                      "title": _title.text,
                      "done": 0
                    });
                    _title.clear();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firestore'
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: Demo()));
}

class Demo extends StatefulWidget {

  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  var documents;
    CollectionReference cfo = Firestore.instance.collection('foods');
    var currentDate = DateTime.now();

   fetchData() {
    // CollectionReference cfo = Firestore.instance.collection('foods');
    cfo.snapshots().listen((event) {
      setState(() {
        documents = event.documents[0].data;
        print(documents);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expiry'),
      ),
       body:SafeArea(
        child: StreamBuilder(
            stream: cfo.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                print('snapshot as $snapshot ');
              
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data.documents[index].data;
                      DateTime dt = doc["dateobj"].toDate();
                      var finald = dt.difference(DateTime.now()).inDays;
                      return ListTile(
                        title: Text(doc["title"]),
                        // title:Text('hello'),
                        subtitle: Text(doc["expirty_date"]),
                        trailing: Text("Remaining Days:${finald}"),
                        // subtitle: Text('baka'),
                        onTap: (){
                          snapshot.data.documents[index].reference.delete();
                          
                        },
                      );}

                    );
              }
              print('nosnapshot $snapshot');
              return(
                Text("Empty right now")
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return MyApp();
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime selectedDate = DateTime.now();
  var formattedDate;
  TextEditingController food = new TextEditingController();

  CollectionReference collectionReference =
      Firestore.instance.collection("foods");

  Map<String, dynamic> foods;
  var documents;

  addToDB() {
    collectionReference.add(foods).whenComplete(() => print('added db db  db'));
    final snacky = SnackBar(
      content: Text('added to db'),
      action: SnackBarAction(
        label: "undo",
        onPressed: () {},
      ),
    );
    Scaffold.of(context).showSnackBar(snacky);
  }
  
   

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        var dateParse = DateTime.parse(picked.toString());
        formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";
        print(formattedDate);
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextFormField(
            controller: food,
            decoration: InputDecoration(
              labelText: "name",
            ),
            validator: (str) => !(str.length > 2) ? "not valid" : null,
          ),
          Row(
            children: [
              Text(formattedDate == null
                  ? selectedDate.toString().substring(0, 10)
                  : formattedDate), //todo is it date only??  //set formatdat instead of picked
              RaisedButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: Text('choose datae'),
              )

            ],
            // todo: dropdonw fro selection numbe rof daty sof prior notification
          ),
          RaisedButton(
            onPressed: () {
              //todo save to firestore.
              if (food.text.length > 2 && formattedDate!=null) {
                foods = {
                  "title": food.text,
                  "expirty_date": formattedDate,
                  "dateobj": selectedDate
                };
               
                collectionReference.add(foods).whenComplete(
                    () =>print('added to db success'));
                // addToDB();
                //todo snackbar

              }
              print(food.text.length > 2 ? "food.text" : "food data is empty");
              print(formattedDate);
            },
            child: Text('save'),
          )
        ],
      ),
    );
  }
}

// class Snackb extends StatelessWidget {
//    final snacky = SnackBar(
//                   content: Text('added to db'),
//                   action: SnackBarAction(
//                     label: "undo",
//                     onPressed: () {},
//                   ),
//                 );
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold.of(context).showSnackBar(snacky);
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';


//We  will first initialize our firebase
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of our application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:HomePage() ,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // here  i initialize my TextField contoller
  final TextEditingController IdController = TextEditingController();
  final TextEditingController ManufacturerController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();


  final CollectionReference _drone =
  FirebaseFirestore.instance.collection('drone');// here i create an instance for the table

// bellow is a function for updating our code
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      IdController.text = documentSnapshot['name'];
      weightController.text = documentSnapshot['weight'].toString();
      ManufacturerController.text = documentSnapshot['Manufacturer'];
      controllerDate.text = documentSnapshot['Date Of Acquisition'].toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx){
        return Padding(
          // i used Edge insect only to avoid the soft keyboard from covering text field
          padding: EdgeInsets.only(top: 20,left: 20,right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom+20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:MainAxisAlignment.start,
            children: [
              TextField(
                  controller: IdController,
                  decoration:InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'ID tag'
                  )
              ),
              TextField(
                  controller: ManufacturerController,
                  decoration:InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Manufacturer'
                  )
              ),
              TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration:InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Weight Capacity'
                  )
              ),
              TextField(
                  controller: controllerDate,
                  keyboardType: TextInputType.datetime,
                  decoration:InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Date OF Acquisition'
                  )
              ),
              SizedBox(height: 30,),
              ElevatedButton(
                child: const Text( 'Update'),
                onPressed: () async {
                  final String date = controllerDate.text;
                  final String name = IdController.text;
                  final String Manufacturer = ManufacturerController.text;
                  final double? weight =
                  double.tryParse(weightController.text);
                  if (weight != null) {

                    await _drone
                        .doc(documentSnapshot!.id)
                        .update({"name": name, "Date Of Acquisition": date,"Manufacturer": Manufacturer,"weight": weight });
                    IdController.text = '';
                    controllerDate.text = '';
                    weightController.text = '';
                    ManufacturerController.text = '';
                    Navigator.of(context).pop();
                  }
                },
              )

            ],
          ) ,
        );
        });
  }
// below is a function to delete an item of drone
  Future<void> _delete(String droneId) async {
    await _drone.doc(droneId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }
  // below is a function to create
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx){
          return Padding(
            // i used Edge insect only to avoid the soft keyboard from covering text field
            padding: EdgeInsets.only(top: 20,left: 20,right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom+20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:MainAxisAlignment.start,
              children: [
                TextField(
                    controller: IdController,
                    decoration:InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ID tag'
                    )
                ),
                TextField(
                    controller: ManufacturerController,
                    decoration:InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Manufacturer'
                    )
                ),
                TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration:InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Weight Capacity'
                    )
                ),
                TextField(
                    controller: controllerDate,
                    keyboardType: TextInputType.datetime,
                    decoration:InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Date OF Acquisition'
                    )
                ),
                SizedBox(height: 30,),
                ElevatedButton(
                  child: const Text( 'Create'),
                  onPressed: () async {
                    final String date = controllerDate.text;
                    final String name = IdController.text;
                    final String Manufacturer = ManufacturerController.text;
                    final double? weight =
                    double.tryParse(weightController.text);
                    if (weight != null) {

                      await _drone.add({"name": name, "Date Of Acquisition": date,"Manufacturer": Manufacturer,"weight": weight });
                      IdController.text = '';
                      controllerDate.text = '';
                      weightController.text = '';
                      ManufacturerController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )

              ],
            ) ,
          );
        });
  }

  var Service = Icons.check_box_outlined;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DRONETECH!',style:TextStyle(fontSize: 25,)),
        backgroundColor: Colors.orange,
        toolbarHeight: 100,

      ),
      body: StreamBuilder(
        stream: _drone.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
          // the stream snapshot will have all the data available in our firebase firestore
          if (streamSnapshot.hasData){
            return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,//number of rows
                itemBuilder: (context,index){

                  final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                  // we use the line of code above to access the document object
                  return Card(
                    margin: EdgeInsets.all(13),
                    child: ListTile(
                      title: Text(documentSnapshot['name']),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(documentSnapshot['Manufacturer']),
                          Text(documentSnapshot['weight'].toString()),
                          Text(documentSnapshot['Date Of Acquisition'].toString()),
                        ],
                      ),
                      trailing:SizedBox(
                        width: 120,
                        height: 130,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Serviced',),
                                IconButton(
                                  icon: Icon(Service,
                                    color: Colors.red,
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      Service = Icons.check_box_outlined;
                                    });

                                  },
                                )


                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _delete(documentSnapshot.id)),
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _update(documentSnapshot)),
                              ],
                            ),
                          ],
                        ),
                      ) ,

                    ),
                  );

                });
          }else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      //add new product
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){
          _create();
        },
      ),

    );
  }
}

// we can use docDrone to create document and write data to firebase

class Drone{
  String id;
  final String name;
  final int weight;
  final DateTime date;
  final String Manufacturer;

  Drone({
    this.id='',
    required this.name,
    required this.weight,
    required this.date,
    required this.Manufacturer,

  });
  Map<String, dynamic> tojson() =>{
    'id': id,
    'name': name,
    'weight': weight,
    'Date Of Acquisition': date,
    'Manufacturer' : Manufacturer,
  };
}

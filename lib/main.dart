import 'dart:convert';

import 'package:flutter/material.dart';
import 'crud.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isUpdating = false;
  bool listchange = false;
  bool chosenImage = false;
  var db = Crud();
  var nameController = TextEditingController();
  var priceController = TextEditingController();
  var photoController = TextEditingController();

  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';

  void chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
      chosenImage = true;
    });
    print(file.toString());
  }

  readyImage() {
    return Container(
      width: 150,
      height: 150,
      child: FutureBuilder<File>(
        future: file,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            tmpFile = snapshot.data;
            base64Image = base64Encode(snapshot.data.readAsBytesSync());
            print(base64Image);
            return Flexible(
                child: Image.file(
              snapshot.data,
              fit: BoxFit.fill,
            ));
          } else
            return Text("no image found");
        },
      ),
    );
  }

  void updating() {
    setState(() {
      buildList();
    });
  }

  itemimage(String url) {
    String photourl;
    bool _validURL = false;

    if (url != null) {
      _validURL = Uri.parse(url).isAbsolute;
    }

    if (_validURL) {
      photourl = "https://tab-test.videntium.com/" + url;
    } else {
      photourl =
          "https://www.bengi.nl/wp-content/uploads/2014/10/no-image-available1.png";
    }
    print("${url} ${_validURL} ${photourl}");
    return Container(
      padding: EdgeInsets.all(20),
      width: 150,
      height: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Image.network(photourl),
      ),
    );
  }

  void doneupdate(String id) {
    setState(() {
      isUpdating = true;
    });
    print(id);
    db.updateData(id, nameController.text, priceController.text, "no image");
    //db.updateData("3", "new", "99", "no image");
    setState(() {
      isUpdating = false;
    });
  }

  String id = "";
  buildList() {
    return Flexible(
      child: FutureBuilder(
          future: db.getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.blue,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Color.fromRGBO(152, 191, 236, .1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            itemimage(snapshot.data[index].itemPhoto),
                            Text(
                              snapshot.data[index].itemname,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(snapshot.data[index].itemprice),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                db.deleteData(snapshot.data[index].id);
                                updating();
                              },
                              icon: Icon(Icons.delete),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  nameController.text =
                                      snapshot.data[index].itemname;
                                  priceController.text =
                                      snapshot.data[index].itemprice;
                                  isUpdating = true;
                                });
                                id = snapshot.data[index].id;
                                print(id);
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  managePanel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (nameController.text != null && priceController.text != null) {
                db.SaveData(
                    nameController.text, priceController.text, base64Image);
                nameController.text = "";
                priceController.text = "";
                setState(() {
                  chosenImage = false;
                });
              }
            }),
        if (isUpdating)
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                doneupdate(id);
                nameController.text = "";
                priceController.text = "";
              }),
      ],
    );
  }

  fieldsPanel() {
    return Container(
        padding: EdgeInsets.all(10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
              ),
              Flexible(
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Price',
                  ),
                ),
              ),
              Flexible(
                  child: IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () {
                        chooseImage();
                      }))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            fieldsPanel(),
            if (chosenImage) readyImage(),
            managePanel(),
            buildList(),
          ],
        ),
      ),
    );
  }
}

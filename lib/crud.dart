import 'dart:convert';

import 'package:http/http.dart' as http;
import 'Item.dart';

class Crud {
  var url = "https://tab-test.videntium.com/mobile.php";
  void SaveData(String name, String price, String photo) async {
    var data = {
      "op": "add",
      "item_name": name,
      "item_price": price,
      "item_photo": photo
    };
    var res = await http.post(url, body: data);

    print(res.body.toString());
  }

  Future getData() async {
    var body = {"op": "list"};
    http.Response res = await http.post(url, body: body);

    var data = jsonDecode(res.body);

    var dataModel = new List();

    for (var word in data) {
      String id = word['id'];
      String name = word['item_name'];
      String price = word['item_price'];
      String photo = word['item_photo'];

      dataModel.add(new Item(id, name, price, photo));
    }
    //print('datalenght' + "${data}");
    return dataModel;
  }

  void updateData(String id, String name, String price, String photo) async {
    var data = {
      "op": "upd",
      "id": id,
      "item_name": name,
      "item_price": price,
      "item_photo": photo
    };
    var res = await http.post(url, body: data);
    print(res.body.toString());
  }

  void deleteData(String _id) async {
    var data = {"op": "del", "id": _id};
    var res = await http.post(url, body: data);
    print(res.body);
  }
}

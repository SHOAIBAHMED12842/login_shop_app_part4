import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});
void _setFavValue(bool newValue){
  isFavorite=newValue;
      notifyListeners();
}
  Future<void> toggleFavoriteStatus(String token, String userId) async{
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    //print(userId);
    notifyListeners();
    final url=Uri.parse('https://flutter-update1-53f1b-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token'); //new changes
    
    try{
     final response= await http.put(url,   //put use instead a patch
        // Uri.https('flutter-update1-53f1b-default-rtdb.firebaseio.com',
        //     '/products/$id.json'),
        body: json.encode(
          //'isFavorite': isFavorite, //patch approch
          isFavorite,       //put approch isfavorite not worked
        ));
        if(response.statusCode>=400)
        {
          _setFavValue(oldStatus);
        }
    }catch(error){
      _setFavValue(oldStatus);
    }
    
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       // 'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //       'https://affco.com.pk/Content/PublicLayout/img/AFFCO-new-Logo1.png',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
    // Product(
    //   id: 'p5',
    //   title: 'Afferguson',
    //   description: 'Firm by PWC',
    //   price: 99.99,
    //   imageUrl:
    //       'https://affco.com.pk/Content/PublicLayout/img/AFFCO-new-Logo1.png',
    // ),
  ];

  //var _showFavoritesOnly = false; //provider use
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    //provider use
    // if(_showFavoritesOnly){
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItem {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    //previous implement in product detail screen
    return _items.firstWhere((prod) => prod.id == id);
  }
//.........for provider use
// void showFavoritesOnly() {
//   _showFavoritesOnly=true;
//   notifyListeners();
// }

// void showAll() {
//   _showFavoritesOnly = false;
//   notifyListeners();
// }
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {  //changes in paramentet after rules change in firebase
     final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' :'';
    // var url = Uri.parse(
    //     'https://flutter-update1-53f1b-default-rtdb.firebaseio.com/products.json?auth=$authToken'); //new changes
    var url = Uri.parse(
        'https://flutter-update1-53f1b-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString'); //new changes after error
    try {
      final response = await http.get(url);
//print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      //print(extractedData);
      url = Uri.parse(
          'https://flutter-update1-53f1b-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken'); //new changes
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      //print(favoriteData);
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite: prodData['isFavorite'], //previous approch
            // isFavorite:
            //   favoriteData == null ? false : favoriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl'],
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    //final url=Uri.parse('flutter-update1-53f1b-default-rtdb.firebaseio.com/products.json');//new changes
    final url = Uri.parse(
        'https://flutter-update1-53f1b-default-rtdb.firebaseio.com/products.json?auth=$authToken'); //new changes
    //future used instead of void
    // _items.add(value);
    //const url ='https://flutter-update1-53f1b-default-rtdb.firebaseio.com/products.json';
    //return http.post(Uri.https('flutter-update1-53f1b-default-rtdb.firebaseio.com', '/products.json'), body: json.encode({  //not in the course video
    try {
      final response = await http.post(
        url,
        // Uri.https('flutter-update1-53f1b-default-rtdb.firebaseio.com',
        //     '/products.json'),
        body: json.encode({
          //not in the course video/with using async keyword
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId':userId,//new addition after error
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        //id: DateTime.now().toString(),//without jason
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      //_items.insert(0,newProduct);  // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    //.then((response) {
    //print(json.decode(response.body));
    // final newProduct = Product(  //move try block
    //   title: product.title,
    //   description: product.description,
    //   price: product.price,
    //   imageUrl: product.imageUrl,
    //   //id: DateTime.now().toString(),//without jason
    //   id: json.decode(response.body)['name'],
    // );
    // _items.add(newProduct);
    // //_items.insert(0,newProduct);  // at the start of the list
    // notifyListeners();
    //})
    // .catchError((error) {
    //   print(error);
    //   throw error;
    // });
    //return Future.value();
    // final newProduct = Product(
    //   title: product.title,
    //   description: product.description,
    //   price: product.price,
    //   imageUrl: product.imageUrl,
    //   id: DateTime.now().toString(),
    // );
    // _items.add(newProduct);
    // //_items.insert(0,newProduct);  // at the start of the list
    // notifyListeners();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-update1-53f1b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken'); //new changes
      await http.patch(url,
          // Uri.https('flutter-update1-53f1b-default-rtdb.firebaseio.com',
          //     '/products/$id.json'),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            //'isFavorite': newProduct.isFavorite,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('....');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-update1-53f1b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken'); //new changes
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url
        // Uri.https('flutter-update1-53f1b-default-rtdb.firebaseio.com',
        //   '/products/$id.json')
        );
    //.then((response) {
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();

      throw HttpException('Could not delete product');
    }
    existingProduct = null;
    //})
    // .catchError((_) {
    //_items.insert(existingProductIndex, existingProduct);
    //});
    //_items.removeWhere((prod) => prod.id == id);
    //notifyListeners();
    // _items.removeAt(existingProductIndex);
    // notifyListeners();
  }
}

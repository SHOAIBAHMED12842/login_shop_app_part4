import 'package:flutter/material.dart';
//import './screens/splash_screen.dart';
import './providers/auth.dart';
import './providers/cart.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import './providers/products.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        //ChangeNotifierProvider.value(  //without passing constructor
        //for using provider .value is used to replace create/builder
        //builder: (ctx) => Products(),  //for provider version <=3
        //create: (_) => Products(),   //for provider version >=4
        //value: Products(), //same as passing constructor
        //),
        ChangeNotifierProxyProvider<Auth, Products>(
          //provider 3 version use bulder instead update/if update not work then use create
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        // ChangeNotifierProvider.value(  //previous implemention with no auth class
        //   value: Orders(),
        // ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          //provider 3 version use bulder instead update/if update not work then use create
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      // ChangeNotifierProvider.value(         //for using provider .value is used to replace create/builder
      //   //builder: (ctx) => Products(),  //for provider version <=3
      //   //create: (_) => Products(),   //for provider version >=4
      //   value: Products(),
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? ProductOverviewScreen() : AuthScreen(),
              // : FutureBuilder(
              //     future: auth.tryAutoLogin(),   //for autologin
              //     builder: (ctx, authResultSnapshot) =>
              //         authResultSnapshot.connectionState ==
              //                 ConnectionState.waiting
              //             ? SplashScreen()
              //             : AuthScreen(),
              //   ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
      ),
      body: Center(
        child: Text('Let\'s build a shop!'),
      ),
    );
  }
}

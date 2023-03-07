import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {  //other approch convert stateful
  static const routeName = '/orders';

  //@override
 // _OrdersScreenState createState() => _OrdersScreenState();
//}

//class _OrdersScreenState extends State<OrdersScreen> { 
  //Future _orderFuture;
  //Future _obtaonOrdersFuture(){
  //return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  //}
  //var _isLoading = false;
//  @override                             //new approch with future builder
//   void initState() {// approrch work if stateful
    // _orderFuture = _obtaonOrdersFuture();
    // super.initState();
  //}

//  @override                                  //previous approach
//   void initState() {// approrch work if stateful
    // Future.delayed(Duration.zero).then((_) async {
    //   setState(() {
    //     _isLoading = true;
    //   });
    //   await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
    // super.initState();
  //}

    @override
  Widget build(BuildContext context) {
    //print('building orders');
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(), //apply also otherwise init state/_orderFuture insted provider is used
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              // ...
              // Do error handling stuff
              return Center(
                child: Text('An error occurred!'),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                    ),
              );
            }
          }
        },
      ),
    );
  }
}

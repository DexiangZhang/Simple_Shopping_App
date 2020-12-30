import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {

  static const routeName = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFutureObject;

  Future _obtainOrderFuture() {
    return  Provider.of<Orders>(context,listen: false).getOrders();
  }

  @override
  void initState() {
    _ordersFutureObject = _obtainOrderFuture();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFutureObject,
        builder: (ctx, data) {
          // if it is currently waiting for the response (which currently fetch data)
          if(data.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else {
            // where there is an error occured
            if(data.error !=null) {
              print(data.error);
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("An unexpected error has occurred."),
                    SizedBox(height: 10,),
                    Text("Please try again later!"),
                  ],
                ),
              );
            }
            else {
              // no error and the response is complete
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, index) => OrderItem(orderData.orders[index])
                ),
              );
            }
          }
        },
      )
    );
  }
}

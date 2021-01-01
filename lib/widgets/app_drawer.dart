import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_route_screen.dart';
import '../providers/auth.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {

  final TextStyle overallText  =  TextStyle(fontSize: 20);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, 1],
            ),
          ),
        ),
        Column(
          children: <Widget>[
            AppBar(
              title: Text("Menu Options"),
              // make the back button icon disappear
              automaticallyImplyLeading: false,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.shop),
              title: Text(
                "Shop",
                style: overallText,
              ),
              onTap: () {
                Navigator.of(context).pushReplacementNamed("/");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text(
                "Orders",
                style: overallText,
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  CustomRoute(
                    builder: (ctx) => OrdersScreen(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text(
                "Manage Products",
                style: overallText,
              ),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(UserProductsScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(
                "Logout",
                style: overallText,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<Auth>(context, listen: false).logout();
              },
            ),
          ],
        ),
      ]),
    );
  }
}

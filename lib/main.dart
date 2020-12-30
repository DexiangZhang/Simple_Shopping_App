import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/auth.dart';
import './providers/orders.dart';
import './helpers/custom_route_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        // <1st,2nd>  1st - depends providers, 2nd - the object you want
        ChangeNotifierProxyProvider<Auth, Products>(
          create: null,
          update: (ctx, authObject, previousOldProduct) => Products(
              authObject.token,
              authObject.userId,
              previousOldProduct == null ? [] : previousOldProduct.items
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: null,
          update: (ctx, authObject, previousOldOrder) => Orders(
              authObject.token,
              authObject.userId,
              previousOldOrder == null ? [] : previousOldOrder.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme( builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            })
          ),

          // check if you successfullu login or not and show diff screen based on it
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
              /*try to auto login, if still waiting for response show a loading screen
              else show the login screen
               */
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResult) =>
                    authResult.connectionState ==
                        ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      )
    );
  }
}
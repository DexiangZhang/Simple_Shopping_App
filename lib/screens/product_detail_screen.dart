import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {

    final productId = ModalRoute.of(context).settings.arguments as String;

    // Provider.of<Products>(context) gives you the object of "products"
    // adding "listen: false" means you dont want this widget to rebuild when data changed except first time build
    final loadedProduct = Provider.of<Products>(context,listen: false).findById(productId);

    return Scaffold(

      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            iconTheme: IconThemeData(
                color: Colors.purpleAccent.shade100,
            ),
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                loadedProduct.title,
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 20,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 280,bottom: 10),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        SliverList(
          delegate: SliverChildListDelegate([
            SizedBox(height: 10),
            Text(
              "\$${loadedProduct.price}",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                "Description:     " + loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true, // it will go to new line if no more space
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            SizedBox(
              height: 800,
            )
          ]),
        ),
      ],
     )
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    // it shows the single item which in the "create:" where you get the argument from
    final singleProduct = Provider.of<Product>(context,listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authToken = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: singleProduct.id,
            );
          },
          child: Hero(
            tag: singleProduct.id,
            child: FadeInImage(
              placeholder: AssetImage("assets/images/product-placeholder.png"),
              image: NetworkImage(singleProduct.imageUrl),
              fit: BoxFit.cover,
            ),
          )
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: Icon(singleProduct.isFavorite ? Icons.favorite: Icons.favorite_border),
              onPressed: () {
                singleProduct.toggleFavoritesStatus(authToken.token, authToken.userId);
              },
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Text(
            singleProduct.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(
                  singleProduct.id, singleProduct.price, singleProduct.title
              );
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text("Added item to cart"),
                    duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () {
                      cart.removeSingleItem(singleProduct.id);
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}

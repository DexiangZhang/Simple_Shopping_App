import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {

  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded ? min(widget.order.products.length * 20.0 + 120, 200) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
              ListTile(
                title: Text(
                  "\$${widget.order.amount}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  DateFormat("dd/MM/yyyy  hh:mm").format(widget.order.dateTime),
                ),
                trailing: IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
            ),
              AnimatedContainer(
                color: Colors.tealAccent.shade100,
                duration: Duration(milliseconds: 300),
                // it will take whatever is smaller value inside "min( , )", left side require "double" value
                height: _expanded ? min(widget.order.products.length * 20.0 + 20, 100) : 0,
                padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                ),
                child: ListView(
                  children: widget.order.products
                      .map(
                          (produ) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                produ.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${produ.quantity} x \$${produ.price}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          )).toList(),
                ),
              )
          ],
        ),
      ),
    );
  }
}

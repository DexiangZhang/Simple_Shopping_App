import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {

  static const routeName = "/edit_product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _isInit = true;
  var _isLoading = false;

  var _editedProduct = Product(
      id: null,
      title: "",
      price: 0,
      description: "",
      imageUrl: "",
  );

  var _initValues =  {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {

    if(_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      if(productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          "imageUrl": "",
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // require for own FocusNode(), to avoid memory leak when this object is deleted
  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl () {
    if(!_imageUrlFocusNode.hasFocus) {
      /* if user click other input field but the image field has no following pattern
      then don't update the screen (since it is wrong)
       */
      if((!_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith(".png") &&
              !_imageUrlController.text.endsWith(".jpg") &&
              !_imageUrlController.text.endsWith(".jpeg"))) {
          return;
      }
      setState(() {});
    }
  }

  Future<void> _submitForm() async {
    final isValid = _form.currentState.validate();
    // if at least one input is wrong, then return and not saved the form when click button
    if(!isValid) {
      return;
    }
    // this method save form,  which trigger "onsave:" method in "Form()" widget property
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if(_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.id,_editedProduct);

    }
    else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {

        /* we using "await" here b/c we want to wait for this result (user clikc button)
         before we continue to "finally{}" block of code
         */
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("An error occurred!"),
              content: Text("Something went wrong" ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Okay"),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editing Items"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              color: Colors.brown.shade100,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues["title"],
                      // provide the hint so user know what this input field for
                      decoration: InputDecoration(
                        labelText: "Title",
                      ),

                      /* when user press the place where "done" and "submit" suppose to
                      on soft keyboard, will move to  next input field instead of submit data
                       */
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: value,
                          price: _editedProduct.price,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      // value is the string variable that user input on this field
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please provide a value";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    TextFormField(
                      initialValue: _initValues["price"],
                      decoration: InputDecoration(
                        labelText: "Price",
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: double.parse(value),
                          // convert string to double type
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a price";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid number";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter a number greater than 0";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    TextFormField(
                      initialValue: _initValues["description"],
                      decoration: InputDecoration(
                        labelText: "Description",
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a description";
                        }
                        if (value.length < 10) {
                          return "Should be at least 10 characters";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Preview Image",textAlign: TextAlign.center,)
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Image URL",
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _submitForm();
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter an image URL";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "Please enter a valid URL";
                              }
                              if (!value.endsWith(".png") &&
                                  !value.endsWith(".jpg") &&
                                  !value.endsWith(".jpeg")) {
                                return "Please enter a valid image URL";
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
          ),
    );
  }
}

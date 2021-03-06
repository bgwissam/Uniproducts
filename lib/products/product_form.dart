import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart' as cloudFireStore;
import 'package:firebase/firebase.dart' as webFireStorage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_whisperer/image_whisperer.dart' as whisperer;
import 'package:path/path.dart' as Path;
import 'package:web_product_unitrade/products/product_validators.dart';
import 'package:web_product_unitrade/services/fire_storage.dart';
import 'package:web_product_unitrade/models/products.dart';
import 'package:web_product_unitrade/services/database.dart';
import 'package:web_product_unitrade/shared/constants.dart';
import 'package:web_product_unitrade/shared/loading.dart';
import 'package:web_product_unitrade/shared/string.dart';
import 'package:web_product_unitrade/shared/dropdownLists.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/painting.dart' as painting;

class ProductForm extends StatefulWidget {
  final PaintMaterial paintProducts;
  final WoodProduct woodProduct;
  final Lights lightProduct;
  final Accessories accessoriesProduct;
  final Brands brands;
  final List<dynamic> roles;

  ProductForm({
    this.paintProducts,
    this.brands,
    this.woodProduct,
    this.lightProduct,
    this.accessoriesProduct,
    this.roles,
    // this.isAdmin,
    // this.isPriceAdmin,
  });
  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  ProductValidators productValidators = new ProductValidators();
  String itemCode;
  String productName;
  String productType;
  String productCategory;
  String productBrand;
  double productPack;
  double productPrice;
  double productCost;
  String productPackUnit;
  String productDescription;
  List<String> productTags;
  String paintImageUrl;
  double width;
  double length;
  double thickness;
  String dimensions;
  String watt;
  String voltage;
  double angle;
  String closingType;
  String productColor;
  String productImageUrl;
  List<dynamic> imageUrls;
  List<String> _brandList = [];
  String error = 'No Error detected';
  bool loading = false;
  ValueNotifier<bool> itemAdded = ValueNotifier<bool>(false);
  bool tagsListChanged = false;
  //check if current image is edited
  bool editCurrentImage = false;
  StringBuffer tags;
  List<dynamic> tagsList = [];
  //Image file
  List<painting.NetworkImage> image = []..length = 5;
  painting.NetworkImage tempImage;
  Uint8List imageUpload;
  //PDF File variables
  File pdfResult;
  File pdfFile;
  bool loadingPath;
  String pdfFileName;
  //Images file variables
  List<File> images;
  String _pdfUrl;
  String _pdfFileName;
  // bool _multiPick = false;
  //Firebase store variables
  cloudFireStore.FirebaseFirestore fb =
      cloudFireStore.FirebaseFirestore.instance;
  List<dynamic> imageListUrls = [];
  //holds the type of the product
  List<String> type;
  //holds the category of each type
  List<String> category;
  //hold the paint Images list
  List<List<String>> paintImages;
  //container width
  num containerWidth = 500.0;
  num containerheight = 500.0;
  num dropdownListWidth = 250.0;
  String placeHolderImage = 'images/placeholder.png';
  Future getLoadedImages;
  String errorText;
  String zeroValue = '0';

  //Image upload for Web based software
  _startFilePicker() async {
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();
    uploadInput.onChange.listen((event) {
      //Read file content as dataUrl
      final files = uploadInput.files;
      if (files.length == 1) {
        pdfFile = files[0];
        FileReader reader = FileReader();

        reader.onLoadEnd.listen((event) {
          setState(() {
            imageUpload = reader.result;
          });
        });
        reader.onError.listen((event) {
          setState(() {
            errorText = 'The following error occured: $event';
          });
        });
        reader.readAsArrayBuffer(pdfFile);
        _pdfFileName = pdfFile.name;
      }
    });
  }

  //get Images for local strage
  Future<painting.NetworkImage> _startImagesPicker(int index) async {
    print('The index of the clicked section: $index');
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();
    uploadInput.onChange.listen((event) {
      //Read file content as dataUrl
      final files = uploadInput.files;
      if (files.length == 1) {
        images[index] = files[0];
        FileReader reader = FileReader();
        reader.onLoadEnd.listen((event) {
          setState(() {
            imageUpload = reader.result;
          });
        });
        reader.onError.listen((event) {
          setState(() {
            errorText = 'The following error occured: $event';
          });
        });
        reader.readAsArrayBuffer(images[index]);

        whisperer.BlobImage blobImage =
            new whisperer.BlobImage(images[index], name: images[index].name);

        setState(() {
          tempImage = painting.NetworkImage(blobImage.url);
          if (index < imageListUrls.length) {
            imageListUrls.removeAt(index);
            image[index] = tempImage;
          } else {
            print('New image was added: $tempImage at index $index');

            image[index] = tempImage;
          }
        });
      }
    });
    return tempImage;
  }

  //Image upload widget
  Widget showSelectedImage(int index) {
    print('The new images are: $image of index: $index');
    if (image[index] != null)
      return Container(
          child: Image.network(
        image[index].url,
        height: 200.0,
        width: 200.0,
      ));
    else
      return Container(
        child: Text(CANNOT_READ_IMAGE, textAlign: TextAlign.center),
        height: 200.0,
        width: 200.0,
      );
  }

  //will edit current images and upload new ones
  Future<painting.NetworkImage> _updateCurrentImage(int index) async {
    print('The updated image index: $index');
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();
    uploadInput.onChange.listen((event) {
      //Read file content as dataUrl
      final files = uploadInput.files;
      if (files.length == 1) {
        images[index] = files[0];
        FileReader reader = FileReader();
        reader.onLoadEnd.listen((event) {
          setState(() {
            imageUpload = reader.result;
          });
        });
        reader.onError.listen((event) {
          setState(() {
            errorText = 'The following error occured: $event';
          });
        });
        reader.readAsArrayBuffer(images[index]);

        whisperer.BlobImage blobImage =
            new whisperer.BlobImage(images[index], name: images[index].name);

        setState(() {
          tempImage = painting.NetworkImage(blobImage.url);
          //editCurrentImage = true;
          imageListUrls[index] = tempImage;
        });
      }
    });

    return tempImage;
  }

  //Will upload a PDF file to the firebase storage
  Future getPdfFiles() async {
    var result;
    try {
      result =
          await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'pdf');
    } on PlatformException catch (e) {
      print('Unsupported operation $e');
    } catch (e) {
      print('Error selecting file: $e');
    }
    if (!mounted) return;
    setState(() {
      if (result != null) {
        pdfResult = result;
      }
    });
  }

  @override
  void initState() {
    _getBrands();
    if (widget.paintProducts != null) {
      itemCode = widget.paintProducts.itemCode;
      productName = widget.paintProducts.productName;
      productBrand = widget.paintProducts.productBrand;
      productType = widget.paintProducts.productType;
      productCategory = widget.paintProducts.productCategory;
      productColor = widget.paintProducts.color;
      productPack = widget.paintProducts.productPack;
      productPackUnit = widget.paintProducts.productPackUnit;
      productPrice = widget.paintProducts.productPrice;
      productCost = widget.paintProducts.productCost;
      //productTags = widget.paintProducts.productTags;
      _pdfUrl = widget.paintProducts.pdfUrl ?? null;
      productDescription = widget.paintProducts.description;
      paintImageUrl = widget.paintProducts.imageLocalUrl;
    } else if (widget.woodProduct != null) {
      itemCode = widget.woodProduct.itemCode;
      productName = widget.woodProduct.productName;
      productBrand = widget.woodProduct.productBrand;
      productType = widget.woodProduct.productType;
      productCategory = widget.woodProduct.productCategory;
      length = widget.woodProduct.length;
      width = widget.woodProduct.width;
      thickness = widget.woodProduct.thickness;
      productDescription = widget.woodProduct.description;
      productColor = widget.woodProduct.color;
      productPrice = widget.woodProduct.productPrice ?? null;
      productCost = widget.woodProduct.productCost ?? null;
      //productTags = widget.woodProduct.productTags ?? null;
      widget.woodProduct.imageListUrls.isEmpty
          ? imageListUrls = []
          : imageListUrls =
              new List<dynamic>.from(widget.woodProduct.imageListUrls);
    } else if (widget.lightProduct != null) {
      productName = widget.lightProduct.productName;
      productBrand = widget.lightProduct.productBrand;
      productType = widget.lightProduct.productType;
      productCategory = widget.lightProduct.productCategory;
      dimensions = widget.lightProduct.dimensions;
      watt = widget.lightProduct.watt;
      voltage = widget.lightProduct.voltage;
      productColor = widget.lightProduct.color;
      widget.lightProduct.imageListUrls == null
          ? imageListUrls = []
          : imageListUrls =
              new List<dynamic>.from(widget.lightProduct.imageListUrls);
    } else if (widget.accessoriesProduct != null) {
      itemCode = widget.accessoriesProduct.itemCode;
      productName = widget.accessoriesProduct.productName;
      productBrand = widget.accessoriesProduct.productBrand;
      productType = widget.accessoriesProduct.productType;
      productCategory = widget.accessoriesProduct.productCategory;
      length = widget.accessoriesProduct.length;
      angle = widget.accessoriesProduct.angle;
      closingType = widget.accessoriesProduct.closingType;
      productPrice = widget.accessoriesProduct.productPrice;
      productCost = widget.accessoriesProduct.productCost;
      productTags = widget.accessoriesProduct.productTags;
      productColor = widget.accessoriesProduct.color;
      productDescription = widget.accessoriesProduct.description;
      widget.accessoriesProduct.imageListUrls == null
          ? imageListUrls = []
          : imageListUrls =
              new List<dynamic>.from(widget.accessoriesProduct.imageListUrls);
    }
    category = CategoryList.categoryList();
    paintImages = PaintImagesList.paintImagesList();
    type = Type.typeList();
    images = []..length = 5 - imageListUrls.length;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  //drop down list menu for division
  List<DropdownMenuItem<Division>> buildDivisionMenu(List divisionList) {
    List<DropdownMenuItem<Division>> items = [];
    for (Division division in divisionList) {
      items.add(DropdownMenuItem(
          value: division,
          child: new Container(
            child: Text(division.divisionName),
            width: dropdownListWidth,
          )));
    }
    return items;
  }

  //get the current brands
  Future _getBrands() async {
    DatabaseService databaseService = DatabaseService();
    await databaseService.brandCollection
        .get()
        .then((cloudFireStore.QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) {
        _brandList.add(element.data()['brandName']);
      });
    });
    // _buildMenuList = buildBrandsMenu(_brandList);
    setState(() {});
    return _brandList;
  }

  //Convert tags to a dynamic list
  List<dynamic> _convertTagsToList({List<dynamic> tagsList}) {
    tagsList = [];
    if (tags != null) {
      var splitTags = tags.toString().split(',');
      splitTags.forEach((element) {
        if (element != ' ' && element != ',') tagsList.add(element.trim());
      });
    }
    return tagsList;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text(ADD_PRODUCT),
              backgroundColor: Colors.amberAccent,
              elevation: 1.0,
            ),
            body: _userAuthorizationLevel());
  }

  //Widget to check user authorization
  Widget _userAuthorizationLevel() {
    //specify the page width in accordance to the screen
    double pageWidth = MediaQuery.of(context).size.width;
    if (widget.roles.contains('isAdmin')) {
      return SingleChildScrollView(
        child: new Form(
          key: _formKey,
          child:
              Container(width: pageWidth / 1.5, child: _buildProductFormAdmin()),
        ),
      );
    } else if (widget.roles.contains('isPriceAdmin')) {
      return SingleChildScrollView(
        child: new Form(
          key: _formKey,
          child: _buildProductFormPriceAdmin(),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: new Container(
          child: _buildProductContainerUser(),
        ),
      );
    }
  }

  //Just for testing
  Widget _buildNoImageAvailable(int index) {
    print('Current Image: ${imageListUrls[index]} at index: $index');
    return Image.network(
      imageListUrls[index],
      fit: BoxFit.contain,
      width: 200.0,
      height: 200.0,
    );
  }

  //Build the product form for admin users to allow editing
  Widget _buildProductFormAdmin() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          //Select product division unit
          Container(
            alignment: Alignment.bottomLeft,
            child: new DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: productType,
              hint: Text(SELECT_PRODUCT_TYPE),
              onChanged: (String val) {
                setState(() {
                  productType = val;
                });
              },
              selectedItemBuilder: (BuildContext context) {
                return type.map<Widget>((String item) {
                  return Text(item, style: textStyle1);
                }).toList();
              },
              items: type.map((String item) {
                return DropdownMenuItem<String>(child: Text(item), value: item);
              }).toList(),
            ),
          ),
          SizedBox(
            height: 25.0,
          ),
          //select different column depending on the product type
          Container(
            child: selectType(),
          ),
          SizedBox(
            height: 15.0,
          ),
          //Select the category of the product
          Container(
            alignment: Alignment.bottomLeft,
            child: new DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: productCategory,
              hint: Text(SELECT_PRODUCT_CATEGORY),
              onChanged: (String val) {
                setState(() {
                  productCategory = val;
                });
              },
              selectedItemBuilder: (BuildContext context) {
                return category.map<Widget>((String item) {
                  return Text(item, style: textStyle1);
                }).toList();
              },
              items: category.map((String item) {
                return DropdownMenuItem<String>(child: Text(item), value: item);
              }).toList(),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          //Upload product images
          Container(
            padding: EdgeInsets.all(8.0),
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return index < imageListUrls.length
                    ? Container(
                        margin: const EdgeInsets.all(4.0),
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(border: Border.all()),
                        child: InkWell(
                          child: _buildNoImageAvailable(index),
                          onTap: () async {
                            _startImagesPicker(index);
                          },
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(4.0),
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(border: Border.all()),
                        child: InkWell(
                          child: image[index] == null
                              ? new Icon(Icons.add,
                                  size: 72, color: Colors.grey)
                              : showSelectedImage(index),
                          onTap: () async {
                            _startImagesPicker(index);
                          },
                        ),
                      );
              },
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          //Upload file PDF (Data sheet)
          Container(
            margin: EdgeInsets.all(15.0),
            height: 50.0,
            decoration: BoxDecoration(border: Border.all()),
            child: InkWell(
              child: Center(child: Text('Upload PDF')),
              onTap: () async => _startFilePicker(),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          //Uploaded PDF file
          pdfFile != null
              ? Container(
                  height: 50.0,
                  child: Text(
                    pdfFile.name.toString(),
                    style: textStyle1,
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(),
          //Will validate the current field and save the product edited or added to the database
          RaisedButton(
            color: Colors.amber[400],
            child: Text(SAVE_PRODUCT, style: buttonStyle),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                var result;
                DatabaseService databaseService = DatabaseService();
                setState(() {
                  loading = true;
                });
                if (widget.paintProducts == null &&
                    widget.woodProduct == null &&
                    widget.lightProduct == null &&
                    widget.accessoriesProduct == null) {
                  //convert the tags string buffer to list
                  if (tagsListChanged) tagsList = _convertTagsToList();
                  //upload the image
                  await uploadFileImage(images, pdfFile);
                  print('The current pdfUrl: $_pdfUrl');

                  //add the paint product to the database
                  if (productType == TAB_PAINT_TEXT)
                    result = await databaseService.addPaintProduct(
                        itemCode: itemCode,
                        productName: productName,
                        productBrand: productBrand,
                        productType: productType,
                        productPack: productPack,
                        productPrice: productPrice,
                        productCost: productCost,
                        productPackUnit: productPackUnit,
                        productCategory: productCategory,
                        color: productColor,
                        imageListUrls: imageListUrls,
                        imageLocalUrl: paintImageUrl,
                        pdfUrl: _pdfUrl);
                  //variable for adding a wood product
                  else if (productType == TAB_WOOD_TEXT)
                    result = await databaseService.addWoodProduct(
                        itemCode: itemCode,
                        productName: productName,
                        productBrand: productBrand,
                        productType: productType,
                        length: length,
                        width: width,
                        thickness: thickness,
                        productCategory: productCategory,
                        productPrice: productPrice,
                        productCost: productCost,
                        color: productColor,
                        imageListUrls: imageListUrls,
                        pdfUrl: _pdfUrl);
                  //variable for adding a solid surface product
                  else if (productType == TAB_SS_TEXT)
                    result = await databaseService.addSolidSurfaceProduct(
                        itemCode: itemCode,
                        productName: productName,
                        productBrand: productBrand,
                        productType: productType,
                        length: length,
                        width: width,
                        thickness: thickness,
                        productCategory: productCategory,
                        productPrice: productPrice,
                        productCost: productCost,
                        color: productColor,
                        imageListUrls: imageListUrls);
                  //variable for adding a lights products
                  else if (productType == TAB_LIGHT_TEXT)
                    result = await databaseService.addLightsProduct(
                        productName: productName,
                        productBrand: productBrand,
                        productType: productType,
                        dimensions: dimensions,
                        watt: watt,
                        voltage: voltage,
                        productCategory: productCategory,
                        color: productColor,
                        imageListUrls: imageListUrls);
                  //variable for adding accessories products
                  else if (productType == TAB_ACCESSORIES_TEXT)
                    result = await databaseService.addAccessoriesProduct(
                        itemCode: itemCode,
                        productName: productName,
                        productBrand: productBrand,
                        productType: productType,
                        length: length,
                        angle: angle,
                        closingType: closingType,
                        productCategory: productCategory,
                        color: productColor,
                        imageListUrls: imageListUrls);
                  print('Adding a new product result: $result');
                  if (result == null) {
                    setState(() {
                      loading = false;
                      error = 'Failed to add this product';
                    });
                  }
                } else {
                  //check if the tag list was edited
                  if (tagsListChanged) tagsList = _convertTagsToList();
                  //check if the image picker was selected
                  await uploadFileImage(images, pdfFile);
                  print(productType);
                  if (productType == TAB_PAINT_TEXT) {
                    result = await DatabaseService().updatePaintProduct(
                        uid: widget.paintProducts.uid,
                        itemCode: itemCode,
                        productName: productName,
                        productBrand: productBrand,
                        productType: productType,
                        productPack: productPack,
                        productPrice: productPrice,
                        productCost: productCost,
                        productPackUnit: productPackUnit,
                        productCategory: productCategory,
                        color: productColor,
                        imageListUrls: imageListUrls,
                        imageLocalUrl: paintImageUrl,
                        pdfUrl: _pdfUrl);
                  } else if (productType == TAB_WOOD_TEXT)
                    result = await DatabaseService().updateWoodProduct(
                        uid: widget.woodProduct.uid,
                        itemCode: itemCode,
                        productName: productName,
                        productBrand: productBrand,
                        productType: productType,
                        length: length,
                        width: width,
                        thickness: thickness,
                        productCategory: productCategory,
                        productPrice: productPrice,
                        productCost: productCost,
                        productTags: productTags,
                        color: productColor,
                        imageListUrls: imageListUrls,
                        pdfUrl: _pdfUrl);
                  else if (productType == TAB_SS_TEXT)
                    result = await DatabaseService().updateSolidSurfaceProduct(
                        uid: widget.woodProduct.uid,
                        itemCode: itemCode,
                        productName: productName,
                        productBrand: productBrand,
                        productType: productType,
                        length: length,
                        width: width,
                        thickness: thickness,
                        productCategory: productCategory,
                        productPrice: productPrice,
                        productCost: productCost,
                        productTags: productTags,
                        color: productColor,
                        imageListUrls: imageListUrls,
                        pdfUrl: _pdfUrl);
                  else if (productType == TAB_LIGHT_TEXT) {
                    result = await DatabaseService().updateLightsProduct(
                        uid: widget.lightProduct.uid,
                        productName: productName,
                        productBrand: productBrand,
                        productType: productType,
                        dimensions: dimensions,
                        watt: watt,
                        voltage: voltage,
                        productCategory: productCategory,
                        color: productColor,
                        imageListUrls: imageListUrls);
                  } else if (productType == TAB_ACCESSORIES_TEXT)
                    result = await databaseService.updateAccessoriesProduct(
                        uid: widget.paintProducts.uid,
                        itemCode: itemCode,
                        productName: productName,
                        productBrand: productBrand,
                        productType: productType,
                        length: length,
                        angle: angle,
                        closingType: closingType,
                        productCategory: productCategory,
                        productPrice: productPrice,
                        productCost: productCost,
                        productTags: productTags,
                        color: productColor,
                        imageListUrls: imageListUrls);

                  if (result == null) {
                    setState(() {
                      loading = false;
                      error = 'Failed to update this product';
                    });
                  }
                }
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
    );
  }

  //Build the product form for price admin users who are capable of changing the price onlu
  Widget _buildProductFormPriceAdmin() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          //select different column depending on the product type
          Container(
            child: selectType(),
          ),
          SizedBox(
            height: 15.0,
          ),
          //Set new price
          Container(
            child: TextFormField(
              initialValue: widget.paintProducts.productPrice.toString(),
              decoration: textInputDecoration.copyWith(labelText: 'New Price'),
              keyboardType: TextInputType.number,
              validator: (val) =>
                  val.isEmpty ? 'Price should not be empty' : null,
              onChanged: (val) {
                productPrice = double.parse(val);
              },
            ),
          ),
          //Will validate the current field and save the product edited or added to the database
          RaisedButton(
            color: Colors.amber[400],
            child: Text(UPDATE_PRICE, style: buttonStyle),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                var result;
                DatabaseService databaseService = DatabaseService();
                setState(() {
                  loading = true;
                });
                if (widget.paintProducts != null) {
                  if (productType == TAB_PAINT_TEXT) {
                    result = await databaseService.updatePaintPriceField(
                      uid: widget.paintProducts.uid,
                      productPrice: productPrice,
                    );
                  }

                  if (result == null) {
                    setState(() {
                      loading = false;
                      error = 'Failed to update this product';
                    });
                  }
                }
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
    );
  }

  //Build the product Container details
  Widget _buildProductContainerUser() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          selectType(),
        ],
      ),
    );
  }

  //if no image was found an empty container will be returned
  Widget noImageContainer() {
    return Container(
      height: 260.0,
      width: 260.0,
      child: Image.asset('assets/images/no_image.png'),
    );
  }

  //upload the image file to firebase storage
  Future uploadFileImage(List<File> images, File pdfFile) async {
    webFireStorage.StorageReference storageReference;
    String folderNameImages;
    String folderNameTDS;
    //select the image folder in Firebase storage depending on product type
    switch (productType) {
      case TAB_PAINT_TEXT:
        folderNameImages = 'paint_image';
        folderNameTDS = 'paint_TDS';
        break;
      case TAB_WOOD_TEXT:
        folderNameImages = 'wood_image';
        folderNameTDS = 'wood_TDS';
        break;
      case TAB_SS_TEXT:
        folderNameImages = 'solid_image';
        folderNameTDS = 'solid_TDS';
        break;
      case TAB_LIGHT_TEXT:
        folderNameImages = 'lights_image';
        break;
      case TAB_ACCESSORIES_TEXT:
        folderNameImages = 'accessories_image';
        folderNameTDS = 'accessories_TDS';
        break;
      default:
        folderNameImages = 'unknown_image';
        folderNameTDS = 'unknown_TDS';
        break;
    }
    //check if there's a current image that was edited and upload it to the storage and get the url
    if (editCurrentImage) {
      for (var index = 0; index < imageListUrls.length; index++) {
        if (imageListUrls[index] is File) {
          storageReference = webFireStorage.storage().ref().child(
              '$folderNameImages/${Path.basename(imageListUrls[index].url)}');

          webFireStorage.UploadTaskSnapshot uploadTaskSnapshot =
              await storageReference.put(imageListUrls[index]).future;

          Uri imageUrl = await uploadTaskSnapshot.ref.getDownloadURL();

          imageListUrls.removeAt(index);
          imageListUrls.add(imageUrl.toString());
        }
      }
      editCurrentImage = false;
    }
    //Save all new images added to the list into firebase storage and get url
    if (images.isNotEmpty)
      for (var image in images) {
        if (image != null) {
          storageReference = webFireStorage
              .storage()
              .ref()
              .child('$folderNameImages/${image.name}');

          webFireStorage.UploadTaskSnapshot uploadTaskSnapshot =
              await storageReference.put(image).future;

          Uri imageUrl = await uploadTaskSnapshot.ref.getDownloadURL();
          print('The new images are: $imageUrl');
          imageListUrls.add(imageUrl.toString());
        }
      }
    //save PDF File if file doesn't exist
    if (pdfFile != null && _pdfFileName != null) {
      webFireStorage.StorageReference _ref =
          webFireStorage.storage().ref().child('$folderNameTDS/$_pdfFileName');
      webFireStorage.UploadTaskSnapshot uploadTaskSnapshot =
          await _ref.put(pdfFile).future;

      Uri pdfUrl = await uploadTaskSnapshot.ref.getDownloadURL();
      _pdfUrl = pdfUrl.toString();
    } else {
      error = 'Could not get the pdfFile or it\'s name';
    }
  }

  //Future to get image from firebase storage
  Future<List<Widget>> _getImage(
      BuildContext context, List<dynamic> images) async {
    List<Image> m;
    for (var image in images)
      await FireStorageService.loadFromStorage(context, image)
          .then((downloadurl) {
        m.add(downloadurl);
      });

    return m;
  }

  //Widget to select the type of product category
  Widget selectType() {
    switch (productType) {
      case TAB_PAINT_TEXT:
        return _buildPaintWidget();
        break;
      case TAB_WOOD_TEXT:
        return _buildWoodWidget();
        break;
      case TAB_SS_TEXT:
        return _buildSolidWidget();
        break;
      case TAB_LIGHT_TEXT:
        return _buildLightWidget();
        break;
      case TAB_ACCESSORIES_TEXT:
        return _buildAccessoriesWidget();
        break;
      default:
        return null;
    }
  }

//builds the paint widget product details
  Widget _buildPaintWidget() {
    //return product paint form for admin users
    if (widget.roles.contains('isAdmin')) {
      return Column(
        children: <Widget>[
          //Name field
          Container(
            child: TextFormField(
              initialValue: productName != null ? productName : '',
              textCapitalization: TextCapitalization.characters,
              style: textStyle1,
              decoration: textInputDecoration.copyWith(labelText: PRODUCT_NAME),
              validator: (val) => val.isEmpty ? PRODUCT_NAME_VALIDATION : null,
              onChanged: (val) {
                setState(() {
                  productName = val;
                });
              },
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          //Item Code field
          Container(
            child: TextFormField(
              initialValue: itemCode != null ? itemCode : '',
              textCapitalization: TextCapitalization.characters,
              style: textStyle1,
              decoration: textInputDecoration.copyWith(labelText: PRODUCT_CODE),
              validator: (val) => val.isEmpty ? PRODUCT_CODE_VALIDATION : null,
              onChanged: (val) {
                setState(() {
                  itemCode = val;
                });
              },
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          //Packing field
          Container(
            child: Row(
              children: [
                //Packing quantity
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: productPack != null
                        ? productPack.toString()
                        : zeroValue,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: textStyle1,
                    decoration: textInputDecoration.copyWith(
                        labelText: PRODUCT_PACKAGE),
                    validator: (val) =>
                        productValidators.productPackValidator(val),
                    onChanged: (val) {
                      setState(() {
                        productPack = double.parse(val);
                      });
                    },
                  ),
                ),
                //packing unit
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue:
                        productPackUnit != null ? productPackUnit : '',
                    style: textStyle1,
                    decoration: textInputDecoration.copyWith(
                        labelText: PRODUCT_PACKING_UNIT),
                    validator: (val) =>
                        val.isEmpty ? PRODUCT_PACKING_UNIT_VALIDATION : null,
                    onChanged: (val) {
                      setState(() {
                        productPackUnit = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          //Price field
          Container(
            child: TextFormField(
              initialValue:
                  productPrice != null ? productPrice.toString() : zeroValue,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: textStyle1,
              decoration:
                  textInputDecoration.copyWith(labelText: PRODUCT_PRICE),
              validator: (val) => productValidators.productPriceValidator(val),
              onChanged: (val) {
                setState(() {
                  productPrice = double.parse(val);
                });
              },
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          //Item Cost field
          Container(
            child: TextFormField(
              initialValue:
                  productCost != null ? productCost.toString() : zeroValue,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: textStyle1,
              decoration: textInputDecoration.copyWith(labelText: PRODUCT_COST),
              onChanged: (val) {
                setState(() {
                  productCost = double.parse(val);
                });
              },
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          //Colour field
          Container(
            child: TextFormField(
              initialValue: productColor != null ? productColor : '',
              textCapitalization: TextCapitalization.characters,
              style: textStyle1,
              decoration:
                  textInputDecoration.copyWith(labelText: PRODUCT_COLOUR),
              validator: (val) =>
                  val.isEmpty ? PRODUCT_COLOUR_VALIDATION : null,
              onChanged: (val) {
                setState(() {
                  productColor = val;
                });
              },
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          //Drop down button for brands list
          Container(
            alignment: Alignment.bottomLeft,
            child: new DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: productBrand,
              hint: Text(SELECT_PRODUCT_BRAND),
              onChanged: (String val) {
                setState(() {
                  productBrand = val;
                });
              },
              selectedItemBuilder: (BuildContext context) {
                return _brandList.map<Widget>((String item) {
                  return Text(item, style: textStyle1);
                }).toList();
              },
              items: _brandList.map((String item) {
                return DropdownMenuItem<String>(child: Text(item), value: item);
              }).toList(),
            ),
          ),
          //Image picker from Local images
          Container(
            alignment: Alignment.bottomLeft,
            child: DropdownButton<dynamic>(
              value: paintImageUrl,
              isExpanded: true,
              isDense: true,
              onChanged: (dynamic val) {
                setState(() {
                  print(val.runtimeType);
                  paintImageUrl = val;
                });
              },
              selectedItemBuilder: (BuildContext context) {
                return paintImages.map<Widget>((List<String> imageUrl) {
                  return Text(imageUrl[1] + ' ' + imageUrl[2]);
                }).toList();
              },
              items: paintImages.map((List<String> imageUrl) {
                return DropdownMenuItem(
                    value: imageUrl[0],
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      height: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(imageUrl[0]),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(imageUrl[1]),
                          SizedBox(
                            width: 2.0,
                          ),
                          Text(imageUrl[2])
                        ],
                      ),
                    ));
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          paintImageUrl != null
              //returns the images of the product
              ? Container(height: 270.0, child: Image.asset(paintImageUrl))
              : Container(
                  child: noImageContainer(),
                ),
          SizedBox(
            height: 20.0,
          ),
          //product name field
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(PRODUCT_NAME),
              ),
              Expanded(
                flex: 3,
                child: Text(productName != null ? productName : '',
                    style: textStyle1),
              ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          //product packing field
          Row(
            children: [
              Expanded(flex: 2, child: Text(PRODUCT_PACKAGE)),
              Expanded(
                flex: 3,
                child: Text(
                    productPack != null ? '$productPack $productPackUnit' : '',
                    style: textStyle1),
              ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          //product price
          Row(
            children: [
              Expanded(flex: 2, child: Text(PRODUCT_PRICE)),
              Expanded(
                flex: 3,
                child: Text(
                  productPack != null ? '$productPrice' : '',
                  style: textStyle1,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          //product colour
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(PRODUCT_COLOUR),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  productColor != null ? productColor : '',
                  style: textStyle1,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          //product brand
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(PRODUCT_BRAND),
              ),
              Expanded(
                flex: 3,
                child: Text(productBrand != null ? productBrand : '',
                    style: textStyle1),
              ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          //Show current PDF File Data sheet
          _pdfUrl != null
              ? FlatButton(
                  padding: EdgeInsets.all(15.0),
                  color: Colors.red[200],
                  height: 40.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.black)),
                  child: Text(TDS),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFFileViewer(
                        pdfUrl: _pdfUrl,
                        productName: productName,
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      );
    }
  }

  //builds the wood wiget product details
  Widget _buildWoodWidget() {
    return widget.roles.contains('isAdmin')
        ? Column(
            children: <Widget>[
              //Product Name
              Container(
                child: TextFormField(
                  initialValue: productName != null ? productName : '',
                  textCapitalization: TextCapitalization.characters,
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_NAME),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_NAME_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      productName = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Item Code field
              Container(
                child: TextFormField(
                  initialValue: itemCode != null ? itemCode : '',
                  textCapitalization: TextCapitalization.characters,
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_CODE),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_CODE_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      itemCode = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Product Length
              Container(
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue:
                            length != null ? length.toString() : zeroValue,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: textStyle1,
                        decoration: textInputDecoration.copyWith(
                            labelText: PRODUCT_LENGHT),
                        validator: (val) =>
                            productValidators.productLengthValidator(val),
                        onChanged: (val) {
                          setState(() {
                            length = double.parse(val);
                          });
                        },
                      ),
                    ),
                    //Product Width
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue:
                            width != null ? width.toString() : zeroValue,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: textStyle1,
                        decoration: textInputDecoration.copyWith(
                            labelText: PRODUCT_WIDTH),
                        validator: (val) =>
                            productValidators.productWidthValidator(val),
                        onChanged: (val) {
                          setState(() {
                            width = double.parse(val);
                          });
                        },
                      ),
                    ),
                    //Product Thickness
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: thickness != null
                            ? thickness.toString()
                            : zeroValue,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: textStyle1,
                        decoration: textInputDecoration.copyWith(
                            labelText: PRODUCT_THICKNESS),
                        validator: (val) =>
                            productValidators.productThicknessValidator(val),
                        onChanged: (val) {
                          setState(() {
                            thickness = double.parse(val);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Product Colour
              Container(
                child: TextFormField(
                  initialValue: productColor != null ? productColor : '',
                  textCapitalization: TextCapitalization.characters,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_COLOUR),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_COLOUR_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      productColor = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Price field
              Container(
                child: TextFormField(
                  initialValue: productPrice != null
                      ? productPrice.toString()
                      : zeroValue,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_PRICE),
                  validator: (val) =>
                      productValidators.productPriceValidator(val),
                  onChanged: (val) {
                    setState(() {
                      productPrice = double.parse(val);
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Item Cost field
              Container(
                child: TextFormField(
                  initialValue:
                      productCost != null ? productCost.toString() : zeroValue,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_COST),
                  onChanged: (val) {
                    setState(() {
                      productCost = double.parse(val);
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Drop down button for brands list
              Container(
                alignment: Alignment.bottomLeft,
                child: new DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  value: productBrand,
                  hint: Text(SELECT_PRODUCT_BRAND),
                  onChanged: (String val) {
                    setState(() {
                      productBrand = val;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return _brandList.map<Widget>((String item) {
                      return Text(item, style: textStyle1);
                    }).toList();
                  },
                  items: _brandList.map((String item) {
                    return DropdownMenuItem<String>(
                        child: Text(item), value: item);
                  }).toList(),
                ),
              ),
            ],
          )
        : Column(
            children: <Widget>[
              widget.woodProduct.imageListUrls != null
                  ? Container(
                      height: 270,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.woodProduct.imageListUrls.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200])),
                            child: Image(
                              fit: BoxFit.contain,
                              image: NetworkImage(
                                  widget.woodProduct.imageListUrls[index]),
                              height: 260.0,
                              width: 260.0,
                            ),
                          );
                        },
                      ))
                  : noImageContainer(),
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_NAME),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(productName != null ? productName : '',
                        style: textStyle1),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(flex: 2, child: Text(PRODUCT_PACKAGE)),
                  Expanded(
                      flex: 3,
                      child: Row(
                        children: <Widget>[
                          Text(
                            length.toString() != null ? length : '',
                            style: textStyle1,
                          ),
                          Text(
                            ' x ',
                            style: textStyle1,
                          ),
                          Text(
                            width.toString() != null ? width : '',
                            style: textStyle1,
                          ),
                          Text(
                            ' x ',
                            style: textStyle1,
                          ),
                          Text(
                            thickness.toString() != null ? thickness : '',
                            style: textStyle1,
                          ),
                          Text(
                            'mm',
                            style: textStyle1,
                          )
                        ],
                      )),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_COLOUR),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      productColor != null ? productColor : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_BRAND),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      productBrand != null ? productBrand : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_DESC),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      productDescription != null ? productDescription : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          );
  }

//builds the solid surface widget product details
  Widget _buildSolidWidget() {
    return widget.roles.contains('isAdmin')
        ? Column(
            children: <Widget>[
              //Product Name
              Container(
                child: TextFormField(
                  initialValue: productName != null ? productName : '',
                  textCapitalization: TextCapitalization.characters,
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_NAME),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_NAME_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      productName = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Item Code field
              Container(
                child: TextFormField(
                  initialValue: itemCode != null ? itemCode : '',
                  textCapitalization: TextCapitalization.characters,
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_CODE),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_CODE_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      itemCode = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Product Length
              Container(
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue:
                            length != null ? length.toString() : zeroValue,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: textStyle1,
                        decoration: textInputDecoration.copyWith(
                            labelText: PRODUCT_LENGHT),
                        validator: (val) =>
                            productValidators.productLengthValidator(val),
                        onChanged: (val) {
                          setState(() {
                            length = double.parse(val);
                          });
                        },
                      ),
                    ),
                    //Product Width
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue:
                            width != null ? width.toString() : zeroValue,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: textStyle1,
                        decoration: textInputDecoration.copyWith(
                            labelText: PRODUCT_WIDTH),
                        validator: (val) =>
                            productValidators.productWidthValidator(val),
                        onChanged: (val) {
                          setState(() {
                            width = double.parse(val);
                          });
                        },
                      ),
                    ),
                    //Product Thickness
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: thickness != null
                            ? thickness.toString()
                            : zeroValue,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: textInputDecoration.copyWith(
                            labelText: PRODUCT_THICKNESS),
                        validator: (val) =>
                            productValidators.productThicknessValidator(val),
                        onChanged: (val) {
                          setState(() {
                            thickness = double.parse(val);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.0,
              ), //Price field
              Container(
                child: TextFormField(
                  initialValue: productPrice != null
                      ? productPrice.toString()
                      : zeroValue,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_PRICE),
                  validator: (val) =>
                      productValidators.productPriceValidator(val),
                  onChanged: (val) {
                    setState(() {
                      if (val.isNotEmpty) productPrice = double.parse(val);
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Item Cost field
              Container(
                child: TextFormField(
                  initialValue:
                      productCost != null ? productCost.toString() : zeroValue,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_COST),
                  onChanged: (val) {
                    setState(() {
                      productCost = double.parse(val);
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Product Colour
              Container(
                child: TextFormField(
                  initialValue: productColor != null ? productColor : '',
                  textCapitalization: TextCapitalization.characters,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_COLOUR),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_COLOUR_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      productColor = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Drop down button for brands list
              Container(
                alignment: Alignment.bottomLeft,
                child: new DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  value: productBrand,
                  hint: Text(SELECT_PRODUCT_BRAND),
                  onChanged: (String val) {
                    setState(() {
                      productBrand = val;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return _brandList.map<Widget>((String item) {
                      return Text(item, style: textStyle1);
                    }).toList();
                  },
                  items: _brandList.map((String item) {
                    return DropdownMenuItem<String>(
                        child: Text(item), value: item);
                  }).toList(),
                ),
              ),
            ],
          )
        : Column(
            children: <Widget>[
              widget.woodProduct.imageListUrls != null
                  ? Container(
                      height: 270,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.woodProduct.imageListUrls.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200])),
                            child: Image(
                              fit: BoxFit.contain,
                              image: NetworkImage(
                                  widget.woodProduct.imageListUrls[index]),
                              height: 260.0,
                              width: 260.0,
                            ),
                          );
                        },
                      ))
                  : noImageContainer(),
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_NAME),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(productName != null ? productName : '',
                        style: textStyle1),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(flex: 2, child: Text(PRODUCT_PACKAGE)),
                  Expanded(
                      flex: 3,
                      child: Row(
                        children: <Widget>[
                          Text(
                            length.toString() != null ? length.toString() : '',
                            style: textStyle1,
                          ),
                          Text(
                            ' x ',
                            style: textStyle1,
                          ),
                          Text(
                            width.toString() != null ? width.toString() : '',
                            style: textStyle1,
                          ),
                          Text(
                            ' x ',
                            style: textStyle1,
                          ),
                          Text(
                            thickness.toString() != null
                                ? thickness.toString()
                                : '',
                            style: textStyle1,
                          ),
                          Text(
                            'mm',
                            style: textStyle1,
                          )
                        ],
                      )),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_COLOUR),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      productColor != null ? productColor : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_BRAND),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      productBrand != null ? productBrand : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_DESC),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      productDescription != null ? productDescription : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          );
  }

//builds the lights widget product details
  Widget _buildLightWidget() {
    return widget.roles.contains('isAdmin')
        ? Column(
            children: <Widget>[
              Container(
                width: containerWidth,
                child: TextFormField(
                  initialValue: productName != null ? productName : '',
                  textCapitalization: TextCapitalization.characters,
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_NAME),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_NAME_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      productName = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Container(
                width: containerWidth,
                child: TextFormField(
                  initialValue: dimensions != null ? dimensions : '',
                  textCapitalization: TextCapitalization.characters,
                  style: textStyle1,
                  decoration: textInputDecoration.copyWith(
                      labelText: PRODUCT_DIMENSIOS),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_DIMENSIONS_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      dimensions = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Container(
                width: containerWidth,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: watt != null ? watt : '',
                        textCapitalization: TextCapitalization.characters,
                        style: textStyle1,
                        decoration:
                            textInputDecoration.copyWith(labelText: WATT),
                        validator: (val) =>
                            val.isEmpty ? WATT_VALIDATION : null,
                        onChanged: (val) {
                          setState(() {
                            watt = val;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: voltage != null ? voltage : '',
                        textCapitalization: TextCapitalization.characters,
                        decoration:
                            textInputDecoration.copyWith(labelText: VOLTAGE),
                        validator: (val) =>
                            val.isEmpty ? VOLTAGE_VALIDATION : null,
                        onChanged: (val) {
                          setState(() {
                            voltage = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Container(
                width: containerWidth,
                child: TextFormField(
                  initialValue: productColor != null ? productColor : '',
                  textCapitalization: TextCapitalization.characters,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_COLOUR),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_COLOUR_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      productColor = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              SizedBox(
                height: 15.0,
              ),
              //Drop down button for brands list
              Container(
                width: containerWidth,
                alignment: Alignment.bottomLeft,
                child: new DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  value: productBrand,
                  hint: Text(SELECT_PRODUCT_BRAND),
                  onChanged: (String val) {
                    setState(() {
                      productBrand = val;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return _brandList.map<Widget>((String item) {
                      return Text(item, style: textStyle1);
                    }).toList();
                  },
                  items: _brandList.map((String item) {
                    return DropdownMenuItem<String>(
                        child: Text(item), value: item);
                  }).toList(),
                ),
              ),
            ],
          )
        : Column(
            children: <Widget>[
              widget.lightProduct.imageListUrls != null
                  ? Container(
                      height: 270,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.lightProduct.imageListUrls.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200])),
                            child: Image(
                              fit: BoxFit.contain,
                              image: NetworkImage(
                                  widget.lightProduct.imageListUrls[index]),
                              height: 260.0,
                              width: 260.0,
                            ),
                          );
                        },
                      ))
                  : noImageContainer(),
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_NAME),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(productName != null ? productName : '',
                        style: textStyle1),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(flex: 2, child: Text(PRODUCT_DIMENSIOS)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      dimensions != null ? dimensions : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(flex: 2, child: Text(WATT)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      watt != null ? watt : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(flex: 2, child: Text(VOLTAGE)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      voltage != null ? voltage : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_COLOUR),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      productColor != null ? productColor : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_BRAND),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      productBrand != null ? productBrand : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_DESC),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      productDescription != null ? productDescription : '',
                      style: textStyle1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          );
  }

//builds the accessories widget product details
  Widget _buildAccessoriesWidget() {
    return widget.roles.contains('isAdmin')
        ? Column(
            children: <Widget>[
              //Product Name
              Container(
                child: TextFormField(
                  initialValue: productName != null ? productName : '',
                  textCapitalization: TextCapitalization.characters,
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_NAME),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_NAME_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      productName = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Item Code field
              Container(
                child: TextFormField(
                  initialValue: itemCode != null ? itemCode : '',
                  textCapitalization: TextCapitalization.characters,
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_CODE),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_CODE_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      itemCode = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Product Lenght
              Container(
                child: TextFormField(
                  initialValue:
                      length.toString() != null ? length.toString() : zeroValue,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: textStyle1,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_LENGHT),
                  onChanged: (val) {
                    setState(() {
                      length = double.parse(val);
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Product Angle
              Container(
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: angle.toString() != null
                            ? angle.toString()
                            : zeroValue,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: textStyle1,
                        decoration: textInputDecoration.copyWith(
                            labelText: PRODUCT_ANGLE),
                        onChanged: (val) {
                          setState(() {
                            angle = double.parse(val);
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    //Closing type
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: closingType != null ? closingType : '',
                        textCapitalization: TextCapitalization.characters,
                        decoration: textInputDecoration.copyWith(
                            labelText: PRODUCT_CLOSING_TYPE),
                        validator: (val) => val.isEmpty
                            ? PRODUCT_CLOSING_TYPE_VALIDATION
                            : null,
                        onChanged: (val) {
                          setState(() {
                            closingType = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Product Colour
              Container(
                child: TextFormField(
                  initialValue: productColor != null ? productColor : '',
                  textCapitalization: TextCapitalization.characters,
                  decoration:
                      textInputDecoration.copyWith(labelText: PRODUCT_COLOUR),
                  validator: (val) =>
                      val.isEmpty ? PRODUCT_COLOUR_VALIDATION : null,
                  onChanged: (val) {
                    setState(() {
                      productColor = val;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              //Drop down button for brands list
              Container(
                alignment: Alignment.bottomLeft,
                child: new DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  value: productBrand,
                  hint: Text(SELECT_PRODUCT_BRAND),
                  onChanged: (String val) {
                    setState(() {
                      productBrand = val;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return _brandList.map<Widget>((String item) {
                      return Text(item, style: textStyle1);
                    }).toList();
                  },
                  items: _brandList.map((String item) {
                    return DropdownMenuItem<String>(
                        child: Text(item), value: item);
                  }).toList(),
                ),
              ),
            ],
          )
        : Column(
            children: <Widget>[
              widget.accessoriesProduct.imageListUrls != null
                  ? Container(
                      height: 270,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            widget.accessoriesProduct.imageListUrls.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200])),
                            child: Image(
                              fit: BoxFit.contain,
                              image: NetworkImage(widget
                                  .accessoriesProduct.imageListUrls[index]),
                              height: 260.0,
                              width: 260.0,
                            ),
                          );
                        },
                      ))
                  : noImageContainer(),
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(PRODUCT_NAME),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(productName != null ? productName : '',
                        style: textStyle1),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              length != null
                  ? Row(
                      children: [
                        Expanded(flex: 2, child: Text(PRODUCT_LENGHT)),
                        Expanded(
                          flex: 3,
                          child: Text(
                            length.toString(),
                            style: textStyle1,
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 15.0,
              ),
              angle != null
                  ? Row(
                      children: [
                        Expanded(flex: 2, child: Text(PRODUCT_ANGLE)),
                        Expanded(
                          flex: 3,
                          child: Text(
                            angle.toString(),
                            style: textStyle1,
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 15.0,
              ),
              closingType != null
                  ? Row(
                      children: [
                        Expanded(flex: 2, child: Text(PRODUCT_CLOSING_TYPE)),
                        Expanded(
                          flex: 3,
                          child: Text(
                            closingType,
                            style: textStyle1,
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 15.0,
              ),
              productColor != null
                  ? Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(PRODUCT_COLOUR),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            productColor,
                            style: textStyle1,
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 15.0,
              ),
              productBrand != null
                  ? Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(PRODUCT_BRAND),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            productBrand,
                            style: textStyle1,
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 15.0,
              ),
              productDescription != null
                  ? Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(PRODUCT_DESC),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            productDescription != null
                                ? productDescription
                                : '',
                            style: textStyle1,
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 20.0,
              ),
            ],
          );
  }
}

class PDFFileViewer extends StatefulWidget {
  final String pdfUrl;
  final String productName;
  PDFFileViewer({this.pdfUrl, this.productName});
  @override
  _PDFFileViewerState createState() => _PDFFileViewerState();
}

class _PDFFileViewerState extends State<PDFFileViewer> {
  String landscapePathPdf = "";
  String remotePDFpath = "";
  String corruptedPathPDF = "";
  File pdfFile;
  //Directory dir;
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  bool fileReady = false;
  String fileName;
  String url;
  @override
  void initState() {
    super.initState();

    // createFileOfPdfUrl().then((f) {
    //   setState(() {
    //     remotePDFpath = f.path;
    //     fileReady = true;
    //   });
    // });
  }

  // Future<File> createFileOfPdfUrl() async {
  //   Completer<File> completer = Completer();

  //   try {
  //     url = widget.pdfUrl;
  //     fileName = url.substring(url.lastIndexOf("/") + 1);
  //     var request = await HttpClient().getUrl(Uri.parse(url));
  //     var response = await request.close();
  //     var bytes = await consolidateHttpClientResponseBytes(response);
  //     dir = await getApplicationDocumentsDirectory();

  //     pdfFile = File("${dir.path}/$fileName");
  //     await pdfFile.writeAsBytes(bytes, flush: true);
  //     completer.complete(pdfFile);
  //   } catch (e) {
  //     throw Exception('Error parsing asset file!');
  //   }
  //   return completer.future;
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Technical Data Sheet',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(
            widget.productName,
          ),
        ),
        body: Center(
          child: fileReady
              ? Builder(
                  builder: (context) {
                    return Stack(
                      children: [
                        PDFView(
                          filePath: remotePDFpath,
                          enableSwipe: true,
                          swipeHorizontal: true,
                          autoSpacing: false,
                          pageFling: true,
                          pageSnap: true,
                          defaultPage: currentPage,
                          fitPolicy: FitPolicy.BOTH,
                          preventLinkNavigation:
                              false, // if set to true the link is handled in flutter
                          onRender: (_pages) {
                            setState(() {
                              pages = _pages;
                              isReady = true;
                            });
                          },
                          onError: (error) {
                            setState(() {
                              print('there is an error 1');
                              errorMessage = error.toString();
                            });
                            print(error.toString());
                          },
                          onPageError: (page, error) {
                            setState(() {
                              print('there is an error 2');
                              errorMessage = '$page: ${error.toString()}';
                            });
                            print('$page: ${error.toString()}');
                          },
                          onViewCreated: (PDFViewController pdfViewController) {
                            _controller.complete(pdfViewController);
                          },
                          onLinkHandler: (String uri) {
                            print('goto uri: $uri');
                          },
                          onPageChanged: (int page, int total) {
                            print('page change: $page/$total');
                            setState(() {
                              currentPage = page;
                            });
                          },
                        ),
                        errorMessage.isEmpty
                            ? !isReady
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Container()
                            : Center(
                                child: Text(errorMessage),
                              )
                      ],
                    );
                  },
                )
              : Container(),
        ),
      ),
    );
  }
}

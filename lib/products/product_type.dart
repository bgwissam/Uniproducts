import 'package:flutter/material.dart';
import 'package:web_product_unitrade/models/user.dart';
import 'package:web_product_unitrade/products/product_grid.dart';
import 'package:web_product_unitrade/shared/constants.dart';
import 'package:web_product_unitrade/shared/string.dart';

class ProductType extends StatefulWidget {
  final String productType;
  final String brandName;
  final UserData user;
  final List<dynamic> roles;
  ProductType({this.productType, this.brandName, this.user, this.roles});
  @override
  _ProductTypeState createState() => _ProductTypeState();
}

class _ProductTypeState extends State<ProductType> {
  void initState() {
    super.initState();
  }

  double inkWellWidth = 50.0;
  double inkWellHeight = 50.0;
  double sizedBoxDistance = 25.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(PRODUCT_TYPE),
        backgroundColor: Colors.amberAccent[400],
      ),
      body: _buildProductType(),
    );
  }

  Widget _buildProductType() {
    if (widget.productType == COATINGS || widget.productType == ADHESIVE)
      return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(20.0), child: _buildPaintListType()),
      );
    else if (widget.productType == WOOD)
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: _buildWoodListType(),
        ),
      );
    else if (widget.productType == SOLID_SURFACE)
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: _buildSolidSurafceListType(),
        ),
      );
    else if (widget.productType == ACCESSORIES)
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: _buildAccessoriesListType(),
        ),
      );
    else {
      return Container(
        child: Text('An Error occured, check with Admin'),
      );
    }
  }

  Widget _buildPaintListType() {
    return GridView.count(
      mainAxisSpacing: 40.0,
      crossAxisSpacing: 40.0,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      crossAxisCount: 4,
      children: [
        //PU Paint
        widget.productType == COATINGS
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                brandName: widget.brandName,
                                productType: TAB_PAINT_TEXT,
                                categoryType: PU_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: inkWellWidth,
                    height: inkWellHeight,
                    child: Center(
                        child: Text(
                      PU_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),

        //NC Paint
        widget.productType == COATINGS
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                brandName: widget.brandName,
                                productType: TAB_PAINT_TEXT,
                                categoryType: NC_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: inkWellWidth,
                    height: inkWellHeight,
                    child: Center(
                        child: Text(
                      NC_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),

        //Stain
        widget.productType == COATINGS
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                productType: TAB_PAINT_TEXT,
                                brandName: widget.brandName,
                                categoryType: STAIN,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: inkWellWidth,
                    height: inkWellHeight,
                    child: Center(
                        child: Text(
                      STAIN,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),

        //Thinner
        widget.productType == COATINGS
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                productType: TAB_PAINT_TEXT,
                                brandName: widget.brandName,
                                categoryType: THINNER,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: inkWellWidth,
                    height: inkWellHeight,
                    child: Center(
                        child: Text(
                      THINNER,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),

        //Exterior Paint
        widget.productType == 'COATING'
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                productType: TAB_PAINT_TEXT,
                                brandName: widget.brandName,
                                categoryType: EXT_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: inkWellWidth,
                    height: inkWellHeight,
                    child: Center(
                        child: Text(
                      EXT_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),

        //Acrylic Paint
        widget.productType == COATINGS
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                productType: TAB_PAINT_TEXT,
                                brandName: widget.brandName,
                                categoryType: AC_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: inkWellWidth,
                    height: inkWellHeight,
                    child: Center(
                        child: Text(
                      AC_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),

        //Special Paint
        widget.productType == COATINGS
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                productType: TAB_PAINT_TEXT,
                                brandName: widget.brandName,
                                categoryType: SPECIAL_PRODUCT,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: inkWellWidth,
                    height: inkWellHeight,
                    child: Center(
                        child: Text(
                      SPECIAL_PRODUCT,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),

        //Glue
        widget.productType == ADHESIVE
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                productType: TAB_PAINT_TEXT,
                                brandName: widget.brandName,
                                categoryType: GLUE_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: inkWellWidth,
                    height: inkWellHeight,
                    child: Center(
                        child: Text(
                      GLUE_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildWoodListType() {
    return GridView.count(
      mainAxisSpacing: 40.0,
      crossAxisSpacing: 40.0,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      crossAxisCount: 4,
      children: [
        //MDF
        widget.productType == WOOD
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                brandName: widget.brandName,
                                productType: TAB_WOOD_TEXT,
                                categoryType: MDF_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: MediaQuery.of(context).size.width,
                    height: 120.0,
                    child: Center(
                        child: Text(
                      MDF_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),
        //Firerated products
        widget.productType == WOOD
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                brandName: widget.brandName,
                                productType: TAB_WOOD_TEXT,
                                categoryType: FIRE_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: MediaQuery.of(context).size.width,
                    height: 120.0,
                    child: Center(
                        child: Text(
                      FIRE_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),
        //Formica products
        widget.productType == WOOD
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                brandName: widget.brandName,
                                productType: TAB_WOOD_TEXT,
                                categoryType: HPL_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: MediaQuery.of(context).size.width,
                    height: 120.0,
                    child: Center(
                        child: Text(
                      HPL_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),
        //Chipboard
        widget.productType == WOOD
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                brandName: widget.brandName,
                                productType: TAB_WOOD_TEXT,
                                categoryType: CHIP_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: MediaQuery.of(context).size.width,
                    height: 120.0,
                    child: Center(
                        child: Text(
                      CHIP_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildSolidSurafceListType() {
    return GridView.count(
      mainAxisSpacing: 40.0,
      crossAxisSpacing: 40.0,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      crossAxisCount: 4,
      children: [
        //Corian
        widget.productType == SOLID_SURFACE
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                brandName: widget.brandName,
                                productType: TAB_SS_TEXT,
                                categoryType: COR_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: MediaQuery.of(context).size.width,
                    height: 120.0,
                    child: Center(
                        child: Text(
                      COR_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),
        //Monteli
        widget.productType == SOLID_SURFACE
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                brandName: widget.brandName,
                                productType: TAB_SS_TEXT,
                                categoryType: MON_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: MediaQuery.of(context).size.width,
                    height: 120.0,
                    child: Center(
                        child: Text(
                      MON_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),
        //Adhesives
        widget.productType == SOLID_SURFACE
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                brandName: widget.brandName,
                                productType: TAB_SS_TEXT,
                                categoryType: SS_ADHESIVE_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: MediaQuery.of(context).size.width,
                    height: 120.0,
                    child: Center(
                        child: Text(
                      SS_ADHESIVE_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildAccessoriesListType() {
    return GridView.count(
      mainAxisSpacing: 40.0,
      crossAxisSpacing: 40.0,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      crossAxisCount: 4,
      children: [
        //Salice
        widget.productType == ACCESSORIES
            ? Container(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsGrid(
                                user: widget.user,
                                roles: widget.roles,
                                brandName: widget.brandName,
                                productType: TAB_ACCESSORIES_TEXT,
                                categoryType: SALICE_BUTTON,
                              ))),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]),
                        borderRadius: BorderRadius.circular(25.0)),
                    width: MediaQuery.of(context).size.width,
                    height: 120.0,
                    child: Center(
                        child: Text(
                      SALICE_BUTTON,
                      style: buttonStyle,
                    )),
                  ),
                ),
              )
            : Container(),
        
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:foodsaver/foodDetails.dart';
import 'addFoodItem.dart';
import 'foodDetails.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import "dart:convert";
import 'package:intl/intl.dart';
import './editFoodItem.dart';
import './main.dart';

class Food {
  final int foodId;
  final String foodItem;
  final String expiryDate;
  final int quantity;
  final String units;
  final String category;

  const Food(
      {required this.foodId,
      required this.foodItem,
      required this.expiryDate,
      required this.quantity,
      required this.units,
      required this.category});
}

class Inventory extends StatefulWidget {
  @override
  State<Inventory> createState() => _InventoryState();

  const Inventory({super.key, required this.email});
  final String email;
}

class _InventoryState extends State<Inventory> {
  String selectedFilter = 'Today'; // Default expiry date
  String selectedCategory = 'All'; // Default category
  String selectedSort = 'Expiry Date (nearest to furthest)'; // Default sorting option

  Future<List<Food>> getRequest() async {
    String url = "http://127.0.0.1:5000/allFoodItem";
    final response = await http.get(Uri.parse(url));

    var responseData = json.decode(response.body);

    //Creating a list to store input data;
    List<Food> inventoryList = [];
    for (var indvFood in responseData["data"]) {
      Food food = Food(
          foodId: indvFood["id"],
          foodItem: indvFood["foodItem"],
          expiryDate: indvFood["expiryDate"],
          quantity: indvFood["quantity"],
          units: indvFood["units"],
          category: indvFood["category"]);

      //Adding food to the list.
      inventoryList.add(food);
    }
    return inventoryList;
  }

  List<Food> filterByExpiry(List<Food> foods) {
    DateTime now = DateTime.now();
    switch (selectedFilter) {
      case 'Next 3 days':
        return foods
            .where((food) =>
                DateTime.parse(food.expiryDate).difference(now).inDays <= 3)
            .toList();
      case 'Next 7 days':
        return foods
            .where((food) =>
                DateTime.parse(food.expiryDate).difference(now).inDays <= 7)
            .toList();
      case 'Next 14 days':
        return foods
            .where((food) =>
                DateTime.parse(food.expiryDate).difference(now).inDays <= 14)
            .toList();
      case 'Next 30 days':
        return foods
            .where((food) =>
                DateTime.parse(food.expiryDate).difference(now).inDays <= 30)
            .toList();
      default:
        // Today
        return foods
            .where((food) =>
                DateTime.parse(food.expiryDate).difference(now).inDays <= 1)
            .toList();
    }
  }

  List<Food> filterByCategory(List<Food> foods) {
    if (selectedCategory == 'All') {
      return foods;
    } else {
      return foods.where((food) => food.category == selectedCategory).toList();
    }
  }

  List<Food> sortInventory(List<Food> foods) {
    switch (selectedSort) {
      case 'Expiry Date (nearest to furthest)':
        return foods
          ..sort((a, b) =>
              DateTime.parse(a.expiryDate).compareTo(DateTime.parse(b.expiryDate)));
      case 'Expiry Date (furthest to nearest)':
        return foods
          ..sort((a, b) =>
              DateTime.parse(b.expiryDate).compareTo(DateTime.parse(a.expiryDate)));
      case 'Quantity (most to least)':
        return foods..sort((a, b) => b.quantity.compareTo(a.quantity));
      case 'Quantity (least to most)':
        return foods..sort((a, b) => a.quantity.compareTo(b.quantity));
      case 'Name (A-Z)':
        return foods..sort((a, b) => a.foodItem.compareTo(b.foodItem));
      case 'Name (Z-A)':
        return foods..sort((a, b) => b.foodItem.compareTo(a.foodItem));
      case 'Category':
        return foods..sort((a, b) => a.category.compareTo(b.category));
      case 'Units':
        return foods..sort((a, b) => a.units.compareTo(b.units));
      default:
        return foods;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Welcome \n" + widget.email,
                              style: const TextStyle(
                                color: Color(0xFF003B2B),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              )),
                          Container(
                              child: IconButton(
                            icon: Icon(Icons.logout),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login()));
                            },
                          ))
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Inventory",
                              style: TextStyle(
                                color: Color(0xFF003B2B),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              )),
                          Row(children: [
                            // Sort function
                            Container(
                              child: IconButton(
                                icon: Icon(Icons.sort),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: const Text("Sort By: "),
                                        content: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Form(
                                            child: Column(
                                              children: [
                                                DropdownButton<String>(
                                                  value: selectedSort,
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      selectedSort = newValue!;
                                                    });
                                                    },
                                                  items: <String>[
                                                    'Expiry Date (nearest to furthest)',
                                                    'Expiry Date (furthest to nearest)',
                                                    'Quantity (highest to lowest)',
                                                    'Quantity (lowest to highest)',
                                                    'Name (A-Z)',
                                                    'Name (Z-A)',
                                                    'Category',
                                                    'Units',
                                                  ].map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            // Filter function
                            Container(
                              child: IconButton(
                                icon: Icon(Icons.filter_alt),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: const Text("Filter By: "),
                                        content: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Form(
                                            child: Column(
                                              children: [
                                                // Expiry date
                                                DropdownButton<String>(
                                                  value: selectedFilter,
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      selectedFilter = newValue!;
                                                    });
                                                  },
                                                  items: <String>[
                                                    'Today',
                                                    'Next 3 days',
                                                    'Next 7 days',
                                                    'Next 14 days',
                                                    'Next 30 days',
                                                  ].map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                ),
                                                // Category
                                                DropdownButton<String>(
                                                  value: selectedCategory,
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      selectedCategory = newValue!;
                                                    });
                                                  },
                                                  items: <String>[
                                                    'All',
                                                    'Grains',
                                                    'Milk Product',
                                                    'Fruits',
                                                    'Nuts',
                                                    'Vegetables',
                                                    'Snacks',
                                                    'Beverages',
                                                  ].map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            // Add Food Items
                            Container(
                                child: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddFoodItem(email: widget.email)));
                              },
                            ))
                          ]),
                        ],
                      )),
                  Divider(
                    color: Color(0xFF007F5C),
                    thickness: 0.5,
                  ),
                  // List of Food
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: FutureBuilder(
                      future: getRequest(),
                      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Container(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          List<Food> sortedFoods = sortInventory(filterByCategory(filterByExpiry(snapshot.data)));
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: sortedFoods.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(
                                      Icons.circle,
                                      size: 15,
                                      color: DateTime.parse(snapshot
                                                      .data[index].expiryDate)
                                                  .difference(DateTime.parse(
                                                      DateFormat("yyyy-MM-dd")
                                                          .format(
                                                              DateTime.now())))
                                                  .inDays <=
                                              1
                                          ? Color(0xFFD63434)
                                          : DateTime.parse(snapshot.data[index].expiryDate)
                                                      .difference(DateTime.parse(
                                                          DateFormat("yyyy-MM-dd")
                                                              .format(
                                                                  DateTime.now())))
                                                      .inDays <=
                                                  3
                                              ? Color(0xFFFF9800)
                                              : Color(0xFF007F5C),
                                    ),
                                    trailing: Wrap(
                                      spacing: 5, // space between the icons
                                      children: <Widget>[
                                        // View Food Details
                                        IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>FoodDetails(
                                                        email: widget.email,
                                                        food: snapshot.data[index].foodItem,
                                                        quantity:snapshot.data[index].quantity,
                                                        units: snapshot.data[index].units,
                                                        expiryDate: snapshot.data[index].expiryDate,
                                                        category: snapshot.data[index].category)));
                                            },
                                            icon: const Icon(
                                              Icons.remove_red_eye,
                                              size: 20,
                                            )),
                                        // Edit Food Details
                                        IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>EditFoodItem(
                                                        email: widget.email,
                                                        food: snapshot.data[index].foodItem,
                                                        quantity:snapshot.data[index].quantity,
                                                        units: snapshot.data[index].units,
                                                        expiryDate: snapshot.data[index].expiryDate,
                                                        category: snapshot.data[index].category)));
                                            },
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 20,
                                            )),
                                        // Delete Food
                                        IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                      scrollable: true,
                                                      title: const Text("Delete: "),
                                                      content: Padding(
                                                        padding:const EdgeInsets.all(8.0),
                                                        child: Form(
                                                            child: Column(
                                                          children: [
                                                            Text( "Are you sure you want to delete " + snapshot.data[index].foodItem + "?"),
                                                            Padding(
                                                                padding:const EdgeInsets.all( 10),
                                                                child: ElevatedButton(
                                                                  onPressed: () {},
                                                                  child: const Text('Delete'),
                                                                  style: ElevatedButton.styleFrom(
                                                                      minimumSize:
                                                                          const Size.fromHeight(50),
                                                                      backgroundColor:Color( 0xFFD63434)),
                                                                )),
                                                                Padding(
                                                                padding:const EdgeInsets.all( 10),
                                                                child: OutlinedButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF000000)),),
                                                                  style: OutlinedButton.styleFrom(
                                                                      minimumSize:const Size.fromHeight(50),
                                                                      backgroundColor:Color(0xFFFFFFFF) ),
                                                                ))
                                                          ],
                                                        )),
                                                      ));
                                                });

                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 20,
                                            )),
                                      ],
                                    ),
                                    title: Text(
                                      snapshot.data[index].foodItem,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    subtitle: Text(
                                      "Expiring on: " +
                                          snapshot.data[index].expiryDate,
                                      style: TextStyle(
                                          color: DateTime.parse(snapshot
                                                          .data[index]
                                                          .expiryDate)
                                                      .difference(DateTime.parse(
                                                          DateFormat("yyyy-MM-dd").format(
                                                              DateTime.now())))
                                                      .inDays <=
                                                  1
                                              ? Color(0xFFD63434)
                                              : DateTime.parse(snapshot
                                                              .data[index]
                                                              .expiryDate)
                                                          .difference(DateTime.parse(
                                                              DateFormat("yyyy-MM-dd")
                                                                  .format(DateTime.now())))
                                                          .inDays <=
                                                      3
                                                  ? Color(0xFFFF9800)
                                                  : Color(0xFF007F5C)),
                                    ),
                                  ),
                                  Divider(
                                    color: Color(0xFF007F5C),
                                    thickness: 0.5,
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              )))),
    bottomNavigationBar: CustomBottomNavigationBar()
    );
  }
}

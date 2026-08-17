import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:j_app/screens/cart_page_screen.dart';
import 'package:j_app/screens/first_Screen.dart';
import 'package:j_app/screens/profile_page_screen.dart';
import 'package:j_app/screens/wish_list_page.dart';
import 'coffee_detail_screen.dart';
import 'dart:async';
import 'package:j_app/data/cart_data.dart';
import 'saved_screen.dart';
import 'package:j_app/widgets/bottom_nav_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'about_us_page.dart';
import 'privacy_policy_page.dart';
import 'terms_conditions_page.dart';
import 'package:j_app/data/coffee_list.dart';
import 'package:j_app/data/wishlist_data.dart';
import 'package:hive_flutter/hive_flutter.dart';


class HomePage extends StatefulWidget {


  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends  State<HomePage>{
  FirebaseAuth auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  String selectedCoffee = "All Coffee";
  String selectedPriceRange = "All";
  TextEditingController searchController = TextEditingController();




  @override
  void initState() {
    super.initState();

    sliderTimer = Timer.periodic(
      const Duration(seconds: 2),
          (timer) {
        if (currentPage < sliderImages.length - 1) {
          currentPage++;
        } else {
          currentPage = 0;
        }

        pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  List<String> sliderImages = [
    "assets/images/coffee_background.webp",
    "assets/images/coffee_icons.jpg",
    "assets/images/coffee_themed.avif",
  ];

  PageController pageController = PageController();
  int currentPage = 0;
  Timer? sliderTimer;

  @override
  void dispose() {
    searchController.dispose();
    pageController.dispose();
    sliderTimer?.cancel();
    super.dispose();
  }

  bool matchesPrice(double price) {
    if (selectedPriceRange == "Under \$3") return price < 3;
    if (selectedPriceRange == "\$3 - \$4") return price >= 3 && price <= 4;
    if (selectedPriceRange == "Above \$4") return price > 4;
    return true;
  }

  @override
  Widget build(BuildContext context) {

    String searchText = searchController.text.toLowerCase();

    List<Map<String, dynamic>> filteredCoffee = coffeelist.where((coffee) {
      bool matchesCategory = selectedCoffee == "All Coffee" || coffee["category"] == selectedCoffee;
      bool matchesSearch = coffee["name"].toString().toLowerCase().contains(searchText);
      return matchesCategory && matchesSearch && matchesPrice(coffee["price"]);
    }).toList();

    List<Map<String, dynamic>> popularCoffee = coffeelist.where((coffee) {
      bool matchesCategory = selectedCoffee == "All Coffee" || coffee["category"] == selectedCoffee;
      bool matchesSearch = coffee["name"].toString().toLowerCase().contains(searchText);
      return matchesCategory && matchesSearch && coffee["popular"] == true && matchesPrice(coffee["price"]);
    }).toList();


    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.black87,
        toolbarHeight: 100,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            );
          },
        ),
        title: const Text(
          " The Cafe",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all (10),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFC67C4E),
                borderRadius: BorderRadius.circular(15),
              ),

              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WishlistPage(),
                    ),
                  );

                },
                icon: const Icon(
                  Icons.favorite_rounded, color: Colors.white,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFC67C4E),
                borderRadius: BorderRadius.circular(15),
              ),

              child: IconButton(
                onPressed: () {
                  showFilterSheet();
                },
                icon: const Icon(
                  Icons.tune,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),

      drawer: Drawer(backgroundColor: Colors.black87,child: ListView(children: [DrawerHeader(

          child: Align(alignment: Alignment.centerLeft,
        child: Image.asset(
            "assets/images/app_icon.png",
            width: 110,
            height: 110,
            fit: BoxFit.contain,
          ),
        ),
      ),
        const SizedBox(height: 15),

        ListTile(
          title: const Text(
            "My Cart",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartPage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text(
            "Profile",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text(
            "Wishlist",
            style: TextStyle(
              color: Colors.white,
            ),
          ),


          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const WishlistPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 30),

        const Divider(),

        const SizedBox(height: 10),
        ListTile(
          title: const Text(
            "About us",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AboutUsPage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text(
            "Terms & Conditions",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsConditionsPage(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text(
            "Privacy & Policy",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 30),

        const Divider(),

        const SizedBox(height: 10),
        ListTile(
          title: const Text("Sign Out", style: TextStyle(
            color: Colors.white,
          ),),
          onTap: signout,
        ),

      ],
      ),
      ),

      body:  Stack(

        children: [

          Column(
            children: [

              SizedBox(height: 20,),

              //image slider
              Stack(
                alignment: Alignment.bottomCenter,

                children: [

                  SizedBox(
                    height: 180,

                    child: PageView.builder(
                      controller: pageController,
                      itemCount: sliderImages.length,

                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },

                      itemBuilder: (context, index) {

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),

                          clipBehavior: Clip.antiAlias,

                          child: Stack(
                            children: [

                              Positioned.fill(
                                child: Image.asset(
                                  sliderImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Positioned(
                                bottom: 20,
                                left: 20,

                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/cart',
                                    );
                                  },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFFC67C4E),
                                    foregroundColor: Colors.white,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),

                                  child: const Text(
                                    "Order Now",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),                  Positioned(
                    bottom: 10,

                    child: Row(
                      children: List.generate(
                        sliderImages.length,

                            (index) {

                          return Container(
                            width: 7,
                            height: 7,

                            margin: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              color: currentPage == index
                                  ? const Color(0xFFC67C4E)
                                  : Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
//chips

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:
                  Row(

                    children: [


                      ElevatedButton(
                        onPressed: () {
                          selectCoffee("All Coffee");
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCoffee == "All Coffee"
                              ? Color(0xFFC67C4E)
                              : Colors.white,
                        ),

                        child: Text("All Coffee",
                          style: TextStyle(
                            color: selectedCoffee == "All Coffee"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 5,),

                      ElevatedButton(
                        onPressed: () {
                          selectCoffee("Latte");
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCoffee == "Latte"
                              ? Color(0xFFC67C4E)
                              : Colors.white,
                        ),

                        child: Text(
                          "Latte",
                          style: TextStyle(
                            color: selectedCoffee == "Latte"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 5,),

                      ElevatedButton(
                        onPressed: () {
                          selectCoffee("Matcha");
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCoffee == "Matcha"
                              ? Color(0xFFC67C4E)
                              : Colors.white,
                        ),

                        child: Text(
                          "Matcha",
                          style: TextStyle(
                            color: selectedCoffee == "Matcha"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 5,),

                      ElevatedButton(
                        onPressed: () {
                          selectCoffee("Americano");
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCoffee == "Americano"
                              ? Color(0xFFC67C4E)
                              : Colors.white,
                        ),

                        child: Text(
                          "Americano",
                          style: TextStyle(
                            color: selectedCoffee == "Americano"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),

                      SizedBox(width: 5,),

                      ElevatedButton(
                        onPressed: () {
                          selectCoffee("Espresso");
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCoffee == "Espresso"
                              ? Color(0xFFC67C4E)
                              : Colors.white,
                        ),

                        child: Text(
                          "Espresso",
                          style: TextStyle(
                            color: selectedCoffee == "Espresso"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Expanded(
                  child: ListView(
                    children: [

                      const SizedBox(height: 10),
                      if (popularCoffee.isNotEmpty) ...[

                    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Text(
                    "Best Sellers",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  height: 230,

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: popularCoffee.length,

                    itemBuilder: (context, index) {

                      var coffee = popularCoffee[index];

                      return SizedBox(
                        width: 180,

                        child:
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CoffeeDetailPage(
                                  coffee: coffee,
                                ),
                              ),
                            );
                          },

                          child: Card(
                            margin: const EdgeInsets.only(right: 10),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),

                            clipBehavior: Clip.antiAlias,

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,


                              children: [

                                Stack(
                                  children: [
                                    Image.asset(
                                      coffee["image"],
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),

                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: ValueListenableBuilder(
                                          valueListenable: wishlistBox.listenable(),
                                          builder: (context, box, _) {
                                            final isFavorite =
                                            isWishlisted(coffee["name"]);

                                            return IconButton(
                                              onPressed: () {
                                                if (isFavorite) {
                                                  removeFromWishlist(
                                                    coffee["name"],
                                                  );

                                                  Fluttertoast.showToast(
                                                    msg: "Removed from Wishlist",
                                                  );
                                                } else {
                                                  addToWishlist(coffee);

                                                  Fluttertoast.showToast(
                                                    msg: "Added to Wishlist",
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFavorite
                                                    ? const Color(0xFFC67C4E)
                                                    : Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),

                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                    children: [

                                      Text(
                                        coffee["name"],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Text(
                                        coffee["description"],
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                        children: [

                                          Text(
                                            "\$${coffee["price"]}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                addToCart(coffee);
                                              });

                                              Fluttertoast.showToast(
                                                msg: "Added to Cart",
                                              );
                                            },

                                            child: Container(
                                              width: 30,
                                              height: 30,

                                              decoration: BoxDecoration(
                                                color: const Color(0xFFC67C4E),
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),

                                              child: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 10,),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Text("All Coffee", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredCoffee.length,

                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),

                    itemBuilder: (context, index) {

                      var coffee = filteredCoffee[index];
                      return
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CoffeeDetailPage(
                                  coffee: coffee,
                                ),
                              ),
                            );
                          },

                          child:
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),

                            clipBehavior: Clip.antiAlias,

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Stack(
                                  children: [
                                    Image.asset(
                                      coffee["image"],
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),

                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: ValueListenableBuilder(
                                          valueListenable: wishlistBox.listenable(),
                                          builder: (context, box, _) {
                                            final isFavorite =
                                            isWishlisted(coffee["name"]);

                                            return IconButton(
                                              onPressed: () {
                                                if (isFavorite) {
                                                  removeFromWishlist(
                                                    coffee["name"],
                                                  );

                                                  Fluttertoast.showToast(
                                                    msg: "Removed from Wishlist",
                                                  );
                                                } else {
                                                  addToWishlist(coffee);

                                                  Fluttertoast.showToast(
                                                    msg: "Added to Wishlist",
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFavorite
                                                    ? const Color(0xFFC67C4E)
                                                    : Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(15),

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: [

                                      Text(
                                        coffee["name"],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        coffee["description"],
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                        children: [

                                          Text(
                                            "\$${coffee["price"]}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                addToCart(coffee);
                                              });

                                              Fluttertoast.showToast(
                                                msg: "Added to Cart",
                                              );
                                            },

                                            child: Container(
                                              width: 30,
                                              height: 30,

                                              decoration: BoxDecoration(
                                                color: const Color(0xFFC67C4E),
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),

                                              child: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),

                                        ],
                                      )

                                    ],
                                  ),
                                )

                              ],
                            ),
                          ),
                        );
                    },
                  ),
                ),
              ],)

              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 0,
      ),
    );
  }

  void selectCoffee(String coffee) {
    setState(() {
      selectedCoffee = coffee;
    });
  }


  Future<void> signout() async {

    final bool? remember = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Sign Out",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            "Do you want this device to remember your login?",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                "No",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "Yes",
                style: TextStyle(
                  color: Color(0xFFC67C4E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (remember == null) {
      return;
    }

    if (remember == false) {

      await _storage.delete(
        key: 'saved_email',
      );

      await _storage.delete(
        key: 'saved_password',
      );

      await _storage.write(
        key: 'remember_login',
        value: 'false',
      );

      await FirebaseAuth.instance.signOut();

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const FirstScreen(),
        ),
            (route) => false,
      );

      return;
    }

    await _storage.write(
      key: 'remember_login',
      value: 'true',
    );

    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const SavedScreen(),
      ),
          (route) => false,
    );
  }

  void showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(alignment: Alignment.topRight,
                  child: IconButton(onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel, color: Colors.white,size:30,),),),
                  TextField(
                    controller: searchController,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                    onChanged: (value) {
                      setModalState(() {});
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Search Coffee",
                      hintStyle: const TextStyle(
                        color: Colors.white70,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Price Range",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ["All", "Under \$3", "\$3 - \$4", "Above \$4"].map((range) {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); //filter bar closes after choosing the filter
                          setModalState(() {
                            selectedPriceRange = range;

                          });
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPriceRange == range
                              ? Color(0xFFC67C4E)
                              : Colors.white,
                        ),
                        child: Text(
                          range,
                          style: TextStyle(
                            color: selectedPriceRange == range
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


import 'package:carousel_slider/carousel_slider.dart';
import 'package:smart_service/src/constants/colors.dart';
import 'package:smart_service/src/screens/verify_account/verify_account.dart';
import 'package:smart_service/src/utils/helpers/helper_function.dart';
import 'package:smart_service/src/utils/texts/button_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_custom/text_custom.dart';
import 'package:smart_service/src/screens/orders/form_order.dart';
import 'package:intl/intl.dart';
import 'package:smart_service/src/models/transactions/transaction_model.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.userFullName,
    required this.userEmail,
  });

  final String userFullName;
  final String userEmail;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final CarouselController carouselController = CarouselController();
  int currentIndex = 0;

  /*   final carousels = [
    'assets/images/Slide1.jpg',
    'assets/images/Slide2.jpg',
    'assets/images/Slide3.jpg',
    'assets/images/Slide4.jpg',
  ];
 */
  List imageList = [
    {"id": 1, "image_path": 'assets/images/Slide1.jpg'},
    {"id": 2, "image_path": 'assets/images/Slide2.jpg'},
    {"id": 3, "image_path": 'assets/images/Slide3.jpg'},
    {"id": 4, "image_path": 'assets/images/Slide4.jpg'},
  ];
  Stream<double> getUserBalance(String userId) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0;

          double totalPayments = 0;
          double totalWithdrawals = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final amount = (data['amount'] as num).toDouble();
            final type = data['type'];

            if (type == 'payment') {
              totalPayments += amount;
            } else if (type == 'withdrawal') {
              totalWithdrawals += amount;
            }
          }

          return totalPayments - totalWithdrawals;
        });
  }

  Stream<int> getCarsTotal(String userId) {
    return FirebaseFirestore.instance
        .collection('cars')
        .where(
          'userCreatedRef',
          isEqualTo: FirebaseFirestore.instance.collection('users').doc(userId),
        )
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0;

          return snapshot.docs.length;
        });
  }

  Stream<int> getBrandsTotal(String userId) {
    return FirebaseFirestore.instance
        .collection('brands')
        .where(
          'userId',
          isEqualTo: FirebaseFirestore.instance.collection('users').doc(userId),
        )
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0;

          return snapshot.docs.length;
        });
  }

  Stream<int> getOrderPendingTotal(String userId) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where(
          'ownerRef',
          isEqualTo: FirebaseFirestore.instance.collection('users').doc(userId),
        )
        .where('paymentStatus', isEqualTo: "Pending")
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0;

          return snapshot.docs.length;
        });
  }

  Stream<int> getOrderFinishTotal(String userId) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where(
          'ownerRef',
          isEqualTo: FirebaseFirestore.instance.collection('users').doc(userId),
        )
        .where('status', isEqualTo: "finish")
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0;

          return snapshot.docs.length;
        });
  }

   Stream<List<TransactionModel>> getTransactions(String userId) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromSnapshot(doc))
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextCustom(
                    TheText: "Prêt pour une nouvelle commande ?",
                    TheTextSize: 14,
                    TheTextFontWeight: FontWeight.normal,
                  ),
                ],
              ),
              SizedBox(height: 5),
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      print(currentIndex);
                    },
                    child: CarouselSlider(
                      items: imageList
                          .map(
                            (item) => Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                               
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.asset(
                                  item['image_path'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      // carouselController: carouselController,
                      options: CarouselOptions(
                        scrollPhysics: const BouncingScrollPhysics(),
                        autoPlay: true,
                        aspectRatio: 2,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
                  /*   Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imageList.asMap().entries.map((entry) {
                        return GestureDetector(
                          // onTap: () =>carouselController.animateToPage(entry.key),
                          child: Container(
                            width: currentIndex == entry.key ? 17 : 7,
                            height: 7.0,
                            margin: const EdgeInsets.symmetric(horizontal: 3.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: currentIndex == entry.key
                                  ? Colors.red
                                  : Colors.teal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ), */
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextCustom(
                    TheText: 'Services disponibles',
                    TheTextSize: 15,
                    TheTextFontWeight: FontWeight.bold,
                    TheTextColor: THelperFunctions.isDarkMode(context)
                        ? ColorApp.tWhiteColor
                        : ColorApp.tBlackColor,
                  ),
                ],
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tSecondaryNewColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage(
                                  'assets/images/super-market.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Super Marché",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tsombreBleuColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage(
                                  'assets/images/pharmacie.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Pharmacie",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tSecondaryNewColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage('assets/images/repas.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Repas",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tsombreBleuColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage('assets/images/delivery.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Course",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tSecondaryNewColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage(
                                  'assets/images/super-market.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Marché",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tsombreBleuColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage(
                                  'assets/images/restaurant.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Restaurant",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tSecondaryNewColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage(
                                  'assets/images/administration_image.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Courrier",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tsombreBleuColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage(
                                  'assets/images/coordonier.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Couturier",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tSecondaryNewColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage('assets/images/banque.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Banque",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tsombreBleuColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage('assets/images/gaz.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Recharge de Gaz",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tSecondaryNewColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage('assets/images/cor.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Cordonnier",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Get.to(() => FormOrderScreen());
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorApp.tsombreBleuColor,
                            ),
                            child: Center(
                              child: Image(
                                width: 45,
                                height: 45,
                                image: AssetImage(
                                  'assets/images/ecolier.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              TextCustom(
                                TheText: "Ecolier(e)s",
                                TheTextSize: 12,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextCustom(
                    TheText: 'Livraisons récentes',
                    TheTextSize: 15,
                    TheTextFontWeight: FontWeight.bold,
                    TheTextColor: THelperFunctions.isDarkMode(context)
                        ? ColorApp.tWhiteColor
                        : ColorApp.tBlackColor,
                  ),
                ],
              ),
              SizedBox(height: 10),
               StreamBuilder(
                stream: getTransactions(FirebaseAuth.instance.currentUser!.uid),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
                    return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: ColorApp.tsombreBleuColor,
                          ),
                          child: Center(
                            child: Lottie.asset(
                                   height: 150,
                            width: 150,
                                  'assets/images/no_data.json',
                                fit: BoxFit.cover,
                                ),
                          ),
                          );
                  }

                  final transaction = asyncSnapshot.data!;

                  return ListView.builder(
                    itemCount: transaction.length,
                    shrinkWrap: true, // Important pour éviter overflow
                  physics: const NeverScrollableScrollPhysics(), // Empêche conflit scroll
                    itemBuilder: (context, index) {
                      final traansactionItem = transaction[index];
                      return Container(
                        height: 120,
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 74, 74, 74),
                        ),
                      
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextCustom(
                                  TheText:
                                      "Transaction #${traansactionItem.reference}",
                                  TheTextSize: 14,
                                  TheTextFontWeight: FontWeight.bold,
                                ),
                                TextCustom(
                                   TheText: DateFormat('d/M/y - HH:mm')
                                                .format(
                                                  traansactionItem.createdAt.toDate(),
                                                ),
                                  TheTextSize: 12,
                                ),
                                if (traansactionItem.status == "completed")
                                  Container(
                                    height: 30,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.green,
                                    ),
                                    child: Center(
                                      child: TextCustom(
                                        TheText: traansactionItem.status,
                                        TheTextSize: 12,
                                      ),
                                    ),
                                  ),
                      
                                if (traansactionItem.status == "failed")
                                  Container(
                                    height: 30,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.red,
                                    ),
                                    child: Center(
                                      child: TextCustom(
                                        TheText: traansactionItem.status,
                                        TheTextSize: 12,
                                      ),
                                    ),
                                  ),
                      
                                if (traansactionItem.status == "pending")
                                  Container(
                                    height: 30,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey,
                                    ),
                                    child: Center(
                                      child: TextCustom(
                                        TheText: traansactionItem.status,
                                        TheTextSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                if (traansactionItem.type == "payment")
                                  TextCustom(
                                    TheText: "+ ${traansactionItem.amount}",
                                    TheTextSize: 15,
                                    TheTextColor: Colors.green,
                                    TheTextFontWeight: FontWeight.bold,
                                  ),
                                if (traansactionItem.type == "withdrawal")
                                  TextCustom(
                                    TheText: "- ${traansactionItem.amount}",
                                    TheTextSize: 15,
                                    TheTextColor: Colors.red,
                                    TheTextFontWeight: FontWeight.bold,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

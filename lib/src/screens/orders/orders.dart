import 'package:lottie/lottie.dart';
import 'package:smart_service/src/constants/colors.dart';
import 'package:smart_service/src/models/order_model.dart';
import 'package:smart_service/src/screens/orders/order_step.dart';
import 'package:smart_service/src/screens/tabs.dart';
import 'package:smart_service/src/utils/helpers/helper_function.dart';
import 'package:smart_service/src/utils/loaders/loaders.dart';
import 'package:smart_service/src/utils/texts/button_custom.dart';
import 'package:smart_service/src/utils/texts/text_custom.dart';
import 'package:smart_service/src/utils/widget_theme/custom_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final tabs = OrderStatus.values.map((item) => item.name).toList();
  late List<OrderModel> orders = [];
  int selectedStars = 0;
  final TextEditingController commentController = TextEditingController();
  bool isValidated = false;

  Stream<List<OrderModel>> _getOrderList() {
    final firebase = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance.currentUser!;
    return firebase
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .where('userRef', isEqualTo: firebase.collection('users').doc(auth.uid))
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((order) => OrderModel.fromSnapshot(order))
              .toList(),
        );
  }

  void showAvisModal(BuildContext context, String orderId) async {
    TextEditingController commentController = TextEditingController();
    int selectedStars = 0;
    bool isValidated = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Donnez votre avis",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // ⭐ Étoiles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setModalState(() {
                            selectedStars = index + 1;
                          });
                        },
                        icon: Icon(
                          index < selectedStars
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 20),

                  // 💬 Commentaire
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Commentaire (obligatoire)",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 📤 Bouton d’envoi
                  isValidated
                      ? CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (selectedStars == 0) {
                                TLoaders.errorSnackBar(
                                  title:
                                      "Vous devez donner une note en étoiles",
                                );
                                return;
                              }
                              if (commentController.text.isEmpty) {
                                TLoaders.errorSnackBar(
                                  title:
                                      "Vous devez donner un commentaire sur la livraison.",
                                );
                                return;
                              }
                              try {
                                setModalState(() {
                                  isValidated = true;
                                });

                                await FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(orderId)
                                    .update({
                                      "clientRating": selectedStars,
                                      "clientReviews": commentController.text
                                          .trim(),
                                      "status": "completed",
                                    });

                                setModalState(() {
                                  isValidated = false;
                                });

                                TLoaders.successSnackBar(
                                  title: "Avis envoyé avec succès.",
                                );
                                Navigator.pop(context);
                              } catch (e) {
                                setModalState(() {
                                  isValidated = false;
                                });
                                TLoaders.errorSnackBar(title: "Erreur $e");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorApp.tsecondaryColor,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text("Envoyer ma note"),
                          ),
                        ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.orange.shade100,
                ),
                child: const TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: ColorApp.tsecondaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelColor: ColorApp.tWhiteColor,
                  unselectedLabelColor: ColorApp.tBlackColor,
                  tabs: [
                    Tab(text: "Mes courses"),
                    Tab(text: "Historiques"),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: _getOrderList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      height: 150,
                      width: 150,
                      'assets/images/no_data.json',
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    TextCustom(
                      TheText: "Aucune course trouvée",
                      TheTextSize: 13,
                    ),
                  ],
                ),
              );
            }

            final allOrders = snapshot.data!;

            // Séparation des commandes
            final mesCourses = allOrders
                .where((order) => order.status.toLowerCase() != "completed")
                .toList();

            final historiques = allOrders
                .where((order) => order.status.toLowerCase() == "completed")
                .toList();

            return TabBarView(
              children: [
                // Onglet "Mes courses"
                _buildOrderList(mesCourses),

                // Onglet "Historiques"
                _buildOrderList(historiques),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget réutilisable pour afficher une liste de commandes
  Widget _buildOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorApp.tsombreBleuColor,
        ),
        child: Center(
          child: Column(
            children: [
              Lottie.asset(
                height: 150,
                width: 150,
                'assets/images/no_data.json',
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              TextCustom(TheText: "Aucune course trouvée", TheTextSize: 13),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      separatorBuilder: (_, __) => const SizedBox(height: 1),
      itemCount: orders.length,
      itemBuilder: (_, index) {
        final order = orders[index];
        return InkWell(
          onTap: () {
            print(order.orderId);
            Get.to(
              () => OrderStep(
                status: order.status,
                orderId: order.uid!,
                amount: order.amount,
                carId: '',
                userCreatedId: order.userRef!.id,
                managerRef: order.managerRef,
                deliverRef: order.deliverRef,
                totalPrice: order.totalPrice,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
              height: order.status == "finish"? 140 : 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: ColorApp.tSombreColor),
              ),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    height: 100,
                    width: 100,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: Image.asset(
                        'assets/images/Screenshot.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /* 1 */
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextCustom(
                              TheText: 'Course: ${order.orderId}',
                              TheTextSize: 13,
                              TheTextFontWeight: FontWeight.bold,
                            ),
                            Container(
                              width: 90,
                              height: 30,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: ColorApp.tsecondaryColor,
                                ),
                              ),
                              child: Center(
                                child: Expanded(
                                  child: TextCustom(
                                    TheText: order.status,
                                    TheTextSize: 12,
                                    TheTextFontWeight: FontWeight.bold,
                                    TheTextColor: ColorApp.tsecondaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        /* 2 */
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextCustom(
                              TheText: 'Date',
                              TheTextSize: 13,
                              TheTextFontWeight: FontWeight.bold,
                            ),
                            Row(
                              spacing: 3,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.date_range_outlined,
                                  size: 16,
                                  color: ColorApp.tsecondaryColor,
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: TextCustom(
                                    TheText: DateFormat(
                                      'd/M/y',
                                    ).format(order.createdAt.toDate()),
                                    TheTextSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextCustom(
                              TheText: 'Prix',
                              TheTextSize: 13,
                              TheTextFontWeight: FontWeight.bold,
                            ),
                            Row(
                              spacing: 3,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: TextCustom(
                                    TheText:
                                        "${order.amount.toStringAsFixed(2)} FCFA",
                                    TheTextSize: 12,
                                    TheTextColor: ColorApp.tSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (order.status == "finish")
                          Container(
                            height: 30,
                            width: 120,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: ColorApp.tPrimaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: InkWell(
                              onTap: () => showAvisModal(context, order.uid!),
                              child: Center(
                                child: TextCustom(
                                  TheText: 'Noter la course',
                                  TheTextSize: 13,
                                  TheTextColor: ColorApp.tWhiteColor,
                                  TheTextFontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            /*  child: ButtonCustom(
                              buttonBackgroundColor: ColorApp.tPrimaryColor,
                              onPressed: () =>
                                  showAvisModal(context, order.uid!),
                              text: 'Noter la course',
                              textSize: 13,
                            ), */
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
    );
  }
}

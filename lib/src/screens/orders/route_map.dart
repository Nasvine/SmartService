import 'dart:math' show cos, sqrt, asin;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:smart_service/notification_services.dart';
import 'package:smart_service/src/constants/colors.dart';
import 'package:smart_service/src/models/order_model.dart';
import 'package:smart_service/src/screens/tabs.dart';
import 'package:smart_service/src/utils/helpers/helper_function.dart';
import 'dart:math';

import 'package:smart_service/src/utils/loaders/loaders.dart';
import 'package:smart_service/src/utils/texts/text_custom.dart';
import 'package:smart_service/src/utils/texts/text_form_field_simple_custom.dart';
import 'package:smart_service/src/utils/validators/validator.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({
    super.key,
    required this.startLocation,
    required this.companyLocation,
    required this.endLocation,
    required this.packageType,
    required this.message,
    required this.numeroWithdrawal,
    this.orderId = "",
  });

  final PlaceLocation startLocation; // Adresse de retrait
  final PlaceLocation companyLocation; // Entreprise
  final PlaceLocation endLocation; // Destination
  final String packageType;
  final String message;
  final int numeroWithdrawal;
  final String orderId;

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  GoogleMapController? _mapController;
  double _totalDistanceKm = 0.0;
  double _totalPrice = 0.0;
  bool _loadingPrice = true;
  bool isValidated = false;
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calculateTotalDistance();
    _fetchPriceFromFirebase();
  }

  /// Formule Haversine
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // pi / 180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R * asin...
  }

  void _calculateTotalDistance() {
    // Segment 1 : Entreprise → Adresse de retrait
    final d1 = _calculateDistance(
      widget.companyLocation.latitude,
      widget.companyLocation.longitude,
      widget.startLocation.latitude,
      widget.startLocation.longitude,
    );

    // Segment 2 : Adresse de retrait → Destination
    final d2 = _calculateDistance(
      widget.startLocation.latitude,
      widget.startLocation.longitude,
      widget.endLocation.latitude,
      widget.endLocation.longitude,
    );

    // Segment 3 : Destination → Entreprise
    final d3 = _calculateDistance(
      widget.endLocation.latitude,
      widget.endLocation.longitude,
      widget.companyLocation.latitude,
      widget.companyLocation.longitude,
    );

    _totalDistanceKm = d1 + d2 + d3;
  }

  Future<void> _fetchPriceFromFirebase() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("deliveryprices")
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        final data = doc.docs.first.data();
        final double pricePerKm = (data["price"] ?? 0).toDouble();
        _totalPrice = _totalDistanceKm * pricePerKm;
      }
    } catch (e) {
      debugPrint("Erreur récupération prix : $e");
    }
    setState(() {
      _loadingPrice = false;
    });
  }

  String generateOrderId() {
    final random = Random();
    int number = random.nextInt(1000000); // génère un nombre entre 0 et 999999
    return number.toString().padLeft(6, '0'); // ajoute des zéros si nécessaire
  }

  void showCancelModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context) {
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
                "Motif de l'annulation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextCustom(
                    TheText: "tMessageCancelText".tr,
                    TheTextSize: 14,
                    TheTextFontWeight: FontWeight.bold,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormFieldSimpleCustom(
                keyboardType: TextInputType.text,
                MaxLines: 5,
                obscureText: false,
                borderRadiusBorder: 10,
                cursorColor: THelperFunctions.isDarkMode(context)
                    ? ColorApp.tWhiteColor
                    : ColorApp.tBlackColor,
                borderSideRadiusBorder: THelperFunctions.isDarkMode(context)
                    ? ColorApp.tsecondaryColor
                    : ColorApp.tSombreColor,
                borderRadiusFocusedBorder: 10,
                borderSideRadiusFocusedBorder:
                    THelperFunctions.isDarkMode(context)
                    ? ColorApp.tsecondaryColor
                    : ColorApp.tSombreColor,
                controller: messageController,
                labelText: widget.orderId != null
                    ? messageController.text
                    : "tMessageCancel".tr,
                labelStyleColor: THelperFunctions.isDarkMode(context)
                    ? ColorApp.tWhiteColor
                    : ColorApp.tBlackColor,
                hintText: widget.orderId != null
                    ? messageController.text
                    : "tMessageCancel".tr,
                hintStyleColor: THelperFunctions.isDarkMode(context)
                    ? ColorApp.tWhiteColor
                    : ColorApp.tBlackColor,

                validator: (value) =>
                    TValidator.validationEmptyText("tMessageCancel".tr, value),
              ),
              const SizedBox(height: 10),

              // 📤 Bouton d’envoi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (messageController.text.isEmpty) {
                      Get.snackbar(
                        'Attention',
                        "Veuillez entrer le motif.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    setState(() {
                      isValidated = true;
                    });
                    final orderItem = OrderModel(
                      orderId: generateOrderId(),
                      deliveryType: widget.packageType,
                      withdrawalPoint: widget.startLocation,
                      destinationLocation: widget.endLocation,
                      deliverLocation: PlaceLocation(
                        latitude: 0,
                        longitude: 0,
                        address: "",
                      ),
                      isDriverAssigned: false,
                      status: 'Canceled',
                      message: widget.message,
                      numeroWithdrawal: widget.numeroWithdrawal,
                      distance: _totalDistanceKm,
                      amount: _totalPrice,
                      purchasePrice: 0,
                      totalPrice: 0,
                      reasonForCancellation: messageController.text.trim(),
                      paymentStatus: 'Canceled',
                      createdAt: Timestamp.now(),
                    );

                    await FirebaseFirestore.instance
                        .collection('orders')
                        .add(orderItem.toJson());
                    TLoaders.successSnackBar(
                      title: 'Congratulations',
                      message: "tMessageCancelOrders".tr,
                    );
                    setState(() {
                      isValidated = false;
                    });

                    Get.offAll(() => const TabsScreen(initialIndex: 1));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorApp.tsecondaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("Envoyer"),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng companyLatLng = LatLng(
      widget.companyLocation.latitude,
      widget.companyLocation.longitude,
    );
    final LatLng startLatLng = LatLng(
      widget.startLocation.latitude,
      widget.startLocation.longitude,
    );
    final LatLng endLatLng = LatLng(
      widget.endLocation.latitude,
      widget.endLocation.longitude,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Trajet")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (companyLatLng.latitude +
                        startLatLng.latitude +
                        endLatLng.latitude) /
                    3,
                (companyLatLng.longitude +
                        startLatLng.longitude +
                        endLatLng.longitude) /
                    3,
              ),
              zoom: 11,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              Marker(
                markerId: const MarkerId("company"),
                position: companyLatLng,
                infoWindow: InfoWindow(
                  title: "Entreprise",
                  snippet: widget.companyLocation.address,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
              Marker(
                markerId: const MarkerId("start"),
                position: startLatLng,
                infoWindow: InfoWindow(
                  title: "Adresse de retrait",
                  snippet: widget.startLocation.address,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
              ),
              Marker(
                markerId: const MarkerId("end"),
                position: endLatLng,
                infoWindow: InfoWindow(
                  title: "Destination",
                  snippet: widget.endLocation.address,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId("route1"),
                color: Colors.red,
                width: 4,
                points: [companyLatLng, startLatLng],
              ),
              Polyline(
                polylineId: const PolylineId("route2"),
                color: Colors.red,
                width: 4,
                points: [startLatLng, endLatLng],
              ),
              Polyline(
                polylineId: const PolylineId("route3"),
                color: Colors.red,
                width: 4,
                points: [endLatLng, companyLatLng],
              ),
            },
          ),

          /// Bas de page avec distance, prix et boutons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _loadingPrice
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            Text(
                              "Distance : ${_totalDistanceKm.toStringAsFixed(2)} km",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Prix : ${_totalPrice.toStringAsFixed(2)} FCFA",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      isValidated
                          ? CircularProgressIndicator()
                          : Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () async {
                                  try {
                                    setState(() {
                                      isValidated = true;
                                    });
                                    print(widget.startLocation);
                                    print(widget.endLocation);
                                    final orderItem = OrderModel(
                                      orderId: generateOrderId(),
                                      deliveryType: widget.packageType,
                                      withdrawalPoint: widget.startLocation,
                                      destinationLocation: widget.endLocation,
                                      deliverLocation: PlaceLocation(
                                        latitude: 0.0,
                                        longitude: 0.0,
                                        address: "",
                                      ),
                                      userRef: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                          ),
                                      isDriverAssigned: false,
                                      status: 'NewOrder',
                                      message: widget.message,
                                      numeroWithdrawal: widget.numeroWithdrawal,
                                      distance: _totalDistanceKm,
                                      amount: _totalPrice,
                                      purchasePrice: 0,
                                      totalPrice: 0,
                                      reasonForCancellation: '',
                                      paymentStatus: 'Pending',
                                      createdAt: Timestamp.now(),
                                    );

                                    if (widget.orderId != "") {
                                      await FirebaseFirestore.instance
                                          .collection('orders')
                                          .doc(widget.orderId)
                                          .update(orderItem.toJson());

                                      final querySnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .where(
                                                'userRole',
                                                isEqualTo: "Super Admin",
                                              )
                                              .get();
                                      for (var doc in querySnapshot.docs) {
                                        final data = doc.data();
                                        final fcmToken = data['fcmToken'];
                                        NotificationServices().sendPushNotification(
                                          deviceToken: fcmToken,
                                          title: "Nouveau Message 👋",
                                          body:
                                              "Vous avez une nouvelle livraison de ${FirebaseAuth.instance.currentUser!.displayName}. Veuillez l'attribuer à un livreur.",
                                        );
                                      }
                                      setState(() {
                                        isValidated = false;
                                      });
                                      TLoaders.successSnackBar(
                                        title: 'Congratulations',
                                        message: "tMessageUpdOrders".tr,
                                      );
                                    } else {
                                      setState(() {
                                        isValidated = true;
                                      });
                                      await FirebaseFirestore.instance
                                          .collection('orders')
                                          .add(orderItem.toJson());
                                      final querySnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .where(
                                                'userRole',
                                                isEqualTo: "Super Admin",
                                              )
                                              .get();
                                      print(
                                        "################################### Ok #######################",
                                      );
                                      for (var doc in querySnapshot.docs) {
                                        final data = doc.data();
                                        final fcmToken = data['fcmToken'];
                                        print(fcmToken);

                                        if (fcmToken != null &&
                                            fcmToken.toString().isNotEmpty) {
                                          NotificationServices()
                                              .sendPushNotification(
                                                deviceToken: fcmToken,
                                                title: "Nouveau Message 👋",
                                                body:
                                                    "Vous avez une nouvelle livraison de . Veuillez l'attribuer à un livreur.",
                                              );
                                        }
                                      }
                                      TLoaders.successSnackBar(
                                        title: 'Congratulations',
                                        message: "tMessageAddOrders".tr,
                                      );
                                      setState(() {
                                        isValidated = false;
                                      });
                                    }
                                    Get.offAll(
                                      () => const TabsScreen(initialIndex: 1),
                                    );
                                  } catch (e) {
                                    print("$e.");
                                    Get.snackbar(
                                      'Attention',
                                      "$e.",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                    );
                                    setState(() {
                                      isValidated = false;
                                    });
                                    return;
                                  }
                                },
                                child: const Text("Continuer"),
                              ),
                            ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => showCancelModal(context),
                          child: const Text("Abandonner"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

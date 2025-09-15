import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:smart_service/src/constants/colors.dart';
import 'package:smart_service/src/models/order_model.dart';
import 'package:smart_service/src/screens/orders/location_input.dart';
import 'package:smart_service/src/screens/orders/route_map.dart';
import 'package:smart_service/src/utils/helpers/helper_function.dart';
import 'package:smart_service/src/utils/texts/button_custom.dart';
import 'package:smart_service/src/utils/texts/button_custom_outlined_icon.dart';
import 'package:smart_service/src/utils/texts/text_custom.dart';
import 'package:smart_service/src/utils/texts/text_form_field_simple_custom.dart';
import 'package:smart_service/src/utils/validators/validator.dart';

class FormOrderScreen extends StatefulWidget {
  const FormOrderScreen({super.key, this.orderId});
  final String? orderId;
  @override
  State<FormOrderScreen> createState() => _FormOrderScreenState();
}

class _FormOrderScreenState extends State<FormOrderScreen> {
  PlaceLocation? _selectedLocationStart;
  PlaceLocation? _selectedLocationEnd;
  final companyLocation = PlaceLocation(
    latitude: 6.378617299999999,
    longitude: 2.4122047,
    address: "Smart Services",
  );
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Map<String, String>> packages = [
    {"Food": 'Repas'},
    {"SuperMarket": 'SuperMarché ou Marché'},
    {"Package": 'Colis'},
    {"AdministrativeCourse": 'Course Administrative'},
  ];
  String? packageType;
  bool isValidated = false;
  final messageController = TextEditingController();
  final numeroWithdrawalController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            LineAwesomeIcons.angle_left_solid,
            color: THelperFunctions.isDarkMode(context)
                ? ColorApp.tWhiteColor
                : ColorApp.tBlackColor,
          ),
        ),
        title: TextCustom(TheText: "tTitle".tr, TheTextSize: 14),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextCustom(
                      TheText: "tStartAdresse".tr,
                      TheTextSize: 14,
                      TheTextFontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LocationInput(
                  onSelectedLocation: (value) {
                    _selectedLocationStart = value;
                    print(_selectedLocationStart!.address);
                    print(_selectedLocationStart!.latitude);
                    print(_selectedLocationStart!.longitude);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextCustom(
                      TheText: "tEndAdresse".tr,
                      TheTextSize: 14,
                      TheTextFontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LocationInput(
                  onSelectedLocation: (value) {
                    _selectedLocationEnd = value;
                    print(_selectedLocationEnd!.address);
                    print(_selectedLocationEnd!.latitude);
                    print(_selectedLocationEnd!.longitude);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextCustom(
                      TheText: "tPackageType".tr,
                      TheTextSize: 14,
                      TheTextFontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: THelperFunctions.isDarkMode(context)
                            ? ColorApp.tSombreColor
                            : ColorApp.tBlackColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: THelperFunctions.isDarkMode(context)
                            ? ColorApp.tSombreColor
                            : ColorApp.tBlackColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: THelperFunctions.isDarkMode(context)
                            ? ColorApp.tSombreColor
                            : ColorApp.tBlackColor,
                      ),
                    ),
                  ),
                  value: packageType,
                  hint: Text('tPackageType'.tr),
                  items: packages.map((value) {
                    String key = value.keys.first;
                    String valueText = value.values.first;
                    return DropdownMenuItem(child: Text(valueText), value: key);
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      packageType = value!;
                    });
                  },
                  validator: (value) =>
                      TValidator.validationEmptyText("tPackageType".tr, value),
                ),

                /* Type End */
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextCustom(
                      TheText: "tMessageToDeliver".tr,
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
                      : "tMessageToDeliver".tr,
                  labelStyleColor: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,
                  hintText: widget.orderId != null
                      ? messageController.text
                      : "tMessageToDeliver".tr,
                  hintStyleColor: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,

                  validator: (value) => TValidator.validationEmptyText(
                    "tMessageToDeliver".tr,
                    value,
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextCustom(
                      TheText: "tNumWithDrawal".tr,
                      TheTextSize: 14,
                      TheTextFontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormFieldSimpleCustom(
                  keyboardType: TextInputType.number,
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
                  controller: numeroWithdrawalController,
                  labelText: "tNumWithDrawalText".tr,
                  labelStyleColor: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,
                  hintText: "tNumWithDrawalText".tr,
                  hintStyleColor: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,
                  prefixIcon: Icon(
                    Icons.phone_android_outlined,
                    color: THelperFunctions.isDarkMode(context)
                        ? ColorApp.tWhiteColor
                        : ColorApp.tBlackColor,
                  ),
                  validator: (value) => TValidator.validationPhoneNumber(value),
                ),
                const SizedBox(height: 10),
                isValidated
                    ? CircularProgressIndicator(color: ColorApp.tPrimaryColor)
                    : ButtonCustom(
                        text: widget.orderId != null
                            ? "tUpdBtn".tr
                            : "tAddBtn".tr,
                        textSize: 15,
                        buttonBackgroundColor: ColorApp.tsecondaryColor,
                        onPressed: () async {
                          if (_selectedLocationStart == null) {
                            Get.snackbar(
                              'Attention',
                              "Veuillez selectionner l'adresse de départ.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          if (_selectedLocationEnd == null) {
                            Get.snackbar(
                              'Attention',
                              "Veuillez selectionner l'adresse de destination.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          if (widget.orderId == null) {
                            Get.to(
                              () => RouteMapScreen(
                                startLocation: _selectedLocationStart!,
                                endLocation: _selectedLocationEnd!,
                                companyLocation: companyLocation,
                                packageType: packageType!,
                                message: messageController.text.trim(),
                                numeroWithdrawal: int.parse(numeroWithdrawalController.text.trim()),
                              ),
                            );
                          } else {
                            Get.to(
                              () => RouteMapScreen(
                                startLocation: _selectedLocationStart!,
                                endLocation: _selectedLocationEnd!,
                                companyLocation: companyLocation,
                                packageType: packageType!,
                                message: messageController.text.trim(),
                                orderId: widget.orderId!,
                                numeroWithdrawal: int.parse(numeroWithdrawalController.text.trim()),
                              ),
                            );
                          }

                          /* setState(() {
                            isValidated = true;
                          });
                          if (!formKey.currentState!.validate()) {
                            setState(() {
                              isValidated = false;
                            });
                            return;
                          }
                          final carItem = CarModel(
                            ownerRef: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid),
                            brandRef: FirebaseFirestore.instance
                                .collection('brands')
                                .doc(selectedValue),
                            userCreatedRef: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid),
                            name: carNameController.text.trim(),
                            description: carDescriptionController.text.trim(),
                            carModal: carModalController.text.trim(),
                            carYear: carYearController.text.trim(),
                            carType: selectedType!,
                            number_of_places: int.parse(
                              carPlacesController.text.trim(),
                            ),
                            carAdresse: companyAdresse!,
                            carGearbox: selectedtGearbox!,
                            link: carImage!,
                            rating: int.parse(carRatingController.text.trim()),
                            isAvailable: true,
                            isAirConditioned: isAirConditioned,
                            pricePerDay: int.parse(
                              carLocationPriceController.text.trim(),
                            ),
                            images: carImageUrls,
                            location: companyLocation,
                            createdAt: DateTime.now(),
                          );
                          if (widget.carId != null) {
                            await firebase
                                .collection('cars')
                                .doc(widget.carId)
                                .update(carItem.toJson());
                            setState(() {
                              isValidated = false;
                            });
                            TLoaders.successSnackBar(
                              title: 'Congratulations',
                              message: "tMessageUpdCar".tr,
                            );
                          } else {
                            setState(() {
                              isValidated = true;
                            });
                            await firebase
                                .collection('cars')
                                .add(carItem.toJson());
                            TLoaders.successSnackBar(
                              title: 'Congratulations',
                              message: "tMessageAddCar".tr,
                            );
                            setState(() {
                              isValidated = false;
                            });
                          }
                          Get.offAll(() => const TabsScreen(initialIndex: 1)); */
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

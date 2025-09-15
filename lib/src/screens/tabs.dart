import 'package:smart_service/src/constants/colors.dart';
import 'package:smart_service/src/models/auth/notification_model.dart';
import 'package:smart_service/src/repository/authentification_repository.dart';
import 'package:smart_service/src/screens/chat/chat_list_screen.dart';
import 'package:smart_service/src/screens/drawer/drawer_listTile.dart';
import 'package:smart_service/src/screens/home_page/home.dart';
import 'package:smart_service/src/screens/home_page/profile.dart';
import 'package:smart_service/src/screens/notification.dart';
import 'package:smart_service/src/screens/orders/orders.dart';
import 'package:smart_service/src/utils/helpers/helper_function.dart';
import 'package:smart_service/src/utils/widget_theme/circle_icon_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'drawer/drawer_header.dart';
import 'package:smart_service/src/utils/texts/text_custom.dart';


class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  final controller = Get.put(TabsScreenController());

  Stream<int> getNotificationTotal(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where(
          'receiverRef',
          isEqualTo: FirebaseFirestore.instance.collection('users').doc(userId),
        )
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0;

          return snapshot.docs.length;
        });
  }

  @override
  Widget build(BuildContext context) {
    controller._selectedIndex.value = widget.initialIndex;
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(
              "Voulez-vous vraiment quitter SmartService ?",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Annuler"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Quitter"),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar:  AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: StreamBuilder(
                stream: getNotificationTotal(
                  FirebaseAuth.instance.currentUser!.uid,
                ),
                builder: (context, asyncSnapshot) {
                  if (!asyncSnapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return Badge.count(
                    count: asyncSnapshot.data!,
                    child: CircleIconCustom(
                      headerIcon1: Icons.notifications,
                      isDark: isDark,
                      onPressed: () async {
                        final notifications = await FirebaseFirestore.instance
                            .collection('notifications')
                            .where(
                              'receiverRef',
                              isEqualTo: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid),
                            )
                            .get();

                        for (final doc in notifications.docs) {
                          final data = NotificationModel.fromSnapshot(doc);
                          if (data.isRead == false) {
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .doc(doc.id)
                                .update({'isRead': true});
                          }
                        }
                        Get.to(() => NotificationScreen());
                      },
                    ),
                  );
                },
              ),
            ),
          ],
          title: Obx(() {
            final index = controller._selectedIndex.value;
            Widget title;

            switch (index) {
              case 0:
                title = Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    controller.profilePicture.value == ""
                        ? CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(
                              "assets/images/profile.jpg",
                            ),
                          )
                        : CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              controller.profilePicture.value!,
                            ),
                          ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        TextCustom(
                          TheText: "Salut, ${controller.userConnectName.value}",
                          TheTextSize: 14,
                          TheTextFontWeight: FontWeight.normal,
                        ),
                        SizedBox(height: 3,),
                        TextCustom(
                          TheText: "Cotonou",
                          TheTextSize: 14,
                          TheTextFontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                );
                break;
              case 1:
                title = TextCustom(TheText: 'Mes courses', TheTextSize: 13);
                break;
              case 2:
                title = TextCustom(
                  TheText: 'Listes de mes discussions',
                  TheTextSize: 13,
                );
                break;
              case 3:
                title = TextCustom(TheText: 'Mon Profile', TheTextSize: 13);
                break;
              default:
                title = TextCustom(TheText: 'TrouvMoi', TheTextSize: 13);
            }

            return title;
          }),
          iconTheme: Theme.of(context).iconTheme,
        ),
        body: Obx(() {
          if (controller.user.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return controller.screens[controller._selectedIndex.value];
        }),
        bottomNavigationBar: Obx(() {
          return BottomAppBar(
            color: isDark ? Colors.black : Colors.white,
            child: SizedBox(
              height: 56,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconBottomBar(
                      isDark: isDark,
                      Idark: "assets/home/home_dark.png",
                      Igreen: "assets/home/home_orange.png",
                      Ilight: "assets/home/home_light.png",
                      icon: Icons.feed,
                      selected: controller._selectedIndex.value == 0,
                      onPressed: () {
                        controller._selectedIndex.value = 0;
                      },
                    ),
                    IconBottomBar(
                      isDark: isDark,
                      Idark: "assets/home/order_dark.png",
                      Igreen: "assets/home/order_orange.png",
                      Ilight: "assets/home/order_light.png",
                      icon: Icons.local_grocery_store_outlined,
                      selected: controller._selectedIndex.value == 1,
                      onPressed: () {
                        controller._selectedIndex.value = 1;
                      },
                    ),
                    /* IconBottomBar(
                      isDark: isDark,
                      Idark: "assets/home/favorite_dark.png",
                      Igreen: "assets/home/favorite_orange.png",
                      Ilight: "assets/home/favorite_light.png",
                      icon: Icons.chat,
                      selected: controller._selectedIndex.value == 2,
                      onPressed: () {
                        controller._selectedIndex.value = 2;
                      },
                    ), */
                    IconBottomBar(
                      isDark: isDark,
                      Idark: "assets/home/chat_dark.png",
                      Igreen: "assets/home/chat_orange.png",
                      Ilight: "assets/home/chat_light.png",
                      icon: Icons.person_outline,
                      selected: controller._selectedIndex.value == 2,
                      onPressed: () {
                        controller._selectedIndex.value = 2;
                      },
                    ),
                    IconBottomBar(
                      isDark: isDark,
                      Idark: "assets/home/profile_dark.png",
                      Igreen: "assets/home/profile_orange.png",
                      Ilight: "assets/home/profile_light.png",
                      icon: Icons.person_outline,
                      selected: controller._selectedIndex.value == 3,
                      onPressed: () {
                        controller._selectedIndex.value = 3;
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        
        
        /* Container(
          decoration: BoxDecoration(
            color: THelperFunctions.isDarkMode(context)
                ? ColorApp.tBlackColor
                : ColorApp.tWhiteColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Theme.of(context).shadowColor.withOpacity(0.1),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 8,
              ),
              child: GNav(
                rippleColor: Theme.of(context).hoverColor,
                hoverColor: Theme.of(context).hoverColor,
                gap: 8,
                activeColor: Theme.of(context).colorScheme.onPrimary,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: Duration(milliseconds: 400),
                tabBackgroundColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).iconTheme.color,
                tabs: const [
                  GButton(icon: LineIcons.home, text: 'Home'),
                  GButton(icon: Icons.list_sharp, text: 'Courses'),
                  GButton(icon: LineIcons.comments, text: 'Chats'),
                  GButton(icon: LineIcons.user, text: 'Profile'),
                ],
                selectedIndex: controller._selectedIndex.value,
                onTabChange: (index) {
                  controller._selectedIndex.value = index;
                },
              ),
            ),
          ),
        ), */

        /*  drawer: Obx(() {
          if (controller.user.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Drawer(
            child: ListView(
              children: [
                DrawerHeaderCustom(
                  displayName: controller.user['fullName'],
                  email: controller.user['email'],
                  photo: controller.user['profilePicture'],
                ),
                DrawerListTile(
                  title: "Discussions",
                  titleColor: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,
                  icon: LineIcons.commentAlt,
                  iconColor: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,
                  onTap: () => Get.offAll(() => TabsScreen(initialIndex: 2)),
                ),
                DrawerListTile(
                  title: "Mes Marques",
                  titleColor: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,
                  icon: LineIcons.brush,
                  iconColor: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,
                  onTap: () => Get.offAll(() => BrandsScreen()),
                ),
                DrawerListTile(
                  title: "Mes véhicules",
                  titleColor: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,
                  icon: LineIcons.car,
                  iconColor: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,
                  onTap: () => Get.offAll(() => TabsScreen(initialIndex: 1)),
                ),
                Divider(
                  height: 18,
                  color: THelperFunctions.isDarkMode(context)
                      ? ColorApp.tWhiteColor
                      : ColorApp.tBlackColor,
                ),
              ],
            ),
          );
        }) */
      ),
    );

    /*  return  */
  }
}

class TabsScreenController extends GetxController {
  static TabsScreenController get to => Get.find();

  final _selectedIndex = 0.obs;
  final userConnectName = ''.obs;
  final profilePicture = ''.obs;
  final user = <String, dynamic>{}.obs;
  final auth = FirebaseAuth.instance.currentUser!;
  RxBool accountVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    _getUserInfo();
  }

  void _getUserInfo() async {
    final data = await AuthentificationRepository.instance.getUserInfo(
      auth.uid,
    );
    if (data.isNotEmpty) {
      user.value = data;
      userConnectName.value = data['fullName'];
      List<String> parts = userConnectName.value.trim().split(" ");

      // Récupérer le prénom (le deuxième mot s’il existe)
      userConnectName.value = parts.length >= 2 ? parts[1] : '';
      if (user['profilePicture'] == null) {
        profilePicture.value = '';
      }else{
        profilePicture.value = user['profilePicture'];
      }
    } else {
      print('No data');
    }
  }

  List<Widget> get screens => [
    HomeScreen(
      userFullName: user['fullName'],
      userEmail: user['email'],
    ),
    OrdersScreen(),
    ChatListScreen(),
    ProfileScreen(
      userFullName: user['fullName'],
      userEmail: user['email'],
    ),
  ];
}

class IconBottomBar extends StatelessWidget {
  const IconBottomBar({
    Key? key,
    required this.Idark,
    required this.Igreen,
    required this.Ilight,
    required this.icon,
    required this.selected,
    required this.onPressed,
    required this.isDark,
  }) : super(key: key);

  final String Idark;
  final String Igreen;
  final String Ilight;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final Function() onPressed;

  final primaryColor = const Color(0xff54b435);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isDark
              ? Container(
                  height: 25,
                  width: 25,
                  child: selected ? Image.asset(Igreen) : Image.asset(Ilight),
                )
              : Container(
                  height: 25,
                  width: 25,
                  child: selected ? Image.asset(Igreen) : Image.asset(Idark),
                ),
        ],
      ),
    );
  }
}


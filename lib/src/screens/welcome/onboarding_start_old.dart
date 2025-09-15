import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_service/src/constants/colors.dart';
import 'package:smart_service/src/screens/auth/login_screen.dart';
import 'package:smart_service/src/utils/texts/button_custom.dart';
import 'package:smart_service/src/utils/texts/text_custom.dart';

class OnboardingStartOldScreen extends StatefulWidget {
  @override
  _OnboardingStartOldScreenState createState() => _OnboardingStartOldScreenState();
}

class _OnboardingStartOldScreenState extends State<OnboardingStartOldScreen> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  // Les données des pages (titre + description + image)
  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/Image1.jpg',
      'title': 'Find Food You Love',
      'description':
          'Discover the best foods from over 1,000 \nrestaurants and fast delivery to your doorstep',
    },
    {
      'image': 'assets/Image2.jpg',
      'title': 'Fast Delivery',
      'description':
          'Fast food delivery to your home, office\n wherever you are',
    },
    {
      'image': 'assets/Live tracking vector.png',
      'title': 'Live Tracking',
      'description':
          'Real time tracking of your food on the app \nonce you placed the order',
    },
  ];

  List<Widget> _buildPageIndicator() {
    return List.generate(_numPages,
        (i) => i == _currentPage ? _indicator(true) : _indicator(false));
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 6.0),
      height: 6,
      width: isActive ? 20 : 8,
      decoration: BoxDecoration(
        color: isActive ? ColorApp.tPrimaryColor : Colors.white70,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // --- Arrière-plan avec PageView ---
            PageView.builder(
              physics: ClampingScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _numPages,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_pages[index]['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.5), // voile sombre
                  ),
                );
              },
            ),

            // --- Contenu superposé ---
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bouton Passer (en haut à droite)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_currentPage != _numPages - 1)
                          Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: ColorApp.tPrimaryColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: InkWell(
                              onTap: () {
                                _pageController.animateToPage(
                                  _numPages - 1,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              child: TextCustom(
                                TheText: 'Passer',
                                TheTextSize: 13,
                                TheTextColor: ColorApp.tWhiteColor,
                                TheTextFontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    Spacer(),

                    // Titre et description (au centre)
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(
                        child: Column(
                          children: [
                            TextCustom(
                              TheText: _pages[_currentPage]['title']!,
                              TheTextSize: 22,
                              TheTextFontWeight: FontWeight.bold,
                              TheTextColor: Colors.white,
                            ),
                            SizedBox(height: 15.0),
                            TextCustom(
                              TheText: _pages[_currentPage]['description']!,
                              TheTextSize: 16,
                              TheTextColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Spacer(),

                    // Indicateurs et bouton (en bas)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                    SizedBox(height: 20),

                    ButtonCustom(
                      onPressed: () {
                        if (_currentPage == _numPages - 1) {
                          Get.to(() => LoginScreen());
                        } else {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        }
                      },
                      text: _currentPage != _numPages - 1 ? 'Suivant' : 'Commencer',
                      textSize: 14,
                      buttonBackgroundColor: ColorApp.tPrimaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

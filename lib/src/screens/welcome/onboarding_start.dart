import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_service/src/constants/colors.dart';
import 'package:smart_service/src/screens/auth/login_screen.dart';
import 'package:smart_service/src/utils/texts/button_custom.dart';
import 'package:smart_service/src/utils/texts/text_custom.dart';

class OnboardingStartScreen extends StatefulWidget {
  @override
  _OnboardingStartScreenState createState() => _OnboardingStartScreenState();
}

class _OnboardingStartScreenState extends State<OnboardingStartScreen> {
  final int _numPages = 4;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 5,
      width: isActive ? 10 : 5,
      decoration: BoxDecoration(
        color: isActive ? ColorApp.tPrimaryColor : Color(0xffD6D6D6),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Container(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentPage != _numPages - 1)
                        Container(
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(10),
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
                      if (_currentPage == _numPages - 1) SizedBox(height: 60),
                    ],
                  ),
                  Container(
                    height: 550.0,
                    child: PageView(
                      physics: ClampingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Image(
                                  image: AssetImage('assets/Img1.jpg'),
                                  height: 300.0,
                                  width: 300.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 80.0),
                              TextCustom(
                                TheText: 'Livrez tout, partout',
                                TheTextSize: 16,
                                TheTextFontWeight: FontWeight.bold,
                              ),

                              SizedBox(height: 15.0),
                              TextCustom(
                                TheText:
                                    'Des colis aux repas, SmartServices vous accompagne partout',
                                TheTextSize: 14,
                                TheTextMaxLines: 2,
                                TheTextAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Image(
                                  image: AssetImage('assets/Image3.jpg'),
                                  height: 300.0,
                                  width: 300.0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 80.0),
                              TextCustom(
                                TheText: 'Un suivi en direct',
                                TheTextSize: 15,
                                TheTextFontWeight: FontWeight.bold,
                              ),

                              SizedBox(height: 15.0),
                              TextCustom(
                                TheText:
                                    'Gardez un œil sur votre livraison à chaque instant.',
                                TheTextSize: 14,
                                TheTextMaxLines: 2,
                                TheTextAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Image(
                                  image: AssetImage('assets/Image1.jpg'),
                                  height: 300.0,
                                  width: 300.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 80.0),
                              TextCustom(
                                TheText: 'Vos courses en un clic',
                                TheTextSize: 15,
                                TheTextFontWeight: FontWeight.bold,
                              ),

                              SizedBox(height: 15.0),
                              TextCustom(
                                TheText:
                                    'Faites vos achats au marché ou au supermarché sans vous déplacer',
                                TheTextSize: 14,
                                TheTextMaxLines: 2,
                                TheTextAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Image(
                                  image: AssetImage('assets/Image4.jpg'),
                                  height: 300.0,
                                  width: 300.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 80.0),
                              TextCustom(
                                TheText: 'SmartServices, partout avec vous',
                                TheTextSize: 15,
                                TheTextFontWeight: FontWeight.bold,
                              ),

                              SizedBox(height: 15.0),
                              TextCustom(
                                TheText:
                                    'Une seule application pour tout livrer, simplement.',
                                TheTextSize: 14,
                                TheTextMaxLines: 2,
                                TheTextAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),
                  SizedBox(height: 15.0),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ButtonCustom(
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
                      text: _currentPage != _numPages - 1
                          ? 'Suivant'
                          : 'Commencer',
                      textSize: 12,
                      buttonBackgroundColor: ColorApp.tPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import "package:church_stream/routes/auth.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:lottie/lottie.dart";
import 'package:google_fonts/google_fonts.dart';
import "package:smooth_page_indicator/smooth_page_indicator.dart";


/**
 * Attributes
 * <a href="https://storyset.com/internet">Internet illustrations by Storyset</a>
 * <a href="https://storyset.com/technology">Technology illustrations by Storyset</a>
 */

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>{

  final displayOneText = "CHURCHFORUS";
  final displayTwoText = "Busy? Tune in the sermon from anywhere and never miss a message from the word of God.";
  final displayThreeText = "Host meetings in the app";
  final displayFourText = "Rewatch meetings and church streams anytime, anywhere.";
  final displayFiveText = "Let's get started!";
  late List<Widget> onBoardingItems;
  int index = 0;
  bool isLastPage = false;

  final pageController = PageController(
    initialPage: 0
  );

  @override
  void initState() {
    onBoardingItems = [
      display_one(),
      display_two(),
      display_three(),
      display_four(),
      display_five()
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  isLastPage = index == 4;
                });
              },
              children: onBoardingItems,
            ), 
          ),

          Expanded(
            child: (isLastPage) ?
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 138, 126, 20),
                      foregroundColor: Colors.white,
                      shape: StadiumBorder()
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Authentication()));
                    }, 
                    child: const Text("Get Started", style: TextStyle(fontSize: 23, letterSpacing: 1.5),)
                  ),
                ),
              )
              :
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  TextButton(
                    onPressed: () {
                      pageController.jumpToPage(4);
                    }, child: const Text("Skip", style: TextStyle(fontSize: 20, color: Colors.amberAccent),)
                  ),

                  SmoothPageIndicator(
                    controller: pageController, 
                    count: onBoardingItems.length,
                    effect: const WormEffect(activeDotColor: Colors.amberAccent, type: WormType.thin),
                    onDotClicked: (doubleindex) {
                      pageController.animateToPage(
                        index, 
                        duration: const Duration(milliseconds: 500), 
                        curve: Curves.bounceIn
                      );
                    },
                  ),

                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        
                      ),
                      onPressed: () {
                        pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.bounceIn);
                      }, 
                      
                      child: const Icon(Icons.arrow_forward, color: Colors.white,)),
                  )

                ],
              )
          )
          
        ],
      )
    );
  }


    Container display_one() {
      return Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
              Lottie.asset("assets/animated_church.json", height: 350),
              const SizedBox(height: 20,),
              Text(displayOneText, style: GoogleFonts.mulish(textStyle: const TextStyle(fontSize: 40)),)
            ],
          ),
        ),
      );
    }

    Container display_two() {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/lady_watching_stream.svg", height: 350),
            const SizedBox(height: 30,),
            Text(displayTwoText, textAlign: TextAlign.center,style: const TextStyle(fontSize: 23, ),)
          ],
        ),
      );
    }

    Container display_three() {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset("assets/online_meet.json", height: 350),
            const SizedBox(height: 30,),
            Text(displayThreeText, textAlign: TextAlign.center,style: const TextStyle(fontSize: 23),)
          ],
        ),
      );
    }

    Container display_four() {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/rewatch.svg", height: 350,),
            const SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(displayFourText, textAlign: TextAlign.center,style: const TextStyle(fontSize: 23),),
            )
          ],
        ),
      );
    }


    Container display_five() {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/get_started.svg", height: 350,),
            const SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(displayFiveText, textAlign: TextAlign.center,style: const TextStyle(fontSize: 40),),
            )
          ],
        ),
      );
    }
}
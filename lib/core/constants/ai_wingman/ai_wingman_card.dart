import 'package:flutter/material.dart';
import '../../../features/ai_wingman/wingman_screen.dart';
import '../../widgets/costume_text/costume_text_widget.dart';

class AiWingmanCard extends StatefulWidget {
  const AiWingmanCard({super.key});

  @override
  State<AiWingmanCard> createState() => _AiWingmanCardState();
}

class _AiWingmanCardState extends State<AiWingmanCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 150,
        width: double.infinity,
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => WingmanScreen()));
          },
          child: Card(
            color: Colors.pink.withOpacity(0.2),
            child: Stack(
              children: [
                 Padding(
                   padding: const EdgeInsets.only(top: 5, left: 5),
                   child: Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(15),
                       color: Colors.white.withOpacity(0.4),
                       border: Border.all(
                         width: 1,
                         color: Colors.white,
                       ),
                     ),
                     // ----------------------------------------------- New AI WINGMAN -----------------------------------------------
                     child: const Padding(
                       padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                       child: Text(
                         "New AI WINGMAN",
                         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                       ),
                     ),
                   ),
                 ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: Column(
                    children: [
                      CostumeTextWidget(
                        text: " Stuck on What to Say?",
                        color: Colors.white,
                        size: 20,
                        fontWeight: FontWeight.bold,
                      ),

                      CostumeTextWidget(
                        text: "2 free generations no Login",
                        color: Colors.white,
                        size: 15,
                      ),
                      SizedBox(
                        width: 200,
                        child: Card(
                          color: Colors.yellow,
                          child: Center(
                            child: CostumeTextWidget(
                              text: " Start Flirting Smarter",
                              color: Colors.black,
                              size: 10,
                              fontWeight: FontWeight.bold,
                              padding: EdgeInsets.symmetric(vertical: 5),
                            ),
                          ),

                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

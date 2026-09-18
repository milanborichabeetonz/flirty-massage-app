import 'package:carousel_slider/carousel_slider.dart';
import 'package:flirtymessages/core/widgets/header_icon_button.dart';
import 'package:flirtymessages/features/favorite/favorite_screen.dart';
import 'package:flutter/material.dart';

import '../../network/services/pickup_line_service.dart';

class PickupLineCard extends StatefulWidget {

  const PickupLineCard({
    super.key,
  });

  @override
  State<PickupLineCard> createState() => _PickupLineCardState();
}

class _PickupLineCardState extends State<PickupLineCard> {

  final PickupLineService service = PickupLineService();



  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 200,
        width: double.infinity,

        child: FutureBuilder(
          future: service.fetchPickUpLines(),
          builder: (context, snapshot) {
            //---------------------------  waiting ----------------------
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ----------------------------- error ------------------------
            if (snapshot.hasError) {
              return Center(child: Text('error : ${snapshot.error}'));
            }
            // ------------------------ has data ---------------------------

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No Category Found"));
            }
            //--------------------------------------------------------

            final pickUpLines = snapshot.data!;
            // ------------------------------------------------------------------------ PageView Builder ----------------------------------------------------

            return CarouselSlider.builder(
              itemCount: pickUpLines.length,
              itemBuilder: (context, index, realIndex) {
                final pickUpLine = pickUpLines[index];

                return Card(
                  elevation: 5,
                  color: Colors.blue,
                  child: Stack(
                    children: [
                      // ------------------------------------- image ----------------------------------------------------
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'https://cdn.pixabay.com/photo/2018/01/14/23/12/nature-3082832_1280.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // --------------------------------------- title -------------------------------------------
                      Card(
                        color: Colors.black45,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("pickup Line of the day",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                        ),
                      ),
                      // --------------------------------------- title -------------------------------------------
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            pickUpLine.text,
                            style: TextStyle(color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,),
                          ),
                        ),
                      ),

                      //-------------------------------------- buttons (Like Edite and Share) -----------------------
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Row(
                          children: [
                            // ----------------- like ----------------------
                            HeaderIconButton(
                              icon: Icons.favorite_border,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoriteScreen(),
                                  ),
                                );
                              },
                              iconColor: Colors.white,
                            ),

                            // ----------------- edite ----------------------
                            HeaderIconButton(
                              icon: Icons.mode_edit_outlined,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoriteScreen(),
                                  ),
                                );
                              },
                              iconColor: Colors.white,
                            ),
                            // ----------------- share ----------------------
                            HeaderIconButton(
                              icon: Icons.share_outlined,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FavoriteScreen(),
                                  ),
                                );
                              },
                              iconColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              options: CarouselOptions(
                height: 200,
                viewportFraction: 0.85,
               // enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(
                  milliseconds: 800,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


import 'package:flirtymessages/core/widgets/header_icon_button.dart';
import 'package:flirtymessages/features/favorite/favorite_screen.dart';
import 'package:flutter/material.dart';

import '../../network/services/pickup_line_service.dart';

class PickupLineCard extends StatelessWidget {

  // final List<PickUpLineModel> pickUpLine;
  final List pickUpLine;
  final PickupLineService service = PickupLineService();

  const PickupLineCard({super.key,
        required this.pickUpLine,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 200,
        width: double.infinity,
        // ------------------------------------------------------------------------ PageView Builder ----------------------------------------------------
        child: PageView.builder(
          itemCount: pickUpLine.length,
          itemBuilder: (context, index) {

            // make variable for access pickUpLine list index vise
            final item = pickUpLine[index];

            return Card(
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("pickup Line of the day"),
                    ),
                  ),
                  // --------------------------------------- title -------------------------------------------
                  Center(
                    child: Text(

                      style: TextStyle(color: Colors.white),
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
        ),
      ),
    );
  }
}

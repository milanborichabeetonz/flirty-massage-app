import 'package:flirtymessages/core/widgets/pickup_line/pickup_line_card.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/header_icon_button.dart';
import '../../favorite/favorite_screen.dart';
import '../../premium/premium_screen.dart';
import '../../setting/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text("pickup lines"),
        actions: [
          Row(
            children: [
              // ------------------------ favorite iconButton ------------------------------------- //
              HeaderIconButton(
                icon: Icons.favorite_border,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: ((context) => FavoriteScreen())),
                  );
                },
                iconColor: Colors.white,
              ),

              // ------------------------ premium iconButton ------------------------------------- //
              HeaderIconButton(
                icon: Icons.workspace_premium,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: ((context) => PremiumScreen())),
                  );
                },
                iconColor: Colors.yellowAccent,
              ),
              // ------------------------ setting iconButton ------------------------------------- //
              HeaderIconButton(
                icon: Icons.settings,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: ((context) => SettingScreen())),
                  );
                },
                iconColor: Colors.white,
              ),
              SizedBox(width: 20),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(2),
          child: Column(
            children: [
                 SizedBox(
                   height: 200,
                     width: double.infinity,
                     child: PickupLineCard()
                 ),
              ],
          ),
        ),
      ),
    );
  }
}

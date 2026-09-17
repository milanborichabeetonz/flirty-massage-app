import 'package:flutter/material.dart';
import '../../../core/constants/ai_wingman/ai_wingman_card.dart';
import '../../../core/constants/category/all_category_tabs.dart';
import '../../../core/constants/pickup_line/pickup_line_card.dart';
import '../../../core/constants/quick_use_widget/quick_use_button.dart';
import '../../../core/widgets/costume_text/costume_text_widget.dart';
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
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
                   // ------------------------------------------- PickupLineCard ----------------------------------------
                 SizedBox(
                   height: 200,
                     width: double.infinity,
                     child:
                     PickupLineCard() // pickup line
                 ),
                 SizedBox(height: 10,),
                  //------------------------------------------ AiWingmanCard -------------------------------------------------------
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: AiWingmanCard(),
                  ),
                  //---------------------------------------------- Quick use --------------------------------------------
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15)
                ),
                child: QuickUseButton(),
              ),
              //-------------------------------------------------------- Category -------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CostumeTextWidget(text: 'Category', color: Colors.black, size: 20,),
                    IconButton(onPressed: (){}, icon: Icon(Icons.search_rounded))
                  ],
                ),
              ),
              // --------------------------------------  show all  category ------------------------------------
              Expanded(child: AllCategoryTabs())
              ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){},child: Icon(Icons.edit_note),),
    );
  }
}

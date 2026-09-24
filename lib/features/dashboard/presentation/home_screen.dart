import 'package:flutter/material.dart';

import '../../../core/constants/ai_wingman/ai_wingman_card.dart';
import '../../../core/constants/category/all_category_tabs.dart';
import '../../../core/constants/pickup_line/pickup_line_card.dart';
import '../../../core/constants/quick_use_widget/quick_use_button.dart';
import '../../../core/network/models/pickup_line_model.dart';
import '../../../core/network/services/pickup_line_service.dart';
import '../../../core/widgets/costume_text/costume_text_widget.dart';
import '../../../core/widgets/header_icon_button.dart';
import '../../category/category_detail_screen.dart';
import '../../category/category_search_screen.dart';
import '../../favorite/favorite_screen.dart';
import '../../pickup_line/pickup_line_maker_screen.dart';
import '../../premium/premium_screen.dart';
import '../../setting/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PickupLineService _pickupLineService = PickupLineService();
  late Future<List<PickupLineModel>> _pickupLinesFuture;

  @override
  void initState() {
    super.initState();
    _pickupLinesFuture = _pickupLineService.fetchPickUpLines();
  }

  Future<void> _openCategorySearch() async {
    try {
      final pickupLines = await _pickupLinesFuture;
      if (!mounted) return;

      final selectedCategory = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => CategorySearchScreen(pickupLines: pickupLines),
        ),
      );

      if (!mounted || selectedCategory == null || selectedCategory.isEmpty) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryDetailScreen(
            initialCategory: selectedCategory,
            pickupLines: pickupLines,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to open search.\n$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text("pickup lines"),
        actions: [
          Row(
            children: [
              // ------------------------ favorite iconButton ------------------------------------- //
              HeaderIconButton(
                icon: Icons.favorite_border,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: ((context) => const FavoriteScreen())),
                  );
                },
                iconColor: Colors.white,
              ),

              // ------------------------ premium iconButton ------------------------------------- //
              HeaderIconButton(
                icon: Icons.workspace_premium,
                onPressed: () => showPremiumDialog(context),
                iconColor: Colors.yellowAccent,
              ),
              // ------------------------ setting iconButton ------------------------------------- //
              HeaderIconButton(
                icon: Icons.settings,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: ((context) => const SettingScreen())),
                  );
                },
                iconColor: Colors.white,
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------- PickupLineCard ----------------------------------------
              const SizedBox(
                height: 200,
                width: double.infinity,
                child: PickupLineCard(), // pickup line
              ),
              const SizedBox(height: 10),

              //------------------------------------------ AiWingmanCard -------------------------------------------------------
              const SizedBox(
                height: 150,
                width: double.infinity,
                child: AiWingmanCard(),
              ),
              const SizedBox(height: 10),

              //---------------------------------------------- Quick use --------------------------------------------
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const QuickUseButton(),
              ),
              const SizedBox(height: 10),

              //-------------------------------------------------------- Category -------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CostumeTextWidget(
                      text: 'Category',
                      color: Colors.black,
                      size: 20,
                    ),
                    IconButton(
                      onPressed: _openCategorySearch,
                      icon: const Icon(Icons.search_rounded),
                    ),
                  ],
                ),
              ),

              // --------------------------------------  show all category ------------------------------------
              FutureBuilder<List<PickupLineModel>>(
                future: _pickupLinesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 110,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 110,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Unable to load categories.'),
                            const SizedBox(height: 6),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _pickupLinesFuture = _pickupLineService
                                      .fetchPickUpLines();
                                });
                              },
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final pickupLines =
                      snapshot.data ?? const <PickupLineModel>[];
                  return AllCategoryTabs(pickupLines: pickupLines);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PickupLineMakerScreen()),
          );
        },
        child: const Icon(Icons.edit_note),
      ),
    );
  }
}

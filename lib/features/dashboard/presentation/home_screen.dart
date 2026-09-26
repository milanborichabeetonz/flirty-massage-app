import 'package:flutter/material.dart';

import '../../../core/constants/ai_wingman/ai_wingman_card.dart';
import '../../../core/constants/category/all_category_tabs.dart';
import '../../../core/constants/pickup_line/pickup_line_card.dart';
import '../../../core/constants/quick_use_widget/quick_use_button.dart';
import '../../../core/network/models/pickup_line_model.dart';
import '../../../core/network/services/pickup_line_service.dart';
import '../../../core/widgets/costume_text/costume_text_widget.dart';
import '../../../core/widgets/header_icon_button.dart';
import '../../category/category_search_screen.dart';
import '../../category/category_unified_screen.dart';
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
          builder: (context) => CategoryUnifiedScreen(
            category: selectedCategory,
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        title: const Text(
          "Pickup Lines",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
              const SizedBox(width: 14),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------- PickupLineCard ----------------------------------------
              const SizedBox(
                height: 200,
                width: double.infinity,
                child: PickupLineCard(), // pickup line
              ),
              const SizedBox(height: 14),

              //------------------------------------------ AiWingmanCard -------------------------------------------------------
              const SizedBox(
                height: 140,
                width: double.infinity,
                child: AiWingmanCard(),
              ),
              const SizedBox(height: 14),

              //---------------------------------------------- Quick use --------------------------------------------
              const SizedBox(
                width: double.infinity,
                child: QuickUseButton(),
              ),
              const SizedBox(height: 14),

              //-------------------------------------------------------- Category -------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CostumeTextWidget(
                    text: 'Categories',
                    color: Color(0xFF1F2937),
                    size: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  IconButton(
                    onPressed: _openCategorySearch,
                    icon: const Icon(Icons.search_rounded, color: Color(0xFF4B5563)),
                    tooltip: 'Search Categories',
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // --------------------------------------  show all category ------------------------------------
              FutureBuilder<List<PickupLineModel>>(
                future: _pickupLinesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 110,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 110,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Unable to load categories.',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                foregroundColor: Colors.white,
                              ),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        tooltip: 'Pickup Line Maker',
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PickupLineMakerScreen()),
          );
        },
        child: const Icon(Icons.edit_note, size: 28),
      ),
    );
  }
}

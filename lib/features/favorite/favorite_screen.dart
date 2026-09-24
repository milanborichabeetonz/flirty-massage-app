import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/pickup_line/pickup_line_card.dart';
import '../../core/controllers/favorite_controller.dart';
import '../../core/network/models/pickup_line_model.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
      ),
      body: Obx(() {
        final controller = FavoriteController.to;
        final pickupFavs =
            controller.favorites.where((f) => f.type != 'dating_tip').toList();

        if (pickupFavs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favourites yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap ❤️ on any pickup line to save it here.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final pickupLines = pickupFavs
            .map((f) => PickupLineModel(text: f.text, category: f.category))
            .toList();

        return PickupLineCard(
          pickupLines: pickupLines,
          mode: PickupLineCardMode.list,
          emptyMessage: 'No favourites yet.',
        );
      }),
    );
  }
}

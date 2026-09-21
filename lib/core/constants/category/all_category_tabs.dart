import 'package:flutter/material.dart';

import '../../network/services/pickup_line_service.dart';
import '../../widgets/costume_text/costume_text_widget.dart';

class AllCategoryTabs extends StatefulWidget {
  const AllCategoryTabs({super.key});

  @override
  State<AllCategoryTabs> createState() => _AllCategoryTabsState();
}

class _AllCategoryTabsState extends State<AllCategoryTabs> {
  final PickupLineService service = PickupLineService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: service.fetchPickUpLines(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 3. No data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Category Found'));
          }

          // 4. API data
          final categories = snapshot.data!;

          // 5. Grid
          return GridView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 2,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Card(
                        child: Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSR-zKqJ2lQvA78r2LN42PqAMHvyefdpXowu6QO-CcheQ&s=10',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  CostumeTextWidget(
                    text: category.category,
                    color: Colors.black,
                    size: 10,
                    fontWeight: FontWeight.normal,
                  ),
                ]
              );
            },
          );
        },
      ),
    );
  }
}

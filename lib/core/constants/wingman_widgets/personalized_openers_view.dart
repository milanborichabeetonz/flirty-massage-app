import 'package:flirtymessages/core/widgets/costume_card/costume_card_widget.dart';
import 'package:flirtymessages/core/widgets/costume_text/costume_text_widget.dart';
import 'package:flirtymessages/core/widgets/custom_button_widget.dart';
import 'package:flirtymessages/core/widgets/pick_tone_card_widget.dart';
import 'package:flutter/material.dart';

class PersonalizedOpenersView extends StatefulWidget {
  const PersonalizedOpenersView({super.key});

  @override
  State<PersonalizedOpenersView> createState() =>
      _PersonalizedOpenersViewState();
}

class _PersonalizedOpenersViewState extends State<PersonalizedOpenersView> {
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.pinkAccent.withOpacity(0.2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              /// -------------------
              children: [
                CostumeCardWidget(
                  color: Colors.white,
                  elevation: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CostumeTextWidget(
                        text: "Who are you messaging?",
                        color: Colors.black,
                        size: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Enter their name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      CostumeTextWidget(
                        text: " Quick Suggestion",
                        color: Colors.lightBlueAccent.withOpacity(0.5),
                        size: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "emily",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Sophia",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Ava",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Isabella",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            
                SizedBox(height: 20),
                CostumeCardWidget(
                  color: Colors.white,
                  elevation: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CostumeTextWidget(
                        text: "What are they into?",
                        color: Colors.black,
                        size: 15,
                        fontWeight: FontWeight.bold,
                      ),
            
                      const SizedBox(height: 10),
            
                      // Suggestion buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Travel",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
            
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Gym",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
            
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Coffee",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
            
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Music",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
            
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Anime",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
            
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Fashion",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
            
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Gaming",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
            
                          CustomButtonWidget(
                            onPressed: () {},
                            child: CostumeTextWidget(
                              text: "Pets",
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ],
                      ),
            
                      const SizedBox(height: 15),
            
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: TextField(
                          maxLines: 4,
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Or type interests(e.g., hiking,cooking)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            
                CostumeCardWidget(
                  color: Colors.white,
                  elevation: 10,
                  child: Column(
                    children: [
                      CostumeTextWidget(
                        text: "Pick the tone",
                        color: Colors.black,
                        size: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    Row(
                        children: [
                          PickToneCardWidget(
                            icon: Icons.favorite,
                            text: 'Playful & charming',
                            titleText: 'Flirty',
                          ),
                          PickToneCardWidget(
                            icon: Icons.favorite_outline,
                            text: 'Sweet & heartfelt',
                            titleText: 'Romantic',
                          ),
                        ],
                    ),
                      Row(
                        children: [
                          PickToneCardWidget(
                            icon: Icons.face,
                            text: 'Witty & light',
                            titleText: 'Funny',
                          ),
                          PickToneCardWidget(
                            icon: Icons.edit,
                            text: 'Bold & assured',
                            titleText: 'Confident',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          PickToneCardWidget(
                            icon: Icons.fireplace,
                            text: 'Direct & daring',
                            titleText: 'Bold',
                          ),
                          PickToneCardWidget(
                            icon: Icons.dark_mode,
                            text: 'Gentle & warm',
                            titleText: 'Soft',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                CustomButtonWidget(onPressed: (){},
                    backgroundColor: Colors.blue,
                    child: CostumeTextWidget(
                  text: "Generate My Opener",
                  color: Colors.white, size: 15,
                  fontWeight: FontWeight.bold,)
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

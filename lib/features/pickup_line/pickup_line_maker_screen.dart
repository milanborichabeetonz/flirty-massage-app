import 'package:flirtymessages/core/widgets/costume_text/costume_text_widget.dart';
import 'package:flirtymessages/core/widgets/custom_button_widget.dart';
import 'package:flirtymessages/core/widgets/edit_text_botton_widget.dart';
import 'package:flutter/material.dart';

import '../../core/constants/line_text_maker_widget/pickup_line_preview_widget.dart';

class PickupLineMakerScreen extends StatefulWidget {
  const PickupLineMakerScreen({super.key});

  @override
  State<PickupLineMakerScreen> createState() => _PickupLineMakerScreenState();
}

class _PickupLineMakerScreenState extends State<PickupLineMakerScreen> {
  //  for text size -----
  double fontSize = 45;
  double vSpacing = 20;
  double textSpacing = 10;



  Color selectedColor = Colors.white;

  final List<Color> bgColor = [
    Colors.white,
    Colors.white,
    Colors.pink.shade100,
    Colors.purple.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.amber.shade100,
    Colors.red.shade100,
    Colors.teal.shade100,
    Colors.black87,
  ];
  // pickup Line Background --------------------------------------------------------------
  void _openBackgroundBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 500,
            width: double.infinity,
            child: Column(
              children: [
                // Text
                CostumeTextWidget(
                  text: "choose Background",
                  color: Colors.black,
                  size: 15,
                ),
                const SizedBox(height: 15),
                // colors option
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: bgColor.length,
                    itemBuilder: (context, index) {
                      final color = bgColor[index];
                      return GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedColor = color;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                        decoration: BoxDecoration(
                            color: color,
                          borderRadius: BorderRadius.circular(15)
                        ),),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // Pickup Line Text Size ---------------------------------------------------------------
  void _openTextSizeBottomSheet(){
    showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(40),
              topLeft: Radius.circular(20)
          ),
          color: Colors.white,
        ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: (){}, child: Icon(Icons.close,size: 30,)),
                  CostumeTextWidget(text: "Text Size", color: Colors.black, size: 15),
                  TextButton(onPressed: (){}, child: Icon(Icons.check,size: 30,)),                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.text_fields,size: 30,),
                  Slider(value: fontSize,
                      min: 10,
                      max: 80,
                      onChanged: (value){
                    setState(() {
                      fontSize = value;
                    });
                  }),
                  CostumeTextWidget(text: fontSize.toString(), color: Colors.black, size: 15)
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.format_line_spacing,size: 30,),
                  Slider(value: fontSize,
                      min: 10,
                      max: 80,
                      onChanged: (value){
                        setState(() {
                          fontSize = value;
                        });
                      }),
                  CostumeTextWidget(text: vSpacing.toString(), color: Colors.black, size: 15)
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.space_bar,size: 30,),
                  Slider(value: fontSize,
                      min: 10,
                      max: 80,
                      onChanged: (value){
                        setState(() {
                          fontSize = value;
                        });
                      }),
                  CostumeTextWidget(text: textSpacing.toString(), color: Colors.black, size: 15)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButtonWidget(onPressed: (){}, child: Icon(Icons.format_bold,size: 30,)),
                  CustomButtonWidget(onPressed: (){}, child: Icon(Icons.format_italic,size: 30,)),
                  CustomButtonWidget(onPressed: (){}, child: Icon(Icons.format_underline,size: 30,)),
                  CustomButtonWidget(onPressed: (){}, child: Icon(Icons.abc,size: 30,)),
                  CustomButtonWidget(onPressed: (){}, child: Icon(Icons.format_align_center,size: 30,)),
                ],
              )
            ],
          ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pickup Line Maker"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.download, size: 30),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // preview screen ------------------
            Expanded(
              child: PickupLinePreviewWidget(
                 backgroundColor: selectedColor, // selected background color
              ),
            ),
            // Editor tool --------------------
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    EditTextBottonWidget(
                      icon: Icons.format_color_fill,
                      text: 'Background',
                      onTap: () {
                        _openBackgroundBottomSheet(
                        );
                      },
                    ),
                    EditTextBottonWidget(icon: Icons.text_fields, text: "Size",
                    onTap: (){
                      setState(() {
                        _openTextSizeBottomSheet();
                      });
                    },),
                    EditTextBottonWidget(icon: Icons.text_format, text: "Font"),
                    EditTextBottonWidget(
                      icon: Icons.color_lens_outlined,
                      text: "Color",
                    ),
                    EditTextBottonWidget(
                      icon: Icons.border_style,
                      text: "Border",
                    ),
                    EditTextBottonWidget(icon: Icons.wb_shade, text: "Shadow"),
                    EditTextBottonWidget(
                      icon: Icons.gradient,
                      text: "Gradient",
                    ),
                    EditTextBottonWidget(icon: Icons.opacity, text: "Opacity"),
                    EditTextBottonWidget(icon: Icons.padding, text: "Padding"),
                    EditTextBottonWidget(icon: Icons.crop, text: "Crop"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

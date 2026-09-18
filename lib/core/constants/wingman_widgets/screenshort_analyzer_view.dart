import 'dart:typed_data';

import 'package:flirtymessages/core/widgets/costume_card/costume_card_widget.dart';
import 'package:flirtymessages/core/widgets/costume_text/costume_text_widget.dart';
import 'package:flutter/material.dart';

class ScreenshortAnalyzerView extends StatefulWidget {
  const ScreenshortAnalyzerView({super.key});

  @override
  State<ScreenshortAnalyzerView> createState() =>
      _ScreenshortAnalyzerViewState();
}

class _ScreenshortAnalyzerViewState extends State<ScreenshortAnalyzerView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 300,
        width: 260,
        child: CostumeCardWidget( // small
          color: Colors.white,
          elevation: 5,
          child: Column(
            children: [
              //------------------- text ----------------------------------
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Card(
                      child: Icon(
                        Icons.file_upload_outlined,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Column(
                      children: [
                        CostumeTextWidget(text: "Upload Screenshort", color: Colors.black, size: 13, fontWeight: FontWeight.bold,),
                        CostumeTextWidget(text: "PNG, JPG up to 10MB", color: Colors.black.withOpacity(0.7), size: 10, )
                      ],
                    )
                  ],
                ),
              ),
              // ------------------  Upload image ---------------------

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20)
                  ),


                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            child: Icon(
                              Icons.file_upload_outlined,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),

                        CostumeTextWidget(text: "Tap  to Upload Upload a Screenshort", color: Colors.black, size: 11, fontWeight: FontWeight.bold,),
                        SizedBox(height: 10,),
                        CostumeTextWidget(text: "PNG, JPG up to 10MB", color: Colors.black.withOpacity(0.7), size: 10, ),
                        SizedBox(height: 20,),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(onPressed: (){}, child: Text("Analyze Conversation")),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Icon(Icons.safety_check_outlined,color: Colors.blue,size: 10,),
                    CostumeTextWidget(text: " Your Data is private & secure", color: Colors.blue, size: 10)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

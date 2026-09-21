import 'package:flutter/material.dart';

class PickupLinePreviewWidget extends StatefulWidget {

  final Color backgroundColor; //  add ------------
  const PickupLinePreviewWidget({
    super.key,
  this.backgroundColor = Colors.white
  });

  @override
  State<PickupLinePreviewWidget> createState() => _PickupLinePreviewWidgetState();
}

class _PickupLinePreviewWidgetState extends State<PickupLinePreviewWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Expanded(
            // main preview content receiver
            child: Card(
              color: widget.backgroundColor, // use for change background
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: "Type Here...",
                      hintStyle: TextStyle(fontSize: 20),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

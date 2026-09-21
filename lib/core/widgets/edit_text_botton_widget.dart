import 'package:flirtymessages/core/widgets/costume_text/costume_text_widget.dart';
import 'package:flutter/material.dart';

class EditTextBottonWidget extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isSelected;
  const EditTextBottonWidget({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<EditTextBottonWidget> createState() => _EditTextBottonWidgetState();
}

class _EditTextBottonWidgetState extends State<EditTextBottonWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected ? Colors.pink.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 2,
              color: widget.isSelected ? Colors.pink : Colors.grey.shade300,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 100,
              width: 120,
              child: Card(
                elevation: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        widget.icon,
                        color: widget.isSelected ? Colors.pink : Colors.black,
                        size: 28,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CostumeTextWidget(
                        text: widget.text,
                        color: Colors.black,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

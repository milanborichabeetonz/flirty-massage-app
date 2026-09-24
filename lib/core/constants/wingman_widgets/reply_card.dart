import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReplyCard extends StatefulWidget {
  final String message;

  const ReplyCard({super.key, required this.message});

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  late String _currentMessage;

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message;
  }

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: _currentMessage));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareMessage() {
    SharePlus.instance.share(ShareParams(text: _currentMessage));
  }

  void _editMessage() {
    final controller = TextEditingController(text: _currentMessage);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reply'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: 'Edit your message...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentMessage = controller.text;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentMessage,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  color: Colors.blue,
                  onTap: _copyMessage,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: Colors.orange,
                  onTap: _editMessage,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  color: Colors.pink,
                  onTap: _shareMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

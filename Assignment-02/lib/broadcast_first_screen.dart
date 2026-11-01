import 'package:flutter/material.dart';

import 'broadcast_second_screen.dart';

enum BroadcastType {
  custom('Custom'),
  battery('System battery notification receiver');

  const BroadcastType(this.label);
  final String label;
}

/// Broadcast Receiver section of the drawer: pick a broadcast type, then
/// proceed to the second screen.
class BroadcastFirstScreen extends StatefulWidget {
  const BroadcastFirstScreen({super.key});

  @override
  State<BroadcastFirstScreen> createState() => _BroadcastFirstScreenState();
}

class _BroadcastFirstScreenState extends State<BroadcastFirstScreen> {
  BroadcastType _selectedType = BroadcastType.custom;

  void _onProceed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BroadcastSecondScreen(selectedType: _selectedType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select a broadcast type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BroadcastType>(
                  value: _selectedType,
                  isExpanded: false,
                  items: [
                    for (final type in BroadcastType.values)
                      DropdownMenuItem(value: type, child: Text(type.label)),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedType = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              key: const Key('proceedButton'),
              onPressed: _onProceed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(color: Colors.grey.shade300),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 1,
              ),
              child: const Text('Proceed'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import 'broadcast_first_screen.dart';
import 'broadcast_service.dart';
import 'broadcast_third_screen.dart';

class BroadcastSecondScreen extends StatefulWidget {
  final BroadcastType selectedType;

  const BroadcastSecondScreen({super.key, required this.selectedType});

  @override
  State<BroadcastSecondScreen> createState() => _BroadcastSecondScreenState();
}

class _BroadcastSecondScreenState extends State<BroadcastSecondScreen> {
  final TextEditingController _textController = TextEditingController();
  StreamSubscription<int>? _batterySub;
  int? _batteryLevel;
  String? _batteryError;

  @override
  void initState() {
    super.initState();
    if (widget.selectedType == BroadcastType.battery) {
      // Registers the ACTION_BATTERY_CHANGED receiver until this screen closes.
      _batterySub = BroadcastService.batteryLevels.listen(
        (level) => setState(() {
          _batteryLevel = level;
          _batteryError = null;
        }),
        onError: (Object error) => setState(() {
          _batteryError = error is UnsupportedError
              ? error.message
              : 'Unable to read battery level';
        }),
      );
    }
  }

  @override
  void dispose() {
    _batterySub?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onProceedWithMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to broadcast')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BroadcastThirdScreen(
          selectedType: widget.selectedType,
          passedMessage: text,
        ),
      ),
    );
  }

  Widget _buildCustomView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Custom Broadcast Receiver Input',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Enter a plain text message below. It is passed to the Third Activity, '
          'whose custom broadcast receiver receives it.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextField(
          key: const Key('customMessageField'),
          controller: _textController,
          decoration: InputDecoration(
            labelText: 'Message to Broadcast',
            hintText: 'e.g. Hello CSE 489!',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.message_outlined),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          key: const Key('sendBroadcastButton'),
          onPressed: _onProceedWithMessage,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Go to Third Activity'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatteryStatus() {
    if (_batteryError != null) {
      return Text(
        _batteryError!,
        key: const Key('batteryLevelText'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.red),
      );
    }
    if (_batteryLevel == null) {
      return const CircularProgressIndicator();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Battery: $_batteryLevel%',
        key: const Key('batteryLevelText'),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade900,
        ),
      ),
    );
  }

  Widget _buildBatteryView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _batteryLevel != null && _batteryLevel! > 20
              ? Icons.battery_charging_full_rounded
              : Icons.battery_alert_rounded,
          size: 80,
          color: Colors.green.shade700,
        ),
        const SizedBox(height: 16),
        const Text(
          'System Battery Notification Receiver',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Broadcast: ACTION_BATTERY_CHANGED',
          style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 24),
        _buildBatteryStatus(),
        const SizedBox(height: 12),
        const Text(
          'Updates automatically whenever the battery level changes.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    BroadcastThirdScreen(selectedType: widget.selectedType),
              ),
            );
          },
          child: const Text('Go to Third Activity'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedType == BroadcastType.custom
              ? 'Second Activity (Input)'
              : 'Second Activity (Battery)',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: widget.selectedType == BroadcastType.custom
            ? _buildCustomView()
            : _buildBatteryView(),
      ),
    );
  }
}

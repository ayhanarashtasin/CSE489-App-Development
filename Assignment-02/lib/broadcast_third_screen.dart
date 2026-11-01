import 'dart:async';

import 'package:flutter/material.dart';

import 'broadcast_first_screen.dart';
import 'broadcast_service.dart';

class BroadcastThirdScreen extends StatefulWidget {
  final BroadcastType selectedType;

  /// Text from the second screen; required for [BroadcastType.custom].
  final String? passedMessage;

  const BroadcastThirdScreen({
    super.key,
    required this.selectedType,
    this.passedMessage,
  }) : assert(selectedType != BroadcastType.custom || passedMessage != null);

  @override
  State<BroadcastThirdScreen> createState() => _BroadcastThirdScreenState();
}

class _BroadcastThirdScreenState extends State<BroadcastThirdScreen> {
  String? _receivedMessage;
  String? _error;
  StreamSubscription<String>? _broadcastSub;

  @override
  void initState() {
    super.initState();
    if (widget.selectedType == BroadcastType.custom) {
      // Create the custom broadcast receiver first, then send the passed text
      // to it. Only what the receiver delivers is shown on screen.
      _broadcastSub = BroadcastService.customBroadcasts.listen(
        (message) => setState(() => _receivedMessage = message),
        onError: _onError,
      );
      BroadcastService.sendCustomBroadcast(widget.passedMessage!)
          .catchError(_onError);
    }
  }

  void _onError(Object error) {
    if (!mounted) return;
    setState(() {
      _error = error is UnsupportedError
          ? error.message
          : 'Custom broadcast failed: $error';
    });
  }

  @override
  void dispose() {
    // Unregisters the custom broadcast receiver.
    _broadcastSub?.cancel();
    super.dispose();
  }

  Widget _buildReceiverStatus() {
    if (_receivedMessage != null) {
      return Text(
        _receivedMessage!,
        key: const Key('receivedBroadcastMessageText'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
        ),
      );
    }
    if (_error != null) {
      return Text(
        _error!,
        key: const Key('broadcastErrorText'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.red),
      );
    }
    return const Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 12),
        Text(
          'Receiver registered. Waiting for broadcast...',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCustomReceiverView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cell_tower_rounded,
          size: 72,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        const Text(
          'Custom Broadcast Receiver',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Action: com.example.assignment_2.CUSTOM_BROADCAST',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _receivedMessage != null
                          ? Icons.check_circle
                          : Icons.hourglass_top,
                      color: _receivedMessage != null
                          ? Colors.green
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Broadcast Message Received:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildReceiverStatus(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          icon: const Icon(Icons.home),
          label: const Text('Back to Home'),
        ),
      ],
    );
  }

  Widget _buildBatteryNothingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 72,
          color: Colors.blueGrey,
        ),
        const SizedBox(height: 16),
        const Text(
          'Third Activity',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Text(
            'Per Assignment Specification:\n\n'
            '"If the user selects the second option in the first activity, then do nothing here."',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.4, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          icon: const Icon(Icons.home),
          label: const Text('Back to Home'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Third Activity')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: widget.selectedType == BroadcastType.custom
              ? _buildCustomReceiverView()
              : _buildBatteryNothingView(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScanReceiptScreen extends StatelessWidget {
  const ScanReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement receipt scanner using image_picker + OcrService
    return Scaffold(
      appBar: AppBar(title: Text('scan_receipt.title'.tr())),
      body: Center(child: Text('scan_receipt.coming_soon'.tr())),
    );
  }
}

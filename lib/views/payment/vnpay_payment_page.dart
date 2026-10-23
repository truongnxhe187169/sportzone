import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/app_colors.dart';
import '../../services/vnpay_service.dart';

/// Màn hình thanh toán VNPay dùng WebView
class VnPayPaymentPage extends StatefulWidget {
  final String paymentUrl;
  final void Function(VNPayResult) onResult;

  const VnPayPaymentPage({
    super.key,
    required this.paymentUrl,
    required this.onResult,
  });

  @override
  State<VnPayPaymentPage> createState() => _VnPayPaymentPageState();
}

class _VnPayPaymentPageState extends State<VnPayPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _handled = false; // tránh gọi callback 2 lần

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            // Bắt return URL từ VNPay
            if (!_handled && VNPayService.isReturnUrl(request.url)) {
              _handled = true;
              final uri = Uri.parse(request.url);
              final result = VNPayService.parseResult(uri);
              // Về lại màn trước rồi truyền kết quả
              if (mounted) {
                Navigator.of(context).pop();
                widget.onResult(result);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            // Chỉ hiện lỗi nếu không phải lỗi từ intercepted URL
            if (!_handled) {
              debugPrint('VNPay WebView error: ${error.description}');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () {
            if (!_handled) {
              _handled = true;
              Navigator.of(context).pop();
              widget.onResult(const VNPayResult(
                responseCode: '24',
                txnRef: '',
                amount: 0,
                bankCode: '',
                transactionNo: '',
                isSuccess: false,
              ));
            }
          },
        ),
        title: Row(
          children: [
            Image.network(
              'https://sandbox.vnpayment.vn/paymentv2/Images/favicon.ico',
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.payment, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            const Text(
              'Thanh toán VNPay',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

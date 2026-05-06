import 'package:flutter/material.dart';
import '../../services/job_service_client.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../services/payment_service.dart';
import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> provider;
  final String categoryName;

  const BookingPage({
    super.key,
    required this.provider,
    required this.categoryName,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 0;
  int _selectedPaymentIndex = 0;
  final JobServiceClient _jobServiceClient = JobServiceClient();
  late Razorpay _razorpay;
  final PaymentService _paymentService = PaymentService();
  bool _isProcessingPayment = false;

  final List<String> _timeSlots = const [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  final List<Map<String, dynamic>> _paymentMethods = const [
    {'name': 'Cash', 'icon': Icons.payments_rounded},
    {'name': 'UPI', 'icon': Icons.account_balance_rounded},
    {'name': 'Credit Card', 'icon': Icons.credit_card_rounded},
  ];

  double get _totalPrice => (widget.provider['price'] as num).toDouble();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _paymentService.initializeForWeb();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await _paymentService.verifyPayment(
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
      );
      if (mounted) setState(() => _isProcessingPayment = false);
      _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        _showErrorSnackBar('Verification failed: $e');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _isProcessingPayment = false);
      _showErrorSnackBar('Payment failed: ${response.message}');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      setState(() => _isProcessingPayment = false);
      _showErrorSnackBar('External wallet selected: ${response.walletName}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030303) : const Color(0xFFFBFBFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSectionHeader('Provider Information'),
                  const SizedBox(height: 16),
                  _buildProviderInfo(isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Schedule Service'),
                  const SizedBox(height: 16),
                  _buildDateSelection(isDark),
                  const SizedBox(height: 20),
                  _buildTimeSelection(isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Payment Method'),
                  const SizedBox(height: 16),
                  _buildPaymentSelection(isDark),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF030303) : Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=800',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    isDark ? const Color(0xFF030303) : const Color(0xFFFBFBFF),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        title: Text(
          'Book ${widget.categoryName}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Color(0xFF3366FF),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildProviderInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0F14).withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE8ECF4),
        ),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'service_icon_${widget.provider['name']}',
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3366FF), width: 2),
                image: DecorationImage(
                  image: NetworkImage(widget.provider['imageUrl'] ??
                      'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.provider['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Expert ${widget.categoryName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${widget.provider['price']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3366FF),
                ),
              ),
              const Text(
                'per hour',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(7, (index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = _selectedDateIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3366FF) : (isDark ? const Color(0xFF0D0F14) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3366FF) : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE8ECF4)),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeSelection(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_timeSlots.length, (index) {
          final isSelected = _selectedTimeIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3366FF).withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3366FF) : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE8ECF4)),
                  width: 1.5,
                ),
              ),
              child: Text(
                _timeSlots[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  color: isSelected ? const Color(0xFF3366FF) : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPaymentSelection(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_paymentMethods.length, (index) {
          final isSelected = _selectedPaymentIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedPaymentIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3366FF).withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3366FF) : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE8ECF4)),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _paymentMethods[index]['icon'] as IconData, 
                    size: 18, 
                    color: isSelected ? const Color(0xFF3366FF) : (isDark ? Colors.white54 : Colors.grey[600])
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _paymentMethods[index]['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected ? const Color(0xFF3366FF) : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF030303) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE8ECF4))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL PRICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('\$${_totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessingPayment ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: _isProcessingPayment 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBooking() async {
    setState(() => _isProcessingPayment = true);
    final storage = const FlutterSecureStorage();
    final userId = await storage.read(key: 'userId') ?? '';
    String jobIdStr;
    final selectedDate = DateTime.now().add(Duration(days: _selectedDateIndex));
    final dateStr = '${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][selectedDate.weekday - 1]}, ${selectedDate.day}';
    final timeStr = _timeSlots[_selectedTimeIndex];
    final providerName = widget.provider['name'];
    final customDesc = 'SCHEDULED: $dateStr at $timeStr|PROVIDER: $providerName';

    try {
      jobIdStr = await _jobServiceClient.createJob(
        serviceType: widget.categoryName,
        price: _totalPrice,
        workersNeeded: 1,
        latitude: 0.0,
        longitude: 0.0,
        address: 'Home',
        description: customDesc,
        providerId: widget.provider['id'],
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        _showErrorSnackBar('Booking failed: $e');
      }
      return;
    }

    final String jobId = jobIdStr;
    final paymentMethod = _paymentMethods[_selectedPaymentIndex]['name'];

    if (paymentMethod != 'Cash') {
      try {
        if (kIsWeb) {
          if (mounted) {
            final paymentId = await _paymentService.makeWebPayment(
              amount: _totalPrice.toInt(),
              currency: 'INR',
              jobId: jobId,
              userId: userId,
              context: context,
            );
            if (mounted) setState(() => _isProcessingPayment = false);
            if (paymentId != null) {
              _showSuccessDialog();
            } else {
              _showErrorSnackBar('Payment cancelled or failed');
            }
          }
        } else if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
          final order = await _paymentService.createOrder(_totalPrice.toInt(), 'INR', jobId, userId);
          final options = {
            'key': order!['key'],
            'amount': (order['amount'] * 100).toInt(),
            'currency': order['currency'],
            'name': 'Clenzy',
            'description': 'Payment for ${widget.provider['name']}',
            'order_id': order['orderId'],
            'prefill': {'contact': '9876543210', 'email': 'user@clenzy.com'},
          };
          if (mounted) setState(() => _isProcessingPayment = false);
          _razorpay.open(options);
        } else {
          // Desktop Fallback (Windows/macOS/Linux)
          if (mounted) {
            setState(() => _isProcessingPayment = false);
            _showDesktopPaymentNotice(jobId);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isProcessingPayment = false);
          _showErrorSnackBar('Order failed: $e');
        }
      }
    } else {
      if (mounted) setState(() => _isProcessingPayment = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 80),
              const SizedBox(height: 20),
              const Text('Booking Success!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              const Text('Your professional is informed and will arrive as scheduled.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3366FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDesktopPaymentNotice(String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Desktop Payment Mode', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.computer_rounded, size: 48, color: Color(0xFF3366FF)),
            const SizedBox(height: 16),
            const Text(
              'The Razorpay Mobile SDK is optimized for Android & iOS. For desktop testing, we will simulate the payment completion.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3366FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simulate Success', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

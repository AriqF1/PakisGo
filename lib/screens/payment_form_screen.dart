import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'COD';
  String _selectedShipping = 'REG';
  bool _isProcessing = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'COD',
      'name': 'Cash on Delivery',
      'icon': Icons.money,
      'description': 'Bayar saat barang tiba',
      'color': Colors.green,
    },
    {
      'id': 'TRANSFER',
      'name': 'Transfer Bank',
      'icon': Icons.account_balance,
      'description': 'Transfer ke rekening',
      'color': Colors.blue,
    },
    {
      'id': 'EWALLET',
      'name': 'E-Wallet',
      'icon': Icons.wallet,
      'description': 'OVO, GoPay, Dana',
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _shippingOptions = [
    {'id': 'REG', 'name': 'Reguler', 'price': 10000},
    {'id': 'YES', 'name': 'Yakin Esok Sampai', 'price': 25000},
    {'id': 'OKE', 'name': 'Oke Delivery', 'price': 15000},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Simulasi proses pembayaran
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final cart = Provider.of<CartProvider>(context, listen: false);

      // Tampilkan nota pembayaran
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildReceiptDialog(cart),
      );

      cart.resetCart();

      // Kembali ke dashboard
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  int _getShippingCost() {
    return _shippingOptions.firstWhere(
      (option) => option['id'] == _selectedShipping,
    )['price'];
  }

  double _getTotalPayment(CartProvider cart) {
    return cart.totalPrice + _getShippingCost();
  }

  List<Widget> _buildItemsList(CartProvider cart) {
    final Map<String, Map<String, dynamic>> groupedItems = {};

    for (var product in cart.items) {
      if (groupedItems.containsKey(product.name)) {
        groupedItems[product.name]!['quantity']++;
      } else {
        groupedItems[product.name] = {'product': product, 'quantity': 1};
      }
    }

    return groupedItems.values.map((item) {
      final product = item['product'];
      final quantity = item['quantity'] as int;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Text(
              "${quantity}x",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Rp ${(product.price * quantity).toStringAsFixed(0)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Ringkasan Pesanan
                _buildOrderSummary(cart),
                const SizedBox(height: 16),

                // Form Pembeli + Metode Pembayaran + Pengiriman
                _buildFormSection(cart),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(cart),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryGreen, kPrimaryGreen.withOpacity(0.8)],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ringkasan Pesanan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${cart.items.length} Item dalam keranjang",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: _buildItemsList(cart)),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white38, thickness: 1),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Pembayaran",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Rp ${_getTotalPayment(cart).toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Pembeli
            _buildSectionTitle(icon: Icons.person, title: "Informasi Pembeli"),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: "Nama Lengkap",
              hint: "Masukkan nama lengkap",
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: "Nomor Telepon",
              hint: "08xxxxxxxxxx",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: "Alamat Lengkap",
              hint: "Masukkan alamat lengkap",
              icon: Icons.location_on_outlined,
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Alamat tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _notesController,
              label: "Catatan (Opsional)",
              hint: "Tambahkan catatan untuk penjual",
              icon: Icons.note_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Metode Pembayaran
            _buildSectionTitle(icon: Icons.payment, title: "Metode Pembayaran"),
            const SizedBox(height: 16),
            ..._paymentMethods.map(
              (method) => _buildPaymentMethodTile(
                id: method['id'],
                name: method['name'],
                description: method['description'],
                icon: method['icon'],
                color: method['color'],
              ),
            ),

            const SizedBox(height: 32),

            // Pengiriman
            _buildSectionTitle(icon: Icons.local_shipping, title: "Pengiriman"),
            const SizedBox(height: 16),
            ..._shippingOptions.map(
              (option) => _buildShippingOptionTile(
                id: option['id'],
                name: option['name'],
                price: option['price'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimaryGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: kPrimaryGreen, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required String id,
    required String name,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? kPrimaryGreen.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kPrimaryGreen : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? kPrimaryGreen : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kPrimaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingOptionTile({
    required String id,
    required String name,
    required int price,
  }) {
    final isSelected = _selectedShipping == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedShipping = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? kPrimaryGreen.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kPrimaryGreen : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
            Text("Rp $price", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(CartProvider cart) {
    double totalPayment = _getTotalPayment(cart);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Pembayaran",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rp ${totalPayment.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, size: 24),
                          SizedBox(width: 12),
                          Text(
                            "Konfirmasi Pembayaran",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptDialog(CartProvider cart) {
    int shippingCost = _getShippingCost();
    double totalPayment = _getTotalPayment(cart);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "NOTA PEMBAYARAN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              Text("Nama: ${_nameController.text}"),
              Text("Telepon: ${_phoneController.text}"),
              Text("Alamat: ${_addressController.text}"),
              const Divider(height: 20),
              ...cart.items.map(
                (item) => Text("${item.name} x1 = Rp ${item.price}"),
              ),
              const Divider(height: 20),
              Text("Ongkos Kirim: Rp $shippingCost"),
              Text(
                "Total Pembayaran: Rp ${totalPayment.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup Nota"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

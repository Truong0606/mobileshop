import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/shared/widgets/skeleton_loader.dart';
import 'package:smart_shopping_chatbot/shared/widgets/empty_state_widget.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  bool _isLoadingPending = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoadingPending = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Lịch sử đơn hàng',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Hoàn thành'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPendingTab(),
            _buildDeliveringTab(),
            _buildCompletedTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_isLoadingPending) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SkeletonLoader(height: 120, width: double.infinity),
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderItem(
          orderId: '#ORD-1001',
          date: '23/07/2026',
          status: 'Chờ xác nhận',
          statusColor: Colors.orange,
          total: '500.000 đ',
          items: '2 sản phẩm',
        ),
        const SizedBox(height: 16),
        _buildOrderItem(
          orderId: '#ORD-1002',
          date: '22/07/2026',
          status: 'Chờ xác nhận',
          statusColor: Colors.orange,
          total: '1.200.000 đ',
          items: '3 sản phẩm',
        ),
      ],
    );
  }

  Widget _buildDeliveringTab() {
    return const EmptyStateWidget(
      icon: Icons.local_shipping_outlined,
      title: 'Không có đơn hàng nào',
      message: 'Hiện tại bạn không có đơn hàng nào đang được giao.',
    );
  }

  Widget _buildCompletedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderItem(
          orderId: '#ORD-0999',
          date: '20/07/2026',
          status: 'Hoàn thành',
          statusColor: Colors.green,
          total: '850.000 đ',
          items: '1 sản phẩm',
        ),
      ],
    );
  }

  Widget _buildOrderItem({
    required String orderId,
    required String date,
    required String status,
    required Color statusColor,
    required String total,
    required String items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderId,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ngày đặt: $date',
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  items,
                  style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  total,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

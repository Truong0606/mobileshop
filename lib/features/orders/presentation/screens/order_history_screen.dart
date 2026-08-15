import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:smart_shopping_chatbot/core/theme/app_colors.dart';
import 'package:smart_shopping_chatbot/core/utils/price_formatter.dart';
import 'package:smart_shopping_chatbot/shared/widgets/skeleton_loader.dart';
import 'package:smart_shopping_chatbot/shared/widgets/empty_state_widget.dart';
import 'package:smart_shopping_chatbot/shared/providers/order_provider.dart';
import 'package:smart_shopping_chatbot/features/orders/data/models/order_model.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).fetchOrders(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('profile');
              }
            },
          ),
          title: Text(
            'Lịch sử đơn hàng',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Chờ thanh toán'),
              Tab(text: 'Đã thanh toán'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(null),
            _buildOrderList('PENDING'),
            _buildOrderList('PAID'),
            _buildOrderList('CANCELLED'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(String? filterStatus) {
    final orderState = ref.watch(orderProvider);
    
    if (orderState.isLoading && orderState.orders.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SkeletonLoader(height: 120, width: double.infinity),
          );
        },
      );
    }

    if (orderState.error != null && orderState.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: ${orderState.error}'),
            ElevatedButton(
              onPressed: () => ref.read(orderProvider.notifier).refresh(), 
              child: const Text('Thử lại')
            )
          ],
        ),
      );
    }

    final filteredOrders = filterStatus == null 
        ? orderState.orders 
        : orderState.orders.where((o) => o.status == filterStatus).toList();

    if (filteredOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(orderProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Không có đơn hàng',
              message: 'Bạn chưa có đơn hàng nào trong trạng thái này.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(orderProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length + (orderState.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == filteredOrders.length) {
            // Reached the end, load more
            Future.microtask(() => ref.read(orderProvider.notifier).fetchOrders());
            return const Center(child: CircularProgressIndicator());
          }
          final order = filteredOrders[index];
          return _buildOrderItem(order);
        },
      ),
    );
  }

  Widget _buildOrderItem(OrderModel order) {
    Color statusColor;
    String statusText;
    switch (order.status) {
      case 'PENDING':
        statusColor = Colors.orange;
        statusText = 'Chờ thanh toán';
        break;
      case 'PAID':
        statusColor = Colors.green;
        statusText = 'Đã thanh toán';
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = Colors.grey;
        statusText = order.status;
    }

    // Format date
    String dateStr = '';
    if (order.createdAt != null) {
      try {
        final dt = DateTime.parse(order.createdAt!).toLocal();
        dateStr = DateFormat('dd/MM/yyyy HH:mm').format(dt);
      } catch (_) {
        dateStr = order.createdAt!;
      }
    }

    return InkWell(
      onTap: () {
        context.pushNamed('order_detail', pathParameters: {'id': order.id.toString()});
      },
      child: Card(
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
                    order.orderCode ?? '#${order.id}',
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
                      statusText,
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
              if (dateStr.isNotEmpty)
                Text(
                  'Ngày đặt: $dateStr',
                  style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
                ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} sản phẩm',
                    style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    PriceFormatter.formatVNDDouble(order.totalAmount),
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
      ),
    );
  }
}

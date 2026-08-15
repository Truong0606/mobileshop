import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_shopping_chatbot/features/orders/data/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository();
});

class PaymentState {
  final bool isLoading;
  final String? error;
  final String? paymentUrl;

  PaymentState({this.isLoading = false, this.error, this.paymentUrl});

  PaymentState copyWith({bool? isLoading, String? error, String? paymentUrl}) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be null to clear
      paymentUrl: paymentUrl, // Can be null to clear
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository _repository;

  PaymentNotifier(this._repository) : super(PaymentState());

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<String?> checkout({
    required String receiverName,
    required String receiverPhone,
    required String shippingAddress,
    required String returnUrl,
    required String cancelUrl,
    String? conversationId,
  }) async {
    state = state.copyWith(isLoading: true, error: null, paymentUrl: null);
    try {
      final url = await _repository.checkout(
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        shippingAddress: shippingAddress,
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
        conversationId: conversationId,
      );
      state = state.copyWith(isLoading: false, paymentUrl: url);
      return url;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repository);
});

/// Payment options offered in the booking flow.
///
/// [Booking.paymentMethod] stays a plain String; this enum only supplies the
/// picker's choices and their display labels.
enum PaymentMethod {
  cash('cash', 'Cash'),
  myanmyanpay('myanmyanpay', 'MyanMyanPay'),
  stripe('stripe', 'Stripe (Card)');

  const PaymentMethod(this.value, this.label);

  /// Wire value stored on a booking.
  final String value;
  final String label;

  static PaymentMethod fromValue(String value) => values.firstWhere(
        (method) => method.value == value,
        orElse: () => PaymentMethod.cash,
      );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:car_service_app/main.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const CarServiceApp());

    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:stanslist/app.dart'; // Corrected import path
import 'package:stanslist/screens/home_screen.dart'; // Import HomeScreen

void main() {
  testWidgets('App has a home screen', (WidgetTester tester) async {
    // For now, assuming StansListApp can be pumped directly or providers are handled within it.
    await tester.pumpWidget(
        const StansListApp()); // Corrected to StansListApp and added const

    // Verify that the home screen is displayed (assuming it's the initial route or handled by router)
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}

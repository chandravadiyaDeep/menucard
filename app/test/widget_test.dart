import 'package:flutter_test/flutter_test.dart';
import 'package:menucard/app.dart';
import 'package:menucard/data/app_database.dart';

void main() {
  testWidgets('MenuCard home screen renders', (tester) async {
    // Use an in-memory SQLite database for a deterministic widget test.
    final database = AppDatabase.forTesting();
    await tester.pumpWidget(MenuCardApp(database: database));
    await tester.pumpAndSettle();
    expect(find.text('Your shop, your menu.'), findsOneWidget);
    expect(find.text('Works offline'), findsOneWidget);
    await database.close();
  });
}

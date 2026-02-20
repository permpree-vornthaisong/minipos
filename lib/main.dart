import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/product/product_event.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/cart/cart_event.dart';
import 'blocs/report/report_bloc.dart';
import 'blocs/report/report_event.dart';
import 'services/storage_service.dart';
import 'pages/product_page.dart';
import 'pages/checkout_page.dart';
import 'pages/report_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ProductBloc(storageService: storageService)..add(LoadProducts()),
        ),
        BlocProvider(
          create: (_) =>
              CartBloc(storageService: storageService)..add(LoadCart()),
        ),
        BlocProvider(
          create: (_) => ReportBloc(storageService: storageService),
        ),
      ],
      child: MaterialApp(
        title: 'Mini POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _goToTab(int index) {
    setState(() => _currentIndex = index);
    if (index == 2) {
      context.read<ReportBloc>().add(LoadReport());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ProductPage(onCartTap: () => _goToTab(1)),
      const CheckoutPage(),
      const ReportPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.store),
            label: 'สินค้า',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'ตะกร้า',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'รายงาน',
          ),
        ],
      ),
    );
  }
}

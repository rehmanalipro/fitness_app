import 'package:flutter/material.dart';

import 'package:fitness_app/layout/main_layout.dart';

class SubscriptionOptionsScreen extends StatelessWidget {
  const SubscriptionOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Subscription',
      showAppBar: true,
      showBackButton: true,
      showBottomNav: false,
      currentIndex: 5,
      body: Container(
        width: double.infinity,
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Center(
              child: SizedBox(
                width: 324,
                child: Column(
                  children: const [
                    _PlanOptionTile(
                      title: 'Monthly',
                      price: '\$9.99/month',
                      description: 'All features, no ads',
                    ),
                    SizedBox(height: 18),
                    _PlanOptionTile(
                      title: 'Quarterly',
                      price: '\$24.99 every 3 months',
                      description: 'Save 15%',
                    ),
                    SizedBox(height: 18),
                    _PlanOptionTile(
                      title: 'Yearly',
                      price: '\$89.99/year',
                      description: 'Save 25% + 2 bonus months + premium badge',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanOptionTile extends StatelessWidget {
  final String title;
  final String price;
  final String description;

  const _PlanOptionTile({
    required this.title,
    required this.price,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 324,
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 28 / 2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

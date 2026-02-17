import 'package:flutter/material.dart';

import 'package:fitness_app/core/widgets/app_back_appbar.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackAppBar(title: 'Subscription'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _PlanCard(
            title: 'Free Plan',
            subtitle: 'Basic workout and tracking features',
            price: '\$0 / month',
          ),
          SizedBox(height: 12),
          _PlanCard(
            title: 'Pro Monthly',
            subtitle: 'All premium workouts and guides',
            price: '\$9.99 / month',
          ),
          SizedBox(height: 12),
          _PlanCard(
            title: 'Pro Yearly',
            subtitle: 'Best value for full-year access',
            price: '\$79.99 / year',
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

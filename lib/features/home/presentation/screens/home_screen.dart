import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Hello, Maya',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here are the feedback requests that need your input.',
            style: TextStyle(color: Color(0xFF475569), fontSize: 15),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.task_alt_rounded, color: Color(0xFF2BB3A9)),
                      SizedBox(width: 8),
                      Text(
                        'Live request',
                        style: TextStyle(
                          color: Color(0xFF2BB3A9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Customer Experience Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF102A43),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share your experience with our onboarding and support journey.',
                    style: TextStyle(color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: Color(0xFF475569),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Due in 2 days',
                        style: TextStyle(color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('Open feedback form'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your feedback',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 8),
          _SummaryCard(
            label: 'Submitted',
            value: '3',
            color: const Color(0xFF1F4D9A),
          ),
          const SizedBox(height: 10),
          _SummaryCard(
            label: 'In review',
            value: '1',
            color: const Color(0xFFE8B84B),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF475569))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                value,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

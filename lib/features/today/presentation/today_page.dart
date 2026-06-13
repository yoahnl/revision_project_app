import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../application/today_controller.dart';
import '../domain/today_plan.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({required this.controller, super.key});

  final TodayController controller;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late Future<TodayPlan> _plan;

  @override
  void initState() {
    super.initState();
    _plan = widget.controller.getTodayPlan();
  }

  void _reloadPlan() {
    setState(() {
      _plan = widget.controller.getTodayPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Plan du jour',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            IconButton(
              onPressed: _reloadPlan,
              icon: const Icon(Icons.refresh),
              tooltip: 'Recharger',
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<TodayPlan>(
          future: _plan,
          builder: (context, snapshot) {
            final plan = snapshot.data;

            if (snapshot.connectionState != ConnectionState.done) {
              return const LinearProgressIndicator();
            }

            if (snapshot.hasError || plan == null) {
              return _TodayErrorState(onRetry: _reloadPlan);
            }

            if (plan.items.isEmpty) {
              return const Text('Aucune revision prioritaire');
            }

            return Column(
              children: [
                for (final item in plan.items) _TodayPlanItemCard(item: item),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TodayPlanItemCard extends StatelessWidget {
  const _TodayPlanItemCard({required this.item});

  final TodayPlanItem item;

  @override
  Widget build(BuildContext context) {
    final scoreLabel = '${(item.masteryScore * 100).round()} %';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.subjectName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(item.knowledgeUnitTitle),
            const SizedBox(height: 12),
            Text('Maitrise $scoreLabel'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => context.go(
                  Uri(
                    path: activitiesRoutePath,
                    queryParameters: {'subjectId': item.subjectId},
                  ).toString(),
                ),
                icon: const Icon(Icons.play_arrow),
                label: Text('Demarrer ${item.estimatedMinutes} min'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayErrorState extends StatelessWidget {
  const _TodayErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impossible de charger le plan',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Reessayer'),
        ),
      ],
    );
  }
}

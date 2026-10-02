import 'package:flutter/material.dart';

import '../models/guide_article.dart';
import '../widgets/guide_diagrams.dart';

/// 「役立つ情報」の一覧。
class GuideListView extends StatelessWidget {
  const GuideListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('役立つ情報')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: kGuideArticles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final a = kGuideArticles[i];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(a.title),
                subtitle: Text(a.summary),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GuideDetailView(article: a)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 解説記事の本文。
class GuideDetailView extends StatelessWidget {
  const GuideDetailView({super.key, required this.article});

  final GuideArticle article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(article.summary, style: theme.textTheme.bodyLarge),
            for (final s in article.sections) ...[
              const SizedBox(height: 20),
              Text(s.heading, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(s.body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
              if (s.figures.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Figures(figures: s.figures),
              ],
            ],
            if (article.officialFigures.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('公式の図', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '道路標識、区画線及び道路標示に関する命令（標識令）別表第六の図です。寸法を示す設計図なので、色は上の説明のとおりです。',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final (file, caption) in article.officialFigures)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/guides/$file',
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(caption, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 24),
            Text(
              '出典: ${article.sourceRef}（${article.checkedAt} 確認）',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Figures extends StatelessWidget {
  const _Figures({required this.figures});

  final List<GuideFigure> figures;

  @override
  Widget build(BuildContext context) {
    if (figures.length == 1) {
      return GuideDiagramView(figure: figures.first);
    }
    return LayoutBuilder(
      builder: (context, c) {
        final perRow = c.maxWidth >= 520 ? figures.length : 2;
        final w = (c.maxWidth - 12 * (perRow - 1)) / perRow;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final f in figures)
              SizedBox(width: w, child: GuideDiagramView(figure: f)),
          ],
        );
      },
    );
  }
}

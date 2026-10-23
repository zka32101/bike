import 'package:flutter/material.dart';

import '../core/constants/license_category.dart';
import '../models/skill_exam_tip.dart';

/// 技能試験のコツ一覧。免許区分を切り替えると、関係のある種目だけが出る。
class SkillExamListView extends StatefulWidget {
  const SkillExamListView({super.key, this.initialCategory = LicenseCategory.futsuuNirin});

  final LicenseCategory initialCategory;

  @override
  State<SkillExamListView> createState() => _SkillExamListViewState();
}

class _SkillExamListViewState extends State<SkillExamListView> {
  late LicenseCategory _category = widget.initialCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tips = skillExamTipsFor(_category);
    return Scaffold(
      appBar: AppBar(title: const Text('技能試験のコツ')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _Notice(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in LicenseCategory.values)
                  ChoiceChip(
                    label: Text(c.label),
                    selected: c == _category,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            for (final t in tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(t.title),
                    subtitle: Text(t.summary),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SkillExamDetailView(tip: t, category: _category),
                      ),
                    ),
                  ),
                ),
              ),
            Text(kSkillExamFollowNotice, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// 種目ごとのコツと練習チェックリスト。チェックは画面を開いている間だけ保持する。
class SkillExamDetailView extends StatefulWidget {
  const SkillExamDetailView({super.key, required this.tip, required this.category});

  final SkillExamTip tip;
  final LicenseCategory category;

  @override
  State<SkillExamDetailView> createState() => _SkillExamDetailViewState();
}

class _SkillExamDetailViewState extends State<SkillExamDetailView> {
  final Set<int> _checked = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = widget.tip.sectionsFor(widget.category);
    final checklist = widget.tip.checklistFor(widget.category);
    return Scaffold(
      appBar: AppBar(title: Text(widget.tip.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _Notice(),
            const SizedBox(height: 12),
            Text(widget.tip.summary, style: theme.textTheme.bodyLarge),
            for (final s in sections) ...[
              const SizedBox(height: 20),
              Text(s.heading, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(s.body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
            ],
            const SizedBox(height: 24),
            Text('練習チェックリスト（${_checked.length}/${checklist.length}）',
                style: theme.textTheme.titleMedium),
            for (var i = 0; i < checklist.length; i++)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _checked.contains(i),
                title: Text(checklist[i].text),
                onChanged: (v) => setState(() {
                  if (v ?? false) {
                    _checked.add(i);
                  } else {
                    _checked.remove(i);
                  }
                }),
              ),
            const SizedBox(height: 16),
            Text(kSkillExamFollowNotice, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(kSkillExamDraftNotice, style: theme.textTheme.bodySmall),
    );
  }
}

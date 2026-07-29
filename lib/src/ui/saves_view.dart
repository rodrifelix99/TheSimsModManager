import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../core/save_game.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'widgets.dart';

/// The Saves screen: what the current game's save files say about the
/// worlds the user actually plays - households, funds, sims, portraits,
/// photo albums - read straight off the disk, never written back.
///
/// Every game fills a different subset of [SaveGame] - a Sims 2 hood has
/// careers and relationships, a Sims 3 save has portraits and little
/// else, The Sims 1 has its houses but never a face - so the screen is
/// capability-driven: sections appear when the data exists and no game
/// ever shows an empty shell of another game's layout.
class SavesView extends StatelessWidget {
  const SavesView({super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final saves = c.saveGames;

    if (c.savesLoading && saves == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: t.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.savesScanning,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: t.muted,
              ),
            ),
          ],
        ),
      );
    }
    if (saves == null || saves.isEmpty) {
      return _EmptyState(theme: t, controller: c);
    }

    final save = c.selectedSave!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(theme: t, controller: c, save: save),
        _TabBar(theme: t, controller: c),
        Expanded(
          child: switch (c.effectiveSavesTab) {
            SavesTab.households =>
              _HouseholdsTab(theme: t, controller: c, save: save),
            SavesTab.album => _AlbumTab(theme: t, controller: c, save: save),
            SavesTab.stats => _StatsTab(theme: t, controller: c, save: save),
          },
        ),
      ],
    );
  }
}

/// The save's display title: its own name, except for the one game whose
/// saves are nameless numbered folders.
String saveTitle(L l, SaveGame save) {
  final number = save.neighborhoodNumber;
  return number != null ? l.savesNeighborhood(number) : save.name;
}

String _savedDate(DateTime? date) {
  if (date == null) return '';
  try {
    return DateFormat.yMMMd().add_Hm().format(date);
  } catch (_) {
    return DateFormat.yMMMd('en').add_Hm().format(date);
  }
}

String _simoleons(int amount) {
  String number;
  try {
    number = NumberFormat.decimalPattern().format(amount);
  } catch (_) {
    number = NumberFormat.decimalPattern('en').format(amount);
  }
  return '§$number';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.tint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.auto_stories_outlined, size: 30, color: t.accent),
          ),
          const SizedBox(height: 18),
          Text(
            l.savesEmptyTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: t.text,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(
              l.savesEmptyBody(controller.adapter.game.name),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.muted,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            style: accentButtonStyle(t),
            onPressed: controller.refreshSaves,
            child: Text(l.savesRescan),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(
      {required this.theme, required this.controller, required this.save});

  final GameTheme theme;
  final AppController controller;
  final SaveGame save;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final saves = c.saveGames!;
    final world = save.worldName;
    final subtitle = [
      if (world != null && world.isNotEmpty && world != save.name) world,
      if (save.modifiedAt != null)
        l.savesLastSaved(_savedDate(save.modifiedAt)),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.savesCount(saves.length), style: eyebrowStyle(t)),
                    const SizedBox(height: 5),
                    Text(
                      saveTitle(l, save),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: t.text,
                        height: 1.1,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: t.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => c.revealInFileManager(save.path),
                tooltip: l.savesShowInFolder,
                icon: Icon(Icons.folder_open_rounded, size: 20, color: t.muted),
              ),
              IconButton(
                onPressed: c.savesLoading ? null : c.refreshSaves,
                tooltip: l.savesRescan,
                icon: Icon(Icons.refresh_rounded, size: 20, color: t.muted),
              ),
            ],
          ),
          if (saves.length > 1) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: saves.length,
                separatorBuilder: (_, __) => const SizedBox(width: 9),
                itemBuilder: (context, index) =>
                    _SlotCard(theme: t, controller: c, index: index),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One save slot in the header's switcher row.
class _SlotCard extends StatelessWidget {
  const _SlotCard(
      {required this.theme, required this.controller, required this.index});

  final GameTheme theme;
  final AppController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    final save = controller.saveGames![index];
    final active = index == controller.selectedSaveIndex;
    final sub = [
      if (save.worldName != null && save.worldName!.isNotEmpty) save.worldName!,
      if (save.backupCount > 0) l.savesBackups(save.backupCount),
    ].join(' · ');

    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => controller.selectSave(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 168,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: active ? t.tint : t.surface,
            border: Border.all(
              color: active || hovered ? t.accent : t.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                saveTitle(l, save),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: t.text,
                ),
              ),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: t.muted,
                  ),
                ),
              ],
              if (save.modifiedAt != null) ...[
                const SizedBox(height: 1),
                Text(
                  _savedDate(save.modifiedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: t.muted.withValues(alpha: .75),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  String _label(L l, SavesTab tab) => switch (tab) {
        SavesTab.households => l.savesTabHouseholds,
        SavesTab.album => l.savesTabAlbum,
        SavesTab.stats => l.savesTabStats,
      };

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final tabs = c.availableSavesTabs;
    final current = c.effectiveSavesTab;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 14),
      // Scrolls sideways instead of overflowing: translated tab labels
      // run long ("Statystyki świata"), and the minimum window is narrow.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: t.surfaceAlt,
            border: Border.all(color: t.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final tab in tabs)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: HoverBuilder(
                    cursor: SystemMouseCursors.click,
                    builder: (context, hovered) => GestureDetector(
                      onTap: () => c.setSavesTab(tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: tab == current
                              ? t.surface
                              : hovered
                                  ? t.tint
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: tab == current
                              ? [
                                  BoxShadow(
                                    color: t.shadow.withValues(alpha: .25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          _label(l, tab),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: tab == current ? t.accent : t.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Households

class _HouseholdsTab extends StatelessWidget {
  const _HouseholdsTab(
      {required this.theme, required this.controller, required this.save});

  final GameTheme theme;
  final AppController controller;
  final SaveGame save;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 720;
        final households = save.households;
        final grid = _HouseholdList(
          theme: theme,
          controller: controller,
          households: households,
          columns: constraints.maxWidth > 980 ? 2 : 1,
        );
        final detail = controller.selectedSaveHousehold;
        if (!wide || detail == null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
            child: grid,
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: grid),
              const SizedBox(width: 20),
              SizedBox(
                width: 344,
                child: _HouseholdDetail(
                    theme: theme, controller: controller, household: detail),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HouseholdList extends StatelessWidget {
  const _HouseholdList({
    required this.theme,
    required this.controller,
    required this.households,
    required this.columns,
  });

  final GameTheme theme;
  final AppController controller;
  final List<SaveHousehold> households;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    // Rows are built per section so the played/townies split never lands
    // mid-row; the list itself stays lazy for the hoods that carry
    // thousands of townie households.
    final firstOther =
        households.indexWhere((household) => !household.isPlayed);
    final rows = <Widget>[];

    void addSection(int start, int end) {
      for (var i = start; i < end; i += columns) {
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          // IntrinsicHeight so the two cards of a row match heights; the
          // list's unbounded height means stretch alone cannot.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < columns; column++) ...[
                  if (column > 0) const SizedBox(width: 12),
                  Expanded(
                    child: i + column < end
                        ? _HouseholdCard(
                            theme: theme,
                            controller: controller,
                            index: i + column,
                            household: households[i + column],
                          )
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ));
      }
    }

    if (firstOther <= 0) {
      addSection(0, households.length);
    } else {
      addSection(0, firstOther);
      rows.add(Padding(
        padding: const EdgeInsets.fromLTRB(6, 14, 6, 8),
        child: Text(l.savesOtherHouseholds, style: eyebrowStyle(theme)),
      ));
      addSection(firstOther, households.length);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 28),
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index],
    );
  }
}

class _HouseholdCard extends StatelessWidget {
  const _HouseholdCard({
    required this.theme,
    required this.controller,
    required this.index,
    required this.household,
  });

  final GameTheme theme;
  final AppController controller;
  final int index;
  final SaveHousehold household;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    final active = index == controller.selectedSaveHouseholdIndex;
    final meta = [
      if (household.lotName != null && household.lotName!.isNotEmpty)
        household.lotName!,
      if (household.members.isNotEmpty)
        l.savesSimCount(household.members.length),
    ].join(' · ');

    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => controller.selectSaveHousehold(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(
              color: active || hovered ? t.accent : t.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: ModThumb(
                  seed: household.name,
                  bytes: household.portrait,
                  borderRadius: BorderRadius.circular(11),
                  decodeWidth: 104,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            household.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: t.text,
                            ),
                          ),
                        ),
                        if (household.funds != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _simoleons(household.funds!),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: t.accent,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: t.muted,
                        ),
                      ),
                    ],
                    if (household.members.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      _AvatarRow(theme: t, members: household.members),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The overlapping member-initial dots of the design; portraits when the
/// save has them.
class _AvatarRow extends StatelessWidget {
  const _AvatarRow({required this.theme, required this.members});

  final GameTheme theme;
  final List<SaveSim> members;

  @override
  Widget build(BuildContext context) {
    const shown = 6;
    return Row(
      children: [
        for (var i = 0; i < members.length && i < shown; i++)
          Align(
            widthFactor: .72,
            child: _SimAvatar(theme: theme, sim: members[i], size: 24),
          ),
        if (members.length > shown)
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              '+${members.length - shown}',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: theme.muted,
              ),
            ),
          ),
      ],
    );
  }
}

class _SimAvatar extends StatelessWidget {
  const _SimAvatar(
      {required this.theme, required this.sim, required this.size});

  final GameTheme theme;
  final SaveSim sim;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final portrait = sim.portrait;
    final child = portrait != null
        ? ClipOval(
            child: Image.memory(
              portrait,
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              cacheWidth: (size * 2).round(),
              errorBuilder: (_, __, ___) => _initial(t),
            ),
          )
        : _initial(t);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: t.surface, width: 2),
      ),
      child: child,
    );
  }

  Widget _initial(GameTheme t) {
    final name = sim.firstName;
    // Blend between the theme's two accents per sim, so a household row
    // reads as distinct people without inventing per-mood colors.
    final blend = (name.hashCode & 0xFF) / 0xFF;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.lerp(t.accent, t.accent2, blend),
      ),
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: TextStyle(
          fontSize: size * .44,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _HouseholdDetail extends StatelessWidget {
  const _HouseholdDetail(
      {required this.theme, required this.controller, required this.household});

  final GameTheme theme;
  final AppController controller;
  final SaveHousehold household;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    final facts = <(String, String)>[
      if (household.funds != null) (l.savesFunds, _simoleons(household.funds!)),
      // What the house and its contents are worth: the other half of a
      // family's fortune, and the only wealth an unhoused one lacks.
      if (household.propertyValue != null)
        (l.savesProperty, _simoleons(household.propertyValue!)),
      if (household.bedrooms != null && household.bathrooms != null)
        (
          l.savesRooms,
          l.savesBedsBaths(household.bedrooms!, household.bathrooms!)
        ),
    ];
    final description = household.description;
    final creator = household.creatorName;
    final subtitle = [
      if (household.lotName != null && household.lotName!.isNotEmpty)
        household.lotName!,
      if (household.lotTypeKey != null) l.savesLotType(household.lotTypeKey!),
      if (creator != null && creator.isNotEmpty) l.savesByCreator(creator),
    ].join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (household.portrait != null) ...[
            SizedBox(
              height: 132,
              child: ModThumb(
                seed: household.name,
                bytes: household.portrait,
                borderRadius: BorderRadius.circular(12),
                decodeWidth: 640,
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            household.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: t.text,
              height: 1.15,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: t.muted,
              ),
            ),
          ],
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                for (final (index, (label, value)) in facts.indexed) ...[
                  if (index > 0) const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: t.surfaceAlt,
                        border: Border.all(color: t.border),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .5,
                                color: t.muted,
                              )),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: t.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              description,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: t.muted,
                height: 1.5,
              ),
            ),
          ],
          if (household.members.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l.savesMembers.toUpperCase(), style: eyebrowStyle(t)),
            const SizedBox(height: 9),
            for (final sim in household.members) ...[
              _MemberRow(theme: t, sim: sim),
              const SizedBox(height: 10),
            ],
          ],
          if (household.relationships.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l.savesRelationships.toUpperCase(), style: eyebrowStyle(t)),
            const SizedBox(height: 9),
            for (final bond in household.relationships) ...[
              _BondRow(theme: t, bond: bond),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.theme, required this.sim});

  final GameTheme theme;
  final SaveSim sim;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    final name = sim.fullName.isEmpty ? l.savesUnknownSim : sim.fullName;
    final meta = [
      if (sim.ageKey != null) l.savesAge(sim.ageKey!),
      if (sim.genderKey != null) l.savesGender(sim.genderKey!),
      if (sim.zodiacKey != null) l.savesZodiac(sim.zodiacKey!),
      if (sim.aspirationKey != null) l.savesAspiration(sim.aspirationKey!),
    ].join(' · ');
    final traits = <(String, int)>[
      for (final entry in sim.skills.entries)
        if (entry.value > 0) (l.savesSkill(entry.key), entry.value),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final personality = <(String, int)>[
      for (final entry in sim.personality.entries)
        if (entry.value > 0) (l.savesPersonality(entry.key), entry.value),
    ];
    // A sim can be interested in twenty things; the panel shows what
    // they are most interested in rather than the whole list.
    final interests = <(String, int)>[
      for (final entry in sim.interests.entries)
        if (entry.value > 0) (l.savesInterest(entry.key), entry.value),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final hobbies = <(String, int)>[
      for (final entry in sim.hobbies.entries)
        if (entry.value > 0) (l.savesHobby(entry.key), entry.value),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final education = sim.education;
    // "Biology · 3.4 GPA · semester 5", dropping whatever the save
    // didn't record.
    final study = education == null
        ? ''
        : [
            if (education.major != null) education.major!,
            if (education.gpa != null)
              l.savesGpa(education.gpa!.toStringAsFixed(1)),
            if (education.semester != null)
              l.savesSemester(education.semester!),
          ].join(' · ');
    final career = sim.careerName;
    // What the sim is other than an ordinary living sim - worth saying
    // right next to the name, since it changes everything else about it.
    final badge = sim.occultKey != null
        ? l.savesOccult(sim.occultKey!)
        : sim.isGhost
            ? l.savesGhost
            : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SimAvatar(theme: t, sim: sim, size: 34),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: t.text,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 6),
                    TagChip(label: badge, color: t.accent2, background: t.tint),
                  ],
                ],
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  meta,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: t.muted,
                  ),
                ),
              ],
              if (career != null && career.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sim.careerLevel != null
                      ? l.savesCareerLevel(career, sim.careerLevel!)
                      : career,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: t.accent,
                  ),
                ),
              ],
              if (study.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  study,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: t.accent2,
                  ),
                ),
              ],
              if (sim.bio != null && sim.bio!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  sim.bio!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: t.muted,
                    height: 1.4,
                  ),
                ),
              ],
              if (sim.predestinedHobbyKey != null) ...[
                const SizedBox(height: 2),
                Text(
                  l.savesPredestinedHobby(
                      l.savesHobby(sim.predestinedHobbyKey!)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: t.muted,
                  ),
                ),
              ],
              if (sim.familyTies.isNotEmpty) ...[
                const SizedBox(height: 4),
                _FamilyTies(theme: t, ties: sim.familyTies),
              ],
              if (traits.isNotEmpty ||
                  personality.isNotEmpty ||
                  interests.isNotEmpty ||
                  hobbies.isNotEmpty) ...[
                const SizedBox(height: 5),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    for (final (label, value) in traits)
                      _PointChip(
                          theme: t, label: label, value: value, accent: true),
                    // What they are into, ahead of the raw personality
                    // axes: it is the more interesting half.
                    for (final (label, value) in hobbies.take(3))
                      _PointChip(
                          theme: t, label: label, value: value, accent: true),
                    for (final (label, value) in personality)
                      _PointChip(
                          theme: t, label: label, value: value, accent: false),
                    for (final (label, value) in interests.take(3))
                      _PointChip(
                          theme: t, label: label, value: value, accent: false),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Who a sim's relatives are, gathered one line per kind: "mother Bella
/// Goth", "children Cassandra, Alexander". Ties reach outside the
/// household, which is the point - it is how a family tree survives
/// people moving out.
class _FamilyTies extends StatelessWidget {
  const _FamilyTies({required this.theme, required this.ties});

  final GameTheme theme;
  final List<SaveFamilyTie> ties;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    // Group by kind, keeping the order the scanner sorted them into.
    final byKind = <String, List<String>>{};
    for (final tie in ties) {
      byKind.putIfAbsent(tie.kindKey, () => []).add(tie.name);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in byKind.entries)
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${l.savesFamilyTie(entry.key, entry.value.length)} ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: t.muted,
                    ),
                  ),
                  TextSpan(
                    text: entry.value.join(', '),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: t.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// "cooking 7" - a skill or personality value on the games' own ten-point
/// display scale (stored as 0-1000).
class _PointChip extends StatelessWidget {
  const _PointChip({
    required this.theme,
    required this.label,
    required this.value,
    required this.accent,
  });

  final GameTheme theme;
  final String label;
  final int value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final points = (value / 100).floor().clamp(0, 10);
    final shown = points == 0 ? '<1' : '$points';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: accent ? t.tint : t.surfaceAlt,
        border: Border.all(color: accent ? t.accent : t.border, width: 1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '$label $shown',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: accent ? t.accent : t.muted,
        ),
      ),
    );
  }
}

class _BondRow extends StatelessWidget {
  const _BondRow({required this.theme, required this.bond});

  final GameTheme theme;
  final SaveRelationship bond;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    final score = bond.score;
    final color = score >= 55
        ? t.accent
        : score >= 0
            ? t.accent2
            : t.warning;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${bond.nameA} & ${bond.nameB}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: t.text,
                ),
              ),
            ),
            for (final key in bond.labelKeys.take(2))
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  l.savesRelationshipFlag(key),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: t.accent,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 5,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(color: t.border),
                  // -100..100 drawn from the middle: warmth to the right,
                  // grudges to the left.
                  Positioned(
                    left: score >= 0
                        ? constraints.maxWidth / 2
                        : constraints.maxWidth / 2 * (1 + score / 100),
                    width: constraints.maxWidth / 2 * (score.abs() / 100),
                    top: 0,
                    bottom: 0,
                    child: Container(color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Album

class _AlbumTab extends StatelessWidget {
  const _AlbumTab(
      {required this.theme, required this.controller, required this.save});

  final GameTheme theme;
  final AppController controller;
  final SaveGame save;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final photos = save.photos;
    final index = c.savesPhotoIndex.clamp(0, photos.length - 1);
    final hero = photos[index];
    final caption = hero.caption;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final railWidth = constraints.maxWidth > 760 ? 300.0 : 224.0;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: t.surfaceAlt,
                          border: Border.all(color: t.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _photoImage(hero, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                caption != null && caption.isNotEmpty
                                    ? caption
                                    : l.savesPhotoKind(hero.kindKey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: t.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  l.savesPhotoKind(hero.kindKey),
                                  if (hero.modifiedAt != null)
                                    _savedDate(hero.modifiedAt),
                                ].join(' · '),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: t.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hero.path != null)
                          OutlinedButton(
                            style: accentButtonStyle(t),
                            onPressed: () => c.revealInFileManager(hero.path!),
                            child: Text(l.savesShowInFolder),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: railWidth,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: railWidth > 260 ? 2 : 1,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, i) {
                    final photo = photos[i];
                    final active = i == index;
                    return HoverBuilder(
                      cursor: SystemMouseCursors.click,
                      builder: (context, hovered) => GestureDetector(
                        onTap: () => c.selectSavePhoto(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: active
                                  ? t.accent
                                  : hovered
                                      ? t.muted
                                      : t.border,
                              width: active ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              _photoImage(photo, fit: BoxFit.cover, width: 220),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _photoImage(SavePhoto photo, {required BoxFit fit, int? width}) {
    final fallback = StripeThumb(seed: photo.caption ?? photo.kindKey);
    final bytes = photo.bytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        cacheWidth: width,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    final path = photo.path;
    if (path != null) {
      return Image.file(
        File(path),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        cacheWidth: width,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return fallback;
  }
}

// ---------------------------------------------------------------------------
// Stats

class _StatsTab extends StatelessWidget {
  const _StatsTab(
      {required this.theme, required this.controller, required this.save});

  final GameTheme theme;
  final AppController controller;
  final SaveGame save;

  static const _ageOrder = [
    'infant',
    'baby',
    'toddler',
    'child',
    'teen',
    'youngAdult',
    'adult',
    'elder',
  ];

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);

    final sims = save.sims.toList();
    final played = save.households.where((h) => h.isPlayed).length;
    var netWorth = 0;
    var hasFunds = false;
    for (final household in save.households) {
      final funds = household.funds;
      if (funds != null) {
        netWorth += funds;
        hasFunds = true;
      }
    }
    final ages = <String, int>{};
    for (final sim in sims) {
      final age = sim.ageKey;
      if (age != null) ages[age] = (ages[age] ?? 0) + 1;
    }
    final bestSkills = <String, int>{};
    for (final sim in sims) {
      for (final entry in sim.skills.entries) {
        if (entry.value > (bestSkills[entry.key] ?? 0)) {
          bestSkills[entry.key] = entry.value;
        }
      }
    }
    final topSkills = bestSkills.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final kpis = <(String, String, String?)>[
      if (save.simCount > 0)
        (
          l.savesStatSims,
          '${save.simCount}',
          l.savesAcrossHouseholds(save.households.length)
        ),
      if (save.households.isNotEmpty)
        (
          l.savesStatHouseholds,
          '${save.households.length}',
          played > 0 ? l.savesPlayedCount(played) : null
        ),
      if (hasFunds) (l.savesStatNetWorth, _simoleons(netWorth), null),
      (
        l.savesSizeOnDisk,
        formatBytes(save.sizeBytes),
        save.backupCount > 0 ? l.savesBackups(save.backupCount) : null
      ),
      if (save.worldsVisited.isNotEmpty)
        (l.savesStatWorlds, '${save.worldsVisited.length}', null),
      if (save.photos.isNotEmpty)
        (l.savesStatPhotos, '${save.photos.length}', null),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 860
                ? 4
                : constraints.maxWidth > 560
                    ? 3
                    : 2;
            final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final (label, value, sub) in kpis)
                  SizedBox(
                    width: width,
                    child: _KpiCard(
                        theme: t, label: label, value: value, sub: sub),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        if (ages.isNotEmpty)
          _BarCard(
            theme: t,
            title: l.savesLifeStages,
            rows: [
              for (final age in _ageOrder)
                if (ages[age] case final count?)
                  (
                    l.savesAge(age),
                    count / sims.length,
                    '$count',
                  ),
            ],
          ),
        if (topSkills.isNotEmpty) ...[
          const SizedBox(height: 16),
          _BarCard(
            theme: t,
            title: l.savesTopSkills,
            rows: [
              for (final entry in topSkills.take(7))
                (
                  l.savesSkill(entry.key),
                  entry.value / 1000,
                  '${(entry.value / 100).floor().clamp(0, 10)}',
                ),
            ],
          ),
        ],
        if (save.worldsVisited.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InfoCard(
            theme: t,
            title: l.savesStatWorlds,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final world in save.worldsVisited)
                  TagChip(label: world, color: t.accent, background: t.tint),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _InfoCard(
          theme: t,
          title: l.savesSaveInfo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, value) in <(String, String)>[
                if (save.modifiedAt != null)
                  (l.savesLastSavedLabel, _savedDate(save.modifiedAt)),
                if (save.gameVersion != null)
                  (l.savesGameVersion, save.gameVersion!),
                if (save.description != null && save.description!.isNotEmpty)
                  (l.savesDescription, save.description!),
              ]) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: t.muted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      save.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        color: t.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: accentButtonStyle(t),
                    onPressed: () => controller.revealInFileManager(save.path),
                    child: Text(l.savesShowInFolder),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.theme,
    required this.label,
    required this.value,
    this.sub,
  });

  final GameTheme theme;
  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .6,
                color: t.muted,
              )),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: t.text,
              height: 1.05,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(
              sub!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: t.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BarCard extends StatelessWidget {
  const _BarCard(
      {required this.theme, required this.title, required this.rows});

  final GameTheme theme;
  final String title;

  /// (label, 0..1 fill, value text)
  final List<(String, double, String)> rows;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return _InfoCard(
      theme: t,
      title: title,
      child: Column(
        children: [
          for (final (label, fraction, value) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 104,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: t.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(
                        height: 9,
                        child: Stack(
                          children: [
                            Container(color: t.surfaceAlt),
                            // Positioned.fill, because a non-positioned child
                            // of a Stack is laid out loose and the fill would
                            // take constraints.smallest - no height at all.
                            Positioned.fill(
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: fraction.clamp(0.02, 1),
                                child: DecoratedBox(
                                  decoration:
                                      BoxDecoration(gradient: t.accentGradient),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 30,
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: t.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(
      {required this.theme, required this.title, required this.child});

  final GameTheme theme;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      padding: const EdgeInsets.fromLTRB(19, 16, 19, 12),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: t.text,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

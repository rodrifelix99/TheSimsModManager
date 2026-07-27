// The games The Exchange accepts, in release order, with the ids the app's own
// adapters use. Titles stay English everywhere, the way the app shows them.
export const games = [
  { id: 'sims1', name: 'The Sims' },
  { id: 'sims2', name: 'The Sims 2' },
  { id: 'sims3', name: 'The Sims 3' },
  { id: 'simsmedieval', name: 'The Sims Medieval' },
  { id: 'sims4', name: 'The Sims 4' },
];

export const gameNames: Record<string, string> = Object.fromEntries(
  games.map((game) => [game.id, game.name]),
);

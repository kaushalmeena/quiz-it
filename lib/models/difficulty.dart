/// Question difficulty as understood by the Open Trivia Database.
///
/// [any] is only meaningful as a filter; questions always have a concrete one.
enum Difficulty {
  any('Any'),
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const Difficulty(this.label);

  final String label;

  static Difficulty parse(String? value) {
    return Difficulty.values.firstWhere(
      (difficulty) => difficulty.name == value,
      orElse: () => Difficulty.any,
    );
  }
}

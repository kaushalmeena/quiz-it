/// Answer format of a question.
///
/// [any] is only meaningful as a filter; questions always have a concrete one.
enum QuestionType {
  any('Any'),
  multiple('Multiple'),
  boolean('True / False');

  const QuestionType(this.label);

  final String label;

  static QuestionType parse(String? value) {
    return QuestionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => QuestionType.any,
    );
  }
}

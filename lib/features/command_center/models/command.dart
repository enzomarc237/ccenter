class Command {
  final String id;
  final String title;
  final String description;
  final String category;
  final Function() onExecute;

  const Command({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.onExecute,
  });
}

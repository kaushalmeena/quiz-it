import 'package:flutter/material.dart';

import '../models/category.dart';

/// Categories offered by the Open Trivia Database, with display names and icons.
const categories = [
  Category(id: null, name: 'Any category', icon: Icons.shuffle_rounded),
  Category(id: 9, name: 'General Knowledge', icon: Icons.lightbulb_outline),
  Category(id: 10, name: 'Books', icon: Icons.menu_book_outlined),
  Category(id: 11, name: 'Film', icon: Icons.movie_outlined),
  Category(id: 12, name: 'Music', icon: Icons.music_note_outlined),
  Category(id: 13, name: 'Musicals & Theatres', icon: Icons.theater_comedy),
  Category(id: 14, name: 'Television', icon: Icons.tv_outlined),
  Category(id: 15, name: 'Video Games', icon: Icons.sports_esports_outlined),
  Category(id: 16, name: 'Board Games', icon: Icons.casino_outlined),
  Category(id: 17, name: 'Science & Nature', icon: Icons.science_outlined),
  Category(id: 18, name: 'Computers', icon: Icons.computer_outlined),
  Category(id: 19, name: 'Mathematics', icon: Icons.calculate_outlined),
  Category(id: 20, name: 'Mythology', icon: Icons.auto_awesome_outlined),
  Category(id: 21, name: 'Sports', icon: Icons.sports_soccer_outlined),
  Category(id: 22, name: 'Geography', icon: Icons.public),
  Category(id: 23, name: 'History', icon: Icons.history_edu_outlined),
  Category(id: 24, name: 'Politics', icon: Icons.account_balance_outlined),
  Category(id: 25, name: 'Art', icon: Icons.palette_outlined),
  Category(id: 26, name: 'Celebrities', icon: Icons.star_outline_rounded),
  Category(id: 27, name: 'Animals', icon: Icons.pets_outlined),
  Category(id: 28, name: 'Vehicles', icon: Icons.directions_car_outlined),
  Category(id: 29, name: 'Comics', icon: Icons.auto_stories_outlined),
  Category(id: 30, name: 'Gadgets', icon: Icons.devices_other_outlined),
  Category(id: 31, name: 'Anime & Manga', icon: Icons.animation),
  Category(
    id: 32,
    name: 'Cartoons & Animation',
    icon: Icons.emoji_emotions_outlined,
  ),
];

Category categoryById(int? id) {
  return categories.firstWhere(
    (category) => category.id == id,
    orElse: () => categories.first,
  );
}

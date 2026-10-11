import 'package:flutter/material.dart';

import 'hero_icon.dart';

final class CategoryIconOption {
  const CategoryIconOption(this.key, this.asset, this.pl, this.en);
  final String key, asset, pl, en;
  String label(String language) => language == 'en' ? en : pl;
}

const categoryIconOptions = <CategoryIconOption>[
  CategoryIconOption('WALLET', 'wallet', 'Portfel', 'Wallet'),
  CategoryIconOption('CART', 'shopping_cart', 'Zakupy', 'Shopping'),
  CategoryIconOption('BAG', 'shopping_bag', 'Torba', 'Bag'),
  CategoryIconOption('BOOK', 'book_open', 'Książki', 'Books'),
  CategoryIconOption('MUSIC', 'musical_note', 'Muzyka', 'Music'),
  CategoryIconOption('CAKE', 'cake', 'Jedzenie', 'Food'),
  CategoryIconOption('CAMERA', 'camera', 'Zdjęcia', 'Photos'),
  CategoryIconOption('SPARKLES', 'sparkles', 'Inne', 'Other'),
  CategoryIconOption('HOME', 'home', 'Dom', 'Home'),
  CategoryIconOption('SHOP', 'building_storefront', 'Sklepy', 'Stores'),
  CategoryIconOption('TRANSPORT', 'truck', 'Transport', 'Transport'),
  CategoryIconOption('TICKET', 'ticket', 'Bilety', 'Tickets'),
  CategoryIconOption('TRAVEL', 'globe_alt', 'Podróże', 'Travel'),
  CategoryIconOption('HEALTH', 'heart', 'Zdrowie', 'Health'),
  CategoryIconOption('MEDICINE', 'beaker', 'Leki', 'Medicine'),
  CategoryIconOption('CHILDREN', 'face_smile', 'Dzieci', 'Children'),
  CategoryIconOption('FAMILY', 'user_group', 'Rodzina', 'Family'),
  CategoryIconOption('SPORT', 'trophy', 'Sport', 'Sports'),
  CategoryIconOption('RECREATION', 'lifebuoy', 'Rekreacja', 'Recreation'),
  CategoryIconOption('GIFTS', 'gift', 'Prezenty', 'Gifts'),
  CategoryIconOption('PHONE', 'device_phone_mobile', 'Telefon', 'Phone'),
  CategoryIconOption('COMPUTER', 'computer_desktop', 'Komputer', 'Computer'),
  CategoryIconOption('REPAIRS', 'wrench_screwdriver', 'Naprawy', 'Repairs'),
  CategoryIconOption('ELECTRICITY', 'bolt', 'Prąd', 'Electricity'),
  CategoryIconOption('HEATING', 'fire', 'Ogrzewanie', 'Heating'),
  CategoryIconOption('EDUCATION', 'academic_cap', 'Nauka', 'Education'),
  CategoryIconOption('WORK', 'briefcase', 'Praca', 'Work'),
  CategoryIconOption('BANK', 'building_library', 'Bank', 'Bank'),
  CategoryIconOption('CASH', 'banknotes', 'Gotówka', 'Cash'),
  CategoryIconOption('CARD', 'credit_card', 'Karta', 'Card'),
  CategoryIconOption('DISCOUNTS', 'receipt_percent', 'Rabaty', 'Discounts'),
  CategoryIconOption('FILM', 'film', 'Kino', 'Cinema'),
  CategoryIconOption('TV', 'tv', 'Telewizja', 'Television'),
  CategoryIconOption('GAMES', 'puzzle_piece', 'Gry', 'Games'),
  CategoryIconOption('ART', 'paint_brush', 'Sztuka', 'Art'),
  CategoryIconOption('HAIRCUT', 'scissors', 'Fryzjer', 'Hairdresser'),
  CategoryIconOption('HOLIDAYS', 'sun', 'Wakacje', 'Holidays'),
  CategoryIconOption('PLACES', 'map_pin', 'Miejsca', 'Places'),
  CategoryIconOption('PACKAGES', 'cube', 'Przesyłki', 'Packages'),
  CategoryIconOption('ANIMALS', 'bug_ant', 'Zwierzęta', 'Animals'),
];

CategoryIconOption categoryIcon(String key) => categoryIconOptions.firstWhere(
  (icon) => icon.key == key,
  orElse: () => categoryIconOptions.first,
);

class StoredCategoryIcon extends StatelessWidget {
  const StoredCategoryIcon(this.id, {super.key, this.size = 24, this.color});
  final String id;
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) =>
      HeroIcon(categoryIcon(id).asset, size: size, color: color);
}

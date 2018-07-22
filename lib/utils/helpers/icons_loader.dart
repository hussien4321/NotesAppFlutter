import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

enum EmojiCategory {
  ACTIVITIES,
  FLAGS,
  FOOD,
  NATURE,
  OBJECTS,
  PEOPLE,
  SYMBOLS,
  TRAVEL
}
//[{"order":1,"category":"people","category_label":"Smileys & People"},{"order":2,"category":"nature","category_label":"Animals & Nature"},{"order":3,"category":"food","category_label":"Food & Drink"},{"order":4,"category":"activity","category_label":"Activity"},{"order":5,"category":"travel","category_label":"Travel & Places"},{"order":6,"category":"objects","category_label":"Objects"},{"order":7,"category":"symbols","category_label":"Symbols"},{"order":8,"category":"flags","category_label":"Flags"}]

class EmojiLoader {

  static final int ACTIVITIES_SIZE = 89;
  static final int FLAGS_SIZE = 267;
  static final int FOOD_SIZE = 99;
  static final int NATURE_SIZE = 165;
  static final int OBJECTS_SIZE = 174;
  static final int PEOPLE_SIZE = 327;
  static final int SYMBOLS_SIZE = 273;
  static final int TRAVEL_SIZE = 120;


  static final String _iconLocation = 'assets/icons/';


  Map<String, dynamic> activities;
  Map<String, dynamic> flags;
  Map<String, dynamic> food;
  Map<String, dynamic> nature;
  Map<String, dynamic> objects;
  Map<String, dynamic> people;
  Map<String, dynamic> symbols;
  Map<String, dynamic> travel;

  initialise(BuildContext context) async {
    activities = json.decode(await DefaultAssetBundle.of(context).loadString('assets/data/activity_data.json'));
    flags = json.decode(await DefaultAssetBundle.of(context).loadString('assets/data/flags_data.json'));
    food = json.decode(await DefaultAssetBundle.of(context).loadString('assets/data/food_data.json'));
    nature = json.decode(await DefaultAssetBundle.of(context).loadString('assets/data/nature_data.json'));
    objects = json.decode(await DefaultAssetBundle.of(context).loadString('assets/data/objects_data.json'));
    people = json.decode(await DefaultAssetBundle.of(context).loadString('assets/data/people_data.json'));
    symbols = json.decode(await DefaultAssetBundle.of(context).loadString('assets/data/symbols_data.json'));
    travel = json.decode(await DefaultAssetBundle.of(context).loadString('assets/data/travel_data.json'));
  }

  Map<String, dynamic> _getCategoryDataFile(EmojiCategory category){
    switch (category) {
      case EmojiCategory.ACTIVITIES:
        return activities;
      case EmojiCategory.FLAGS:
        return flags;
      case EmojiCategory.FOOD:
        return food;
      case EmojiCategory.NATURE:
        return nature;
      case EmojiCategory.OBJECTS:
        return objects;
      case EmojiCategory.PEOPLE:
        return people;
      case EmojiCategory.SYMBOLS:
        return symbols;
      case EmojiCategory.TRAVEL:
        return travel;
      default:
        return null;
    }
  }

  String _categoryToString(EmojiCategory category){
    switch (category) {
      case EmojiCategory.ACTIVITIES:
        return 'activity';
      default:
        return '';
    }
  }
  String drawIcon(int id, EmojiCategory category) {

    print('id : '+id.toString()+ ' / '+category.toString());
    _EmojiData _emojiData = new _EmojiData.fromJson(_getCategoryDataFile(category)[id.toString()]);

    return _iconLocation+_emojiData.category+'/'+_emojiData.filename;
  }
}

class _EmojiData {

  String filename, category, keywords;

  _EmojiData(this.filename, this.category, this.keywords);

  _EmojiData.fromJson(Map<String, dynamic> json)
    : filename = json['filename'],
      category = json['category'],
      keywords = json['keywords'];

}


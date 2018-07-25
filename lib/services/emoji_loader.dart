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

  final List<EmojiCategory> listOfCategories = [
    EmojiCategory.PEOPLE,
    EmojiCategory.NATURE,
    EmojiCategory.FOOD,
    EmojiCategory.ACTIVITIES,
    EmojiCategory.TRAVEL,
    EmojiCategory.OBJECTS,
    EmojiCategory.SYMBOLS,
    EmojiCategory.FLAGS
  ];

  static final EmojiLoader _singleton = new EmojiLoader._internal();
  static BuildContext _context;

  factory EmojiLoader(BuildContext context) {
    _context = context;
    return _singleton;
    
  }

  EmojiLoader._internal() {
    DefaultAssetBundle.of(_context).loadString('assets/data/activity_data.json').then((res) => activities = json.decode(res));
    DefaultAssetBundle.of(_context).loadString('assets/data/flags_data.json').then((res) => flags = json.decode(res));
    DefaultAssetBundle.of(_context).loadString('assets/data/food_data.json').then((res) => food = json.decode(res));
    DefaultAssetBundle.of(_context).loadString('assets/data/nature_data.json').then((res) => nature = json.decode(res));
    DefaultAssetBundle.of(_context).loadString('assets/data/objects_data.json').then((res) => objects = json.decode(res));
    DefaultAssetBundle.of(_context).loadString('assets/data/people_data.json').then((res) => people = json.decode(res));
    DefaultAssetBundle.of(_context).loadString('assets/data/symbols_data.json').then((res) => symbols = json.decode(res));
    DefaultAssetBundle.of(_context).loadString('assets/data/travel_data.json').then((res) => travel = json.decode(res));
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

  String drawIcon(String id, EmojiCategory category) {

    _EmojiData _emojiData = new _EmojiData.fromJson(_getCategoryDataFile(category)[id]);

    return _iconLocation+_emojiData.category+'/'+_emojiData.filename;
  }

  List<String> searchIcon(String term) {
    List<String> results = [];
    
    listOfCategories.forEach((cat){
      _getCategoryDataFile(cat).forEach((key, value){
        if(value['keywords'].toString().contains(term)){
          results.add(drawIcon(key ,cat));
        }
      });
    });
    return results;
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


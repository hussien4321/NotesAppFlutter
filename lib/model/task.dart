class Task{

  int _id;
  String _name, _icon;
  bool _recommended;
  DateTime _creationDate;
  
  int get id => _id;
  String get icon => _icon;
  String get name => _name;
  bool get recommended => _recommended;
  DateTime get creationDate => _creationDate;

  Task(int id, String name, String icon, [bool recommended = false]){
    _id = id;
    _name = name;
    _icon = icon;
    _recommended = recommended;
    _creationDate = DateTime.now();
  }
  
  Task.fromJson(Map<String, dynamic> json)
      : _id = json['task_id'],
        _name = json['name'],
        _icon = json['icon'],
        _recommended = json['recommended'] == 'true',
        _creationDate = DateTime.parse(json['creation_date']);

}
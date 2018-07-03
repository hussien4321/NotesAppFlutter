class ToDo{

  String _name;
  DateTime _startDate;
  bool _status;
  
  String get name => _name;
  DateTime get startDate => _startDate;
  bool get status => _status;
  DateTime get deadline => _startDate.add(Duration(days: 1));

  ToDo(String name){
    _name = name;
    _startDate = DateTime.now();
    _status = false;
  }
  
  ToDo.fromJson(Map<String, dynamic> json)
      : _name = json['name'],
        _startDate = DateTime.parse(json['start_date']),
        _status = json['status'] == 'true';

  Map<String, dynamic> toJson() =>
    {
      'name': _name,
      'start_date': _startDate.toIso8601String(),
      'status' : _status.toString()
    };
}

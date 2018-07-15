class GraphData {
  DateTime _startDate;
  int _value;
  
  GraphData(DateTime startDate, int value){
    _startDate = new DateTime(startDate.year, startDate.month, startDate.day);
    _value = value;
  }

  DateTime get startDate => _startDate;
  int get value => _value;

  void setValue(int newValue){
    _value = newValue;
  }
}
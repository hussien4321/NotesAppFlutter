import 'package:flutter/material.dart';
import '../services/emoji_loader.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/faded_background.dart';
import '../utils/views/custom_grid_view.dart';
import 'package:flutter/services.dart' show rootBundle;

class EmojiSelectorPage extends StatefulWidget {
  @override
  EmojiSelectorPageState createState() => EmojiSelectorPageState();
}

class EmojiSelectorPageState extends State<EmojiSelectorPage> {

  EmojiLoader emojiLoader;
  TextEditingController controller;

  bool loading = true;
  EmojiCategory currentCategory = EmojiCategory.PEOPLE;
  
  String searchText;
  List<String> searchResults;

  @override
  initState(){
    initialise();
    controller = new TextEditingController()..addListener(_textListener);
    super.initState();
  }

  initialise() async {

    loading = true;
    emojiLoader = new EmojiLoader(context);
    searchText = "";
    searchResults = [];
    currentCategory = EmojiCategory.PEOPLE;
    setState(() {
      loading= false;
    });
  }

  
  @override
  void dispose() {
    controller.removeListener(_textListener);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading ? LoadingScreen() : Container(
        padding: EdgeInsets.only(top: 20.0),
        child: buildGrids(),
      ),
    );
  }

  Widget buildGrids() {
    return  Container( 
        padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 15.0),
            child: Center(
              child: Text(
                'Select an Emoji', 
                style: TextStyle(
                  fontWeight: FontWeight.w300, fontSize: 30.0,
                ),
              ),
            ),
          ),
          subHeader('Categories:'),
          Row(
            children: <Widget>[
              categoryButton(name: '😃', category: EmojiCategory.PEOPLE, radius: BorderRadius.only(topLeft: Radius.circular(10.0))),
              categoryButton(name: '🐻', category: EmojiCategory.NATURE),
              categoryButton(name: '🍔', category: EmojiCategory.FOOD),
              categoryButton(name: '⚽', category: EmojiCategory.ACTIVITIES, radius: BorderRadius.only(topRight: Radius.circular(10.0))),
            ],
          ),
          Row(
            children: <Widget>[
              categoryButton(name: '🌇', category: EmojiCategory.TRAVEL, radius: BorderRadius.only(bottomLeft: Radius.circular(10.0))),
              categoryButton(name: '💡', category: EmojiCategory.OBJECTS),
              categoryButton(name: '🔣', category: EmojiCategory.SYMBOLS),
              categoryButton(name: '🎌', category: EmojiCategory.FLAGS, radius: BorderRadius.only(bottomRight: Radius.circular(10.0))),
            ],
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Search here'
                    ),
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                ),
                IconButton(
                  onPressed: (){
                    controller.clear();
                    setState(() {
                      searchText = '';
                    });
                  },
                  icon: Icon(searchText.length ==0 ? Icons.search : Icons.backspace),
                )
              ],
            ),
          ),
          (searchText.length == 0) ?
          Expanded(
            child: Container(
              child: Column(
                children: <Widget>[
                  (currentCategory == EmojiCategory.PEOPLE) ? 
                  CustomGridView(emojiLoader, EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE, show: currentCategory == EmojiCategory.PEOPLE) : Container(),
                  (currentCategory == EmojiCategory.NATURE) ? 
                  CustomGridView(emojiLoader, EmojiLoader.NATURE_SIZE, EmojiCategory.NATURE, show: currentCategory == EmojiCategory.NATURE,) : Container(),
                  (currentCategory == EmojiCategory.FOOD) ? 
                  CustomGridView(emojiLoader, EmojiLoader.FOOD_SIZE, EmojiCategory.FOOD, show: currentCategory == EmojiCategory.FOOD,) : Container(),
                  (currentCategory == EmojiCategory.ACTIVITIES) ? 
                  CustomGridView(emojiLoader, EmojiLoader.ACTIVITIES_SIZE, EmojiCategory.ACTIVITIES, show: currentCategory == EmojiCategory.ACTIVITIES,) : Container(),
                  (currentCategory == EmojiCategory.TRAVEL) ? 
                  CustomGridView(emojiLoader, EmojiLoader.TRAVEL_SIZE, EmojiCategory.TRAVEL, show: currentCategory == EmojiCategory.TRAVEL,) : Container(),
                  (currentCategory == EmojiCategory.OBJECTS) ? 
                  CustomGridView(emojiLoader, EmojiLoader.OBJECTS_SIZE, EmojiCategory.OBJECTS, show: currentCategory == EmojiCategory.OBJECTS,) : Container(),
                  (currentCategory == EmojiCategory.SYMBOLS) ? 
                  CustomGridView(emojiLoader, EmojiLoader.SYMBOLS_SIZE, EmojiCategory.SYMBOLS, show: currentCategory == EmojiCategory.SYMBOLS,) : Container(),
                  (currentCategory == EmojiCategory.FLAGS) ? 
                  CustomGridView(emojiLoader, EmojiLoader.FLAGS_SIZE, EmojiCategory.FLAGS, show: currentCategory == EmojiCategory.FLAGS,) : Container(),
                ],
              ),
            ),
          ):
          (searchText.length < 3) ? Center(child: Text('Search is too short, keep typing ⌨️'),) :
          (searchResults.length == 0 ) ? Center(child: Text('No results found 😭'),) :
          CustomGridView(emojiLoader, searchResults.length, null, show: searchText.length > 0 , preLoadedData: searchResults,),
        ], 
      ),
    );
  }

  Widget categoryButton({String name, EmojiCategory category, BorderRadius radius}){
    bool isCurrentCat = currentCategory == category;
    return Expanded(
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: radius == null ? BorderRadius.circular(0.0) : radius
        ), 
        onPressed: (searchText.length > 0 || isCurrentCat) ? null : () {
          setState(() {
            currentCategory = category;         
          });
        },
        child: Text(name),
        color: Colors.orange,
      ),
    );
  }

  Widget subHeader(String text){
    return Container(
      padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 18.0, color: Colors.orange[800]),
        textAlign: TextAlign.start,
      ),
    );
  }


  
  void _textListener() {
    String newText = controller.text;
    List<String> newResutls = []; 
    if(newText.length > 2){
      newResutls= emojiLoader.searchIcon(newText.toLowerCase());
    }
    else{
      newResutls = [];
    }

    setState(() {
      searchText = newText;
      searchResults = newResutls;
    });
  }

}
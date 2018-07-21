import 'package:flutter/material.dart';
import '../utils/helpers/icons_loader.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/faded_background.dart';
import 'package:flutter/services.dart' show rootBundle;

class EmojiSelectorPage extends StatefulWidget {
  @override
  EmojiSelectorPageState createState() => EmojiSelectorPageState();
}

class EmojiSelectorPageState extends State<EmojiSelectorPage> {

  EmojiLoader emojiLoader = new EmojiLoader();

  bool loading = true;
  
  @override
  initState(){
    super.initState();
    initialise();
  }

  initialise() async {

    loading = true;
    await emojiLoader.initialise(context);
    setState(() {
      loading= false;
    });
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


  //todo: ADD LAZY LOADING (SILVERGRIDVIEW LISTS?) (SCROLL CONTROLLERS?)
  Widget buildGrids() {
    return SingleChildScrollView(
      child: Container( 
        padding: EdgeInsets.all(10.0),
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
          // subHeader('Smileys & People'),
          // _buildGridTileList(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          // subHeader('Animals & Nature'),
          // _buildGridTileList(EmojiLoader.NATURE_SIZE, EmojiCategory.NATURE),
          subHeader('Food & Drink'),
          _buildGridTileList(EmojiLoader.FOOD_SIZE, EmojiCategory.FOOD),
          // subHeader('Activity'),
          // _buildGridTileList(EmojiLoader.ACTIVITIES_SIZE, EmojiCategory.ACTIVITIES),
          // subHeader('Travel & Places'),
          // _buildGridTileList(EmojiLoader.TRAVEL_SIZE, EmojiCategory.TRAVEL),
          // subHeader('Objects'),
          // _buildGridTileList(EmojiLoader.OBJECTS_SIZE, EmojiCategory.OBJECTS),
          // subHeader('Symbols'),
          // _buildGridTileList(EmojiLoader.SYMBOLS_SIZE, EmojiCategory.SYMBOLS),
          // subHeader('Flags'),
          // _buildGridTileList(EmojiLoader.FLAGS_SIZE, EmojiCategory.FLAGS),
        ], 
      ),
      ),
    );
  }

  Widget subHeader(String text){
    return Container(
      padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 18.0, color: Colors.orange[800], fontWeight: FontWeight.bold),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildGridTileList(int count, EmojiCategory category) {
   return Center(
    child: 
    
      Wrap(
      spacing: 15.0,
      runSpacing: 15.0,
      direction: Axis.horizontal, 
      children: List<Widget>.generate(
        count,
        (int index) =>
          Material(
            color: Colors.transparent,
            child: new InkWell(
              splashColor: Colors.grey,
              onTap: () => print(index.toString()+' selected! '+category.toString()),
              child: Image.asset (
                  emojiLoader.drawIcon(index + 1, category),
                  height: 32.0,
                  width: 32.0,
                ),
            )
          )
      ),
    ),
   );
  }
}
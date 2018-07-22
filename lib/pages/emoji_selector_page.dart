import 'package:flutter/material.dart';
import '../utils/helpers/icons_loader.dart';
import '../utils/views/loading_screen.dart';
import '../utils/views/faded_background.dart';
import '../utils/views/custom_grid_view.dart';
import 'package:flutter/services.dart' show rootBundle;

class EmojiSelectorPage extends StatefulWidget {
  @override
  EmojiSelectorPageState createState() => EmojiSelectorPageState();
}

class EmojiSelectorPageState extends State<EmojiSelectorPage> {

  EmojiLoader emojiLoader = new EmojiLoader();
  ScrollController controller;

  bool loading = true;
  EmojiCategory currentCategory = EmojiCategory.PEOPLE;
  
  @override
  initState(){
    initialise();
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  initialise() async {

    loading = true;
    currentCategory = EmojiCategory.PEOPLE;
    await emojiLoader.initialise(context);
    setState(() {
      loading= false;
    });
  }

  
  @override
  void dispose() {
    controller.removeListener(_scrollListener);
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


  //todo: ADD LAZY LOADING (SILVERGRIDVIEW LISTS?) (SCROLL CONTROLLERS?)
  Widget buildGrids() {
    return  Container( 
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
          // SizedBox(
          //   height: 400.0,
          //  child: CustomScrollView(
          //    controller: controller,
          //   slivers: <Widget>[
          //     // subHeader('Smileys & People'),
          //     justGridSliver(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          //     justGridSliver(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          //     justGridSliver(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          //     justGridSliver(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          //     justGridSliver(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          //     justGridSliver(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          //     justGridSliver(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          //     justGridSliver(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          //     justGridSliver(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          //     justGridSliver(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          //   ],
          // ),
          // )
          // subHeader('Smileys & People'),
          // _buildGridTileList(EmojiLoader.PEOPLE_SIZE, EmojiCategory.PEOPLE),
          // subHeader('Animals & Nature'),
          // _buildGridTileList(EmojiLoader.NATURE_SIZE, EmojiCategory.NATURE),
          // subHeader('Food & Drink'),
          // listImplementation(EmojiLoader.FOOD_SIZE, EmojiCategory.FOOD),
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
    );
  }

  Widget categoryButton({String name, EmojiCategory category, BorderRadius radius}){
    bool isCurrentCat = currentCategory == category;
    return Expanded(
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: radius == null ? BorderRadius.circular(0.0) : radius
        ), 
        onPressed: isCurrentCat ? null : () {
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
        style: TextStyle(fontSize: 18.0, color: Colors.orange[800], fontWeight: FontWeight.bold),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildGridTileList(int count, EmojiCategory category) {
   return Center(
    child: wrapImplementation(count, category),
   );
  }

  Widget listImplementation(int count, EmojiCategory category){
    return SizedBox(
      height: 300.0,
      child: CustomScrollView(
      slivers:<Widget>[ SliverGrid.extent(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this would produce 2 rows.
      maxCrossAxisExtent: 32.0,
      mainAxisSpacing: 15.0,
      // Generate 100 Widgets that display their index in the List
      children: List.generate(count, (index) {
        return Container(
          child: Material(
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
        );
      }),
    )
      ])
    );

  }

  Widget justGridSliver(int count, EmojiCategory category){
    return SliverGrid.extent(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this would produce 2 rows.
      maxCrossAxisExtent: 32.0,
      mainAxisSpacing: 15.0,
      // Generate 100 Widgets that display their index in the List
      children: List.generate(count, (index) {
        return Container(
          // child: Material(
          //   color: Colors.transparent,
          //   child: new InkWell(
          //     splashColor: Colors.grey,
          //     onTap: () => print(index.toString()+' selected! '+category.toString()),
          //     child: Image.asset (
          //         emojiLoader.drawIcon(index + 1, category),
          //         height: 32.0,
          //         width: 32.0,
          //       ),
          //   )
          // )
        );
      }),
    );
  }

  
  void _scrollListener() {
    print('P = '+controller.position.extentAfter.toString() + ' : ' + controller.position.extentInside.toString() + ' : ' + controller.position.extentBefore.toString());
    print('O = '+controller.position.maxScrollExtent.toString() + ' : ' + controller.position.minScrollExtent.toString()+ ' : ' + controller.position.viewportDimension .toString() + ' : ' + controller.offset.toString() +' : '+ controller.initialScrollOffset.toString());
    // if (controller.position.extentAfter < 500) {
    //   //add stuff
    // }
  }

  Widget wrapImplementation(int count, EmojiCategory category){
    return Wrap(
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
      )
    );
  }
}
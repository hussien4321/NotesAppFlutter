import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/emoji_loader.dart';
import 'dart:io' show Platform;

class CustomGridView extends StatefulWidget {
  
  EmojiLoader _emojiLoader;
  int _count;
  EmojiCategory _category;
  bool show;
  List<String> preLoadedData;


  CustomGridView(this._emojiLoader, this._count, this._category, {this.show = true, this.preLoadedData});
  
  @override
  _CustomGridViewState createState() => _CustomGridViewState();
}

class _CustomGridViewState extends State<CustomGridView> {

  ScrollController controller;
  final double itemSize = 32.0;
  final double itemSpacing = 10.0;
  final double scrollSize = 300.0;
  final double startingSize = 100.0;
  final int renderingBuffer = 20;

  int startIndex;
  int endIndex;

  bool isIOS;
  @override
  initState(){
    if(startIndex == null && endIndex == null){
      startIndex = 0;
      endIndex = 100;
    }
    isIOS = Platform.isIOS;
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }
  
  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }


  void _scrollListener() {
  

    double spaceBefore = controller.position.extentBefore;
    double scrollSize = controller.position.extentInside;
    double maxSize = controller.position.maxScrollExtent + scrollSize;

    double startPercentage = spaceBefore == 0 ? 0.0 :spaceBefore / maxSize;
    double endPercentage = (spaceBefore + scrollSize) == 0 ? 0.0 : (spaceBefore + scrollSize) / maxSize;

    int sizeOfList = widget._count - 1;
    int newStartIndex = (startPercentage * sizeOfList).floor() - renderingBuffer;
    if(newStartIndex < 0){
      newStartIndex = 0;
    }
    int newEndIndex = (endPercentage * sizeOfList).floor() + renderingBuffer;
    if(newEndIndex > sizeOfList){
      newEndIndex = sizeOfList;
    }

    if(startIndex != newStartIndex || endIndex != newEndIndex){
      setState(() {
        startIndex = newStartIndex;
        endIndex = newEndIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return !widget.show || !mounted ? Container() :
      Expanded( 
      child: CustomScrollView(
        controller: controller,
        slivers:<Widget>[ 
          SliverGrid.extent(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this would produce 2 rows.
            maxCrossAxisExtent: itemSize+(itemSpacing*2),
            mainAxisSpacing: 0.0,
            crossAxisSpacing: 0.0,
            // Generate 100 Widgets that display their index in the List
            children: List.generate(widget._count, (index) {
              return (isIOS || (index >= startIndex && index <= endIndex)) ? Container(
                child: Material(
                  color: Colors.transparent,
                  child: new InkWell(
                    splashColor: Colors.grey,
                    onTap: () {
                      String resultToBe = widget.preLoadedData == null ? widget._emojiLoader.drawIcon((index + 1).toString(), widget._category) : widget.preLoadedData[index];
                      return Navigator.of(context).pop(resultToBe);
                    },
                    child:  Container(
                      padding: EdgeInsets.all(itemSpacing),
                      child: Image.asset (
                        widget.preLoadedData == null ? widget._emojiLoader.drawIcon((index + 1).toString(), widget._category) : widget.preLoadedData[index],
                        height: itemSize,
                        width: itemSize,
                      ),
                    ),
                  )
                )
              ) : Container();
            }),
          )
        ]
      ),
    );
  }
}
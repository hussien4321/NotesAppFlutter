import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              settingsHeader('App settings'),
              settingsOption('Reset data', RaisedButton(
                  onPressed: () {
                    //Reset data function
                  },
                  child: Text(
                    'RESET',
                    style: TextStyle(color: Colors.white), 
                  ),
                  color: Colors.orangeAccent,
                ),
              ),
              settingsOption('Change language', IconButton(
                  icon: Icon(FontAwesomeIcons.globe),
                  iconSize: 20.0,
                ),
              ),
              settingsHeader('Notifications'),
              settingsOption('Turn on notifications', Switch(
                value: false,
                onChanged: (status) => print('switched to '+status.toString()),
              )),
              settingsOption('Notify 3 hours before deadline', RaisedButton(
                  onPressed: () {
                    //Switch to a separate column slider for time change
                  },
                  child: Text(
                    'Modify',
                    style: TextStyle(color: Colors.white), 
                  ),
                  color: Colors.orangeAccent,
                ),
              ),
              settingsHeader('In-app purchases'),
              settingsOption('Disable ads', RaisedButton(
                  onPressed: () {
                    //LINK TO DISABLING ADS
                  },
                  child: Text(
                    '£0.99',
                    style: TextStyle(color: Colors.white), 
                  ),
                  color: Colors.orangeAccent,
                ),
              ),
              settingsHeader('Social media'),
              settingsOption('Follow us on twitter  @24h_tasks', IconButton(
                icon: Icon(FontAwesomeIcons.twitter),
                iconSize: 20.0,
                onPressed: () {
                  //LINK TO TWITTER
                },
              )),
              settingsOption('Share this to friends', IconButton(
                icon: Icon(Icons.share),
                iconSize: 20.0,
                onPressed: () {
                    final RenderBox box = context.findRenderObject();
                    Share.share('Check out this great app that helps get your daily tasks done! WWW.WEBSITELINK.COM',
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) &
                                box.size);
                  },
              )),
            ],
          )
        ],
      )
    );
  }

  Widget settingsHeader(String headerText){
    return Container(
      padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0, top: 10.0),
      child: Text(
        headerText,
        style: TextStyle(color: Colors.orange[900],fontWeight: FontWeight.bold, fontSize: 20.0,),
      ),
    );
  }

  Widget settingsOption(String optionText, Widget button){
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            optionText,
            style: TextStyle(fontSize: 17.0),
          ),
        ),
        button,
      ],
    );
  }
}

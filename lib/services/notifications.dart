import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../model/todo.dart';

//TODO: Make singleton
class NotificationService {

  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static NotificationDetails _platformChannelSpecifics;

  static final NotificationService _singleton = new NotificationService._internal();

  factory NotificationService() {
    return _singleton;
  }

  NotificationService._internal(){
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      '24h_tasks_channel_id',
      'Productivity',
      'Notifies user of upcoming task deadlines',
      icon: 'timer',
      color: Colors.orange,
      playSound: false,
      importance: Importance.Low, 
      priority: Priority.Low);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails();
    _platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  createNotification(ToDo todo, int delayInHours) async {


    await _flutterLocalNotificationsPlugin.cancel(todo.id);

    var scheduledNotificationDateTime =
      todo.startDate.add(new Duration(days: 1)).subtract(new Duration(hours: delayInHours));

    if(scheduledNotificationDateTime.isAfter(DateTime.now())){
      String header = todo.task.name+'!';
      String message = 'Only '+ delayInHours.toString()+(delayInHours == 1 ? ' hour' : ' hours')+' left till deadline. Don\'t forget!';
      await _flutterLocalNotificationsPlugin.schedule(
          todo.id,
          header,
          message,
          scheduledNotificationDateTime,
          _platformChannelSpecifics);
    }
  }

  cancelNotification(ToDo todo) async {
    await _flutterLocalNotificationsPlugin.cancel(todo.id);
  }

  cancelOpenNotifications(List<ToDo> todos, int delayInHours) async {
    for(int i = 0; i< todos.length; i++){
      DateTime notificationTime = todos[i].startDate.add(new Duration(days: 1)).subtract(new Duration(hours:  delayInHours));
      if(notificationTime.isBefore(DateTime.now())){
        cancelNotification(todos[i]);
      }
    }
  }

  cancelAllNotifications() async{
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  updateNotifications(List<ToDo> todos, int newDelayInHours){    
    for(int i = 0; i< todos.length; i++){
      createNotification(todos[i], newDelayInHours);
    }
  }
  

  

}
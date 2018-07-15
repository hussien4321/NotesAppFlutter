import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../model/todo.dart';

//TODO: Make singleton
class NotificationService {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  BuildContext context;
  NotificationDetails platformChannelSpecifics;

  initService(){
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
    platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  }

  createNotification(ToDo todo, int delayInHours) async {


    await flutterLocalNotificationsPlugin.cancel(todo.id);

    var scheduledNotificationDateTime =
      todo.startDate.add(new Duration(days: 1)).subtract(new Duration(hours: delayInHours));

    if(scheduledNotificationDateTime.isAfter(DateTime.now())){
      String header = todo.task.icon+' deadline approaching!';
      String message = '"'+todo.task.name+'" only has '+delayInHours.toString()+' hour'+(delayInHours == 1 ? '' : 's')+' remaining. Dont forget to complete it!';
      await flutterLocalNotificationsPlugin.schedule(
          todo.id,
          header,
          message,
          scheduledNotificationDateTime,
          platformChannelSpecifics);
    }
  }

  cancelNotification(ToDo todo) async {
    await flutterLocalNotificationsPlugin.cancel(todo.id);
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
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  updateNotifications(List<ToDo> todos, int newDelayInHours){    
    for(int i = 0; i< todos.length; i++){
      createNotification(todos[i], newDelayInHours);
    }
  }
  

  

}
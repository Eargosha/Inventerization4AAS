part of 'notification_cubit.dart';

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationAdded extends NotificationState {
  final InvNotification notification;
  final List<InvNotification> allNotifications;

  NotificationAdded(this.notification, this.allNotifications);
}

class NotificationUpdated extends NotificationState {
  final List<InvNotification> notifications;

  NotificationUpdated(this.notifications);
}
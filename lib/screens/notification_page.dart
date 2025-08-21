import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventerization_4aas/constants/theme/app_text_styles.dart';
import 'package:inventerization_4aas/cubit/notification/notification_cubit.dart';
import 'package:inventerization_4aas/models/notification_model.dart';
import 'package:inventerization_4aas/screens/widgets/app_bar.dart';
import 'package:inventerization_4aas/constants/theme/app_colors.dart';

@RoutePage()
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: invAppBar(
        title: 'Уведомления',
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Нажмите на название уведомления, чтобы пометить его как прочитанное',
                  ),
                ),
              );
            },
            icon: Icon(Icons.info),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final cubit = context.read<NotificationCubit>();
          final all = cubit.all;
          final unread = cubit.unread;

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: "Непрочитанные"),
                    Tab(text: "Все"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Только непрочитанные
                      _buildList(unread),
                      // Все уведомления
                      _buildList(all),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List<InvNotification> notifications) {
    if (notifications.isEmpty) {
      return const Center(child: Text('Нет уведомлений'));
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final n = notifications[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    color: AppColor.elementColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.notifications_none),
                  ),
                ),
                title: Text(n.title),
                subtitle: Text(n.createdAt),
                trailing: n.isRead
                    ? null
                    : Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                onTap: () {
                  context.read<NotificationCubit>().markAsRead(n.id!);
                },
              ),
              SizedBox(
                height: 100,
                child: Text(
                  n.body,
                  style: AppTextStyle.style14w400.copyWith(
                    color: AppColor.textPrimary,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              Divider(),
            ],
          ),
        );
      },
    );
  }
}

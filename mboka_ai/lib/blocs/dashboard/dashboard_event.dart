abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {
  final String userId;
  LoadDashboardData(this.userId);
}

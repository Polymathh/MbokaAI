import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final FirebaseFirestore firestore;

  DashboardBloc({required this.firestore}) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final userDoc = await firestore
          .collection('users')
          .doc(event.userId)
          .get();

      if (userDoc.exists) {
        emit(DashboardLoaded(userData: userDoc.data()!));
      } else {
        emit(DashboardError("User data not found"));
      }
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}

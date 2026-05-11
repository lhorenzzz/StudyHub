// Shared re-export — both admin and user dashboards can import from here.
// TODO: once the two ResourceCard implementations are unified,
// move the shared implementation into this file directly.
export 'package:study_hub/features/user/dashboard/widgets/resource_widgets.dart'
    show ResourceCard, MyResourceCard, ResourcesGrid, LastOpenedBar;

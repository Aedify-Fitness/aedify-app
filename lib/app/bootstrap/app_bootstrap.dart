import 'package:aedify/app/bootstrap/controllers/bootstrap_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBootstrap {
  AppBootstrap._();
  static final controllerProvider =
      NotifierProvider<BootstrapController, BootstrapState>(
        BootstrapController.new,
      );
}

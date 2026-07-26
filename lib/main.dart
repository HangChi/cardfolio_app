import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_router.dart';
import 'app/cardfolio_app.dart';

void main() {
  runApp(ProviderScope(child: CardfolioApp(router: createAppRouter())));
}

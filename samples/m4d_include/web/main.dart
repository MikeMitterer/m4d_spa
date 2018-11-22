library app;

import "dart:html" as dom;
import 'package:console_log_handler/console_log_handler.dart';

import 'package:m4d_core/m4d_ioc.dart' as ioc;
import 'package:m4d_core/m4d_core.dart';

import 'package:m4d_components/m4d_components.dart';

import 'package:m4d_spa/m4d_spa.dart';

import 'package:prettify/prettify.dart';

main() async {
    final Logger _logger = new Logger('main.MaterialInclude');

    configLogging(show: Level.INFO);

    // Initialize M4D
    ioc.IOCContainer.bindModules([
        SPAModule(), CoreComponentsModule()
    ]);

    final MaterialApplication app = await componentHandler().upgrade();
    app.run();

    final MaterialInclude include = MaterialInclude.widget(dom.querySelector("#main"));

    include.onLoadEnd.listen((_) {

        prettyPrint();
        _logger.info("Loaded");
    });
}

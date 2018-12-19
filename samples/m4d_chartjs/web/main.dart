import "dart:html" as dom;
import "dart:async";
import "dart:math" as math;

import 'package:console_log_handler/console_log_handler.dart';

import 'package:m4d_core/m4d_ioc.dart' as ioc;
import 'package:m4d_core/services.dart' as coreService;

import 'package:m4d_core/m4d_core.dart';

import 'package:m4d_components/m4d_components.dart';

import 'package:m4d_spa/m4d_spa.dart';

import 'package:chartjs/chartjs.dart';


class Application extends MaterialApplication {
    final Logger _logger = new Logger('main.ChartDemo.Application');


    Application() {
    }

    @override
    void run() {
        Future(() => _initStats());
    }

    //- private -----------------------------------------------------------------------------------

    void _initStats() {
        var rnd = math.Random();
        var months = <String>["January", "February", "March", "April", "May", "June"];

        final LinearChartData data = LinearChartData(labels: months, datasets: <ChartDataSets>[
            ChartDataSets(
                label: "My First dataset",
                backgroundColor: "rgba(220,220,220,0.2)",
                data: months.map((_) => rnd.nextInt(100)).toList()),
            ChartDataSets(
                label: "My Second dataset",
                backgroundColor: "rgba(151,187,205,0.2)",
                data: months.map((_) => rnd.nextInt(100)).toList())
        ]);

        final ChartConfiguration config = ChartConfiguration(
            type: 'line', data: data, options: ChartOptions(responsive: true));

        final Chart chart = Chart(dom.querySelector('#canvas') as dom.CanvasElement, config);

        Timer.periodic(Duration(milliseconds: 800),(_) {
            data.datasets.first.data[1] = rnd.nextInt(100);
            data.datasets.first.data[2] = rnd.nextInt(100);
            chart.update();
        });

        _logger.info("Loaded!");
    }
}

main() async {
    configLogging(show: Level.INFO);

    // Initialize M4D
    ioc.Container.bindModules([
        SPAModule(), CoreComponentsModule()
    ]).bind(coreService.Application).to(Application());;

    final MaterialApplication app = await componentHandler().upgrade();

    // Reminder - does not work...
    //    final script = dom.ScriptElement();
    //    script.async = true;
    //    script.src = "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.6.0/Chart.js";
    //    final otherScripts = dom.document.getElementsByTagName("script");
    //    otherScripts.last.parentNode.insertBefore(script, otherScripts.last);
    //    script.onLoad.listen((_) => app.run());

    app.run();
}

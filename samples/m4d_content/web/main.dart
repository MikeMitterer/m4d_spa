library app;

import "dart:html" as dom;
import "dart:async";
import "dart:math" as Math;

import 'package:intl/intl.dart';
import 'package:console_log_handler/console_log_handler.dart';

import 'package:m4d_core/m4d_ioc.dart' as ioc;
import 'package:m4d_core/services.dart' as coreService;

import 'package:m4d_components/m4d_components.dart';

import 'package:m4d_content/m4d_content.dart';
import 'package:m4d_router/router.dart';

import 'package:m4d_content_sample/m4d_content_sample.dart';

import 'includes/store.dart';

class ModelChangedEvent { }

class Application extends MaterialApplication {
    final AppStore _store = ioc.IOCContainer().resolve(AppStoreService).as<AppStore>();
    final router = Router();

    @override
    void run() {
        Future(() => _bindEvents());
    }

    // - private -----------------------------------------------------------------------------------

    void _bindEvents() {
        final MaterialContent list = MaterialContent.widget(dom.querySelector("#list"));
        final MaterialSlider mainslider = MaterialSlider.widget(dom.querySelector("#mainslider2"));

        mainslider.onInput.listen((_) => _store.sliderValue = mainslider.value);

        _store.onChange.listen((_) {
            String items() {
                final StringBuffer line = new StringBuffer();
                for(int counter = 0; counter < _store.sliderValue; counter++) {
                    final String id = "${counter + 1}";

                    line.write("<li>");
                    line.write("Item #${id}");
                    line.write('<button id="btn$id" class="mdl-button mdl-button--raised mdl-button--colored mdl-ripple-effect">Button #${id}</button>');
                    line.write("</li>");
                }
                return line.toString();
            }

            new Future(() {

                list.render("<ul>" + items() + "</ul>").then((_) {
                    for(int counter = 0; counter < _store.sliderValue; counter++) {
                        final dom.Element element  = list.element.querySelector("#btn${counter+1}");

                        // check for null - if elements are added to fast it could be possible that
                        // the element you are searching for was already removed
                        if(element != null) {
                            element.onClick.listen((final dom.MouseEvent event) {
                                dom.window.alert("Clicked on Button #${counter+1}");
                            });

                        }
                    }
                });
            });

        });
    }
}

main() async {
    configLogging(show: Level.INFO);

    // Initialize M4D
    ioc.IOCContainer.bindModules([
        ContentModule(), CoreComponentsModule(), AppStoreModule(), ContentSampleModule()
    ]).bind(coreService.Application).to(Application());

    final Application app = await componentHandler().upgrade();

    _configRouter(app.router);

    app.run();
}

class Day {
    final DateTime _date;

    Day(this._date);

    String get name => new DateFormat("E").format(_date);
    String get date => new DateFormat.yMd().format(_date);
}

/// If you have observable-Properties in your Controller it must be
/// marked as [@Model]
class ObservableController extends MaterialController  {
    final Logger _logger = Logger('main.MaterialContent');

    final time = ObservableProperty<String>("",interval: new Duration(seconds: 1));
    final days = ObservableList<Day>();

    @override
    void loaded(final RouteEvent event) {
        _logger.info("ObservableController loaded...");

        time.observes(() => _getTime());
        for(int counter = 0; days.length < 7 ;counter++) {
            days.add(new Day(new DateTime.now().add(new Duration(days: counter))));
        }
    }

    @override
    void unload() {
        _logger.info("ObservableController removed!");
    }
    
    // - private ------------------------------------------------------------------------------------------------------

    String _getTime() {
        final DateTime now = new DateTime.now();
        return "${now.hour.toString().padLeft(2,"0")}:${now.minute.toString().padLeft(2,"0")}:${now.second.toString().padLeft(2,"0")}";
    }
}

class DemoController extends MaterialController {
    AppStore _store;

    MaterialSlider _slider5;
    MaterialSlider _slider2;

    StreamSubscription _subscription = null;

    @override
    void loaded(final RouteEvent event) {
        _store = iocContainer.resolve(AppStoreService).as<AppStore>();

        _slider5 = MaterialSlider.widget(dom.querySelector("#slider5"));
        _slider2 = MaterialSlider.widget(dom.querySelector("#slider2"));

        if(_slider5 == null) {
            // ERROR-PAGE not slider 5
            return;
        }

        _slider5.value = _store.sliderValue;
        _slider2.value = _store.sliderValue;

        _slider5.hub.onChange.listen((_) => _store.sliderValue = _slider5.value);
        _slider2.hub.onChange.listen((_) => _store.sliderValue = _slider2.value);

        _subscription = _store.onChange.listen((_) => _modelChanged());
    }

    @override
    void unload() {
        _subscription?.cancel();
        _subscription = null;
    }

    // - private ------------------------------------------------------------------------------------------------------

    void _modelChanged() {
        _slider5.value = _store.sliderValue;
        _slider2.value = _store.sliderValue;
    }

}

void _configRouter(final Router router ) {
    final logger = new Logger('main.configRouter');
    final view = new ViewFactory();

    router
        ..addRoute(name: 'test', path: new ReactPattern('/test'),
            enter: view("views/test.html", new DummyController()))

        ..addRoute(name: "test2", path: new ReactPattern('/test2'),
            enter: view("views/test2.html", new ObservableController()))

        ..addRoute(name: "slider", path: new ReactPattern('/slider'),
            enter: view("views/slider.html", new DemoController()))

        ..addRoute(name: "error", path: new ReactPattern('/error'),
            enter: view("views/doesnotexist.html", new DemoController()))

        ..addRoute(name: 'home', path: new ReactPattern('/'),
            enter: view("views/home.html" ,new DummyController()))

    ;

    // optional
    router.onEnter.listen((final RouteEnterEvent event) {
        logger.info("RoutEvent ${event.route.title} -> ${event.route.urlPattern.pattern}");
    });

    // optional
    router.onError.listen((final RouteErrorEvent event) {
        logger.info("RouteErrorEvent ${event.exception}");
    });

    router.listen(); // Start listening
}


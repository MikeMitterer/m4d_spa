library app;

import "dart:html" as dom;
import "dart:async";
import "dart:math" as Math;

import 'package:intl/intl.dart';
import 'package:console_log_handler/console_log_handler.dart';

import 'package:m4d_core/m4d_ioc.dart' as ioc;
import 'package:m4d_core/services.dart' as coreService;
import 'package:m4d_flux/m4d_flux.dart';

import 'package:m4d_components/m4d_components.dart';
import 'package:m4d_directive/directive/components/interfaces/actions.dart';
import 'package:m4d_dialog/m4d_dialog.dart';

import 'package:m4d_spa/m4d_spa.dart';
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

        void _render() {
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

        }
        
        _render();
        _store.onChange.listen((final DataStoreChangedEvent event) {
            // optimize rendering
            if(event.data is PropertyChangedAction
                && (event.data as PropertyChangedAction).data == "sliderValue" ) {
                _render();
            }
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

    Timer _timer;

    @override
    void loaded(final RouteEvent event) {
        _logger.info("ObservableController loaded...");

        _timer = Timer.periodic(Duration(seconds: 1), (_) {
        final _store = ioc.IOCContainer().resolve(AppStoreService).as<AppStore>();

        String _getTime() {
            final DateTime now = new DateTime.now();
            return "${now.hour.toString().padLeft(2,"0")}:${now.minute.toString().padLeft(2,"0")}:${now.second.toString().padLeft(2,"0")}";
        }

        _store.time = _getTime();
        });
    }

    @override
    void unload() {
        _logger.info("ObservableController removed!");
        _timer?.cancel();
    }
    
    // - private ------------------------------------------------------------------------------------------------------

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

        ..addRoute(name: 'docroot', path: new UrlPattern('/'),
            enter: view("views/home.html" ,new DummyController()))

    ;

    // optional
    router.onEnter.listen((final RouteEnterEvent event) {
        logger.info("RoutEvent ${event.route.title} -> ${event.route.urlPattern.pattern}");
    });

    // optional
    router.onError.listen((final RouteErrorEvent event) {
        
        final MaterialNotification notification = new MaterialNotification()..autoClose = true;
        notification("${event.exception.toString()} for ${event.path}",type: NotificationType.ERROR).show();

        logger.info("RouteErrorEvent ${event.exception}");
    });

    router.listen(); // Start listening
}


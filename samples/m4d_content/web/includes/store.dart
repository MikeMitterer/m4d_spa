library app.store;

import 'dart:math' as Math;
import 'dart:async';

import 'package:m4d_directive/m4d_directive.dart';
import 'package:m4d_flux/m4d_flux.dart';
import 'package:m4d_core/m4d_ioc.dart' as ioc;

import 'package:m4d_directive/services.dart' as directiveService;
import 'package:m4d_content_sample/components/interfaces/SimpleDataObject.dart';

final AppStoreService = ioc.Service("app.store.AppStore", ioc.ServiceType.Instance);

class DynamicValue implements SimpleDataObject {
    final String value;

    DynamicValue(this.value);

    @override
    String asString(final String name) => contains(name) ? value : "'$name' not defined!";

    @override
    bool contains(final String name) => name == "value";
}

/// AppStore is a Singleton
class AppStore extends Dispatcher with SimpleDataStoreMixin {
    Timer timer = null;

    AppStore._private() : super(ActionBus()) {
        prop<List<SimpleDataObject>>("dyntest").value = List<SimpleDataObject>();

        sliderValue = 5;

        new Future(() => _bind());
    }

    List<int> randomValues = new List<int>();

    int get sliderValue => contains("sliderValue") ? prop<int>("sliderValue").value.toInt() : 0;

    set sliderValue(final int value) {
        randomValues.clear();
        prop<List<SimpleDataObject>>("dyntest").value.clear();

        for (int counter = 0; counter < value; counter++) {
            final random = new Math.Random().nextInt(1000);

            randomValues.add(random);
            prop<List<SimpleDataObject>>("dyntest").value.add(DynamicValue(random.toString()));
        }
        prop<int>("sliderValue").value = value;
        _update();
    }

    @override
    ObservableProperty<T> prop<T>(final String varname, {
        final T initWith = null, final FormatObservedValue<T> formatter = null }) {
        if (!bindings.containsKey(varname)) {
            bindings[varname] = ObservableProperty<T>(initWith, formatter: formatter);
            bindings[varname].onChange.listen((_) {
                _update();
            });
        }

        if (formatter != null) {
            bindings[varname].onFormat(formatter);
        }

        return bindings[varname];
    }

    // - private -------------------------------------------------------------------------------------

    void _bind() {}

    /// Optimize the update cycle
    void _update() {
        if (timer == null || !timer.isActive) {
            timer = Timer(Duration(milliseconds: 200), () {
                timer?.cancel();
                timer = null;
                emitChange();
            });
        }
    }
}

class AppStoreModule extends ioc.IOCModule {
    final _store = AppStore._private();

    @override
    configure() {
        ioc.IOCContainer().bind(AppStoreService).to(_store);
        ioc.IOCContainer().bind(directiveService.SimpleValueStore).to(_store);
    }

    @override
    List<ioc.IOCModule> get dependsOn => <ioc.IOCModule>[ DirectivesModule()];
}

library app.store;

import 'dart:math' as Math;
import 'dart:async';

import 'package:m4d_directive/m4d_directive.dart';
import 'package:m4d_flux/m4d_flux.dart';
import 'package:m4d_core/m4d_ioc.dart' as ioc;

import 'package:m4d_directive/services.dart' as directiveService;
import 'package:m4d_directive/directive/components/interfaces/actions.dart';
import 'package:m4d_template/m4d_template.dart';

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
    AppStore._private() : super(ActionBus()) {
        prop<List<SimpleDataObject>>("dyntest").value = List<SimpleDataObject>();

        sliderValue = 5;
        time = "";
        
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
        emitChange(action: PropertyChangedAction("dyntest"));
    }

    set time(final String time) => prop<String>("time").value = time;

//    @override
//    ObservableProperty<T> prop<T>(final String varname, {
//        final T initWith = null, final FormatObservedValue<T> formatter = null }) {
//        if (!bindings.containsKey(varname)) {
//            bindings[varname] = ObservableProperty<T>(initWith, formatter: formatter);
//            bindings[varname].onChange.listen((_) {
//                _update();
//            });
//        }
//
//        if (formatter != null) {
//            bindings[varname].onFormat(formatter);
//        }
//
//        return bindings[varname];
//    }

    // - private -------------------------------------------------------------------------------------

    void _bind() {

    }

//    /// Optimize the update cycle
//    void _update({ final Action action: UpdateViewAction }) {
//        if (_timer == null || !_timer.isActive) {
//            _timer = Timer(Duration(milliseconds: 200), () {
//                _timer?.cancel();
//                _timer = null;
//                emitChange(action: action);
//            });
//        }
//    }
}

class AppStoreModule extends ioc.Module {
    final _store = AppStore._private();

    @override
    configure() {
        ioc.Container().bind(AppStoreService).to(_store);
        ioc.Container().bind(directiveService.SimpleValueStore).to(_store);
    }

    @override
    List<ioc.Module> get dependsOn => <ioc.Module>[ DirectivesModule()];
}

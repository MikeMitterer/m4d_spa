/*
 * Copyright (c) 2015, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 *
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of m4d_content;

/// MaterialContent is [ScopeAware] - this means that it can be found by child-MaterialComponent
/// looking for Data (like [MaterialRepeat]
///
/// Unlike other [ScopeAware] components MaterialContent redirects its [Scope] to
/// [MaterialApplication]
///
/// This means if you have a smaller Application you can implement your observable properties
/// in your Application
///
///     @Model
///     class Application extends MaterialApplication {
///         final ObservableProperty<String> time = new ObservableProperty<String>("",interval: new Duration(seconds: 1));
///     
///         Application() {
///             time.observes(() => _getTime());
///         }
///     
///         String _getTime() {
///             final DateTime now = new DateTime.now();
///             return "${now.hour.toString().padLeft(2,"0")}:${now.minute.toString().padLeft(2,"0")}:${now.second.toString().padLeft(2,"0")}";
///         }
///     }
///
/// If you use routes and [MaterialController] implement the [ScopeAware] and tag your
/// Controller with [Model]
///
///     @mdl.Model
///     class ObservableController extends mdl.MaterialController implements ScopeAware {
///         final ObservableProperty<String> time
///         = new ObservableProperty<String>("",interval: new Duration(seconds: 1));
///
///         @override
///         void loaded(final Route route) {
///             time.observes(() => _getTime());
///         }
///
///         @override
///         mdl.Scope get scope => new mdl.Scope(this);
///
///         String _getTime() {
///             final DateTime now = new DateTime.now();
///             return "${now.hour.toString().padLeft(2,"0")}:${now.minute.toString().padLeft(2,"0")}:${now.second.toString().padLeft(2,"0")}";
///         }
///     }
class MaterialContent extends MdlComponent {
    final Logger _logger = new Logger('mdlapplication.MaterialContent');

    static const _MaterialContentCssClasses _cssClasses = const _MaterialContentCssClasses();
    final DomRenderer _renderer = DomRenderer();

    MaterialContent.fromElement(final dom.HtmlElement element,final ioc.IOCContainer iocContainer)
        : super(element,iocContainer) {
    }

    @override
    void attached() {
        _init();
    }

    static MaterialContent widget(final dom.HtmlElement element) => mdlComponent(element,MaterialContent) as MaterialContent;

    // Central Element - by default this is where mdl-content was found (element)
    // html.Element get hub => inputElement;

    /// Render the {content} String - {content} must have ONE! top level element
    Future render(final String content) {
        //_logger.info("Content: $content");

        return _renderer.render(element,content);
    }

    //- private -----------------------------------------------------------------------------------

    void _init() {
        _logger.fine("MaterialContent - init");
        element.classes.add(_cssClasses.IS_UPGRADED);
    }
}

/// Store strings for class names defined by this component that are used in
/// Dart. This allows us to simply change it in one place should we
/// decide to modify at a later date.
class _MaterialContentCssClasses {

    static const String MAIN_CLASS  = "mdl-content";

    final String IS_UPGRADED = 'is-upgraded';

    const _MaterialContentCssClasses();
}

/// creates MdlConfig for MaterialContent
MdlConfig materialContentConfig() => new MdlWidgetConfig<MaterialContent>(
    _MaterialContentCssClasses.MAIN_CLASS, (final dom.HtmlElement element,final ioc.IOCContainer iocContainer)
        => new MaterialContent.fromElement(element,iocContainer));

/// registration-Helper
void registerMaterialContent() => componentFactory().register(materialContentConfig());



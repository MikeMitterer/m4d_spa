part of m4d_content_sample;

class ListComponent extends MdlTemplateComponent {
    final Logger _logger = new Logger('todo.ListComponent');

    static const _cssClasses = _ListComponentCssClasses();

    final SimpleValueStore _store;

    String _template = null;
    final _paramsFromTemplate = List<String>();
    
    ListComponent.fromElement(final dom.HtmlElement element,final ioc.IOCContainer iocContainer)
        : _store = iocContainer.resolve(directiveService.SimpleValueStore).as<SimpleValueStore>(),
            super(element,iocContainer) {
        _init();
    }

    static ListComponent widget(final dom.HtmlElement element)
        => mdlComponent(element,ListComponent) as ListComponent;


    //- private -----------------------------------------------------------------------------------

    void _init() {
        _logger.fine("ListComponent - init (Model: ${_model})");

        _template = element.innerHtml.replaceAll(RegExp(r"<[/]*template>"), "");

        final exp = RegExp(r"\{\{([^\}]+)\}\}");
        exp.allMatches(_template).forEach((final Match match) {
            _paramsFromTemplate.add(match.group(1).trim());
        });

        render().then((_) => _bindSignals() );

        element.classes.add(_cssClasses.IS_UPGRADED);
    }

    void _bindSignals() {
        _store.onChange.listen((final DataStoreChangedEvent event) {
            // optimize rendering
            if(event.data is ListChangedAction) {
                render();
            }
        });
    }

    String get _model => DataAttribute.forAttribute(element, "model").asString();

    List<SimpleDataObject> get _dao {

        if(!_store.contains(_model)) {
            throw ArgumentError("Store has no ${_model} property!");
        }

        return _store.prop(_model).value as List<SimpleDataObject>;
    }

    //- EventHandler -------------------------------------------------------------------------------
    void _onClick(final String index) {
        dom.window.alert("Clicked on Listitem #${index}");
    }

    //- Template -----------------------------------------------------------------------------------

    @override
    String get template {
        final buffer = StringBuffer();

        // Template must return one single element!!!
        buffer.write("<ul class='item-container'>");

        int index = 0;
        _dao.forEach((final SimpleDataObject object) {
            String content = _template;
            _paramsFromTemplate.forEach((final String param) {
                if(object.contains(param)) {
                    content = content.replaceAll("{{$param}}", object.asString(param));
                }
            });
            content = content.replaceAll("{{index}}", "$index");
            buffer.write(content);

            index++;
        });
        buffer.write("</ul>");

        return  buffer.toString();
    }

    @override
    Map<String,Function> get events {
        return <String,Function>{
            "onClick" : (index) => _onClick(index as String)
        };
    }
}

/// registration-Helper
void registerListComponent() {
    final MdlConfig config = new MdlWidgetConfig<ListComponent>(
        _ListComponentCssClasses.MAIN_CLASS,
            (final dom.HtmlElement element, final ioc.IOCContainer iocContainer)
        => new ListComponent.fromElement(element, iocContainer));

    config.selectorType = SelectorType.TAG;
    componentHandler().register(config);
}

/// Store strings for class names defined by this component that are used in
/// Dart. This allows us to simply change it in one place should we
/// decide to modify at a later date.
class _ListComponentCssClasses {
    static const String MAIN_CLASS  = "m4d-list";

    final String IS_UPGRADED = 'is-upgraded';

    const _ListComponentCssClasses();
}

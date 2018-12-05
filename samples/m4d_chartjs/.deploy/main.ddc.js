define(['dart_sdk', 'packages/logging/logging', 'packages/m4d_core/core/interfaces', 'packages/console_log_handler/console_log_handler', 'packages/m4d_core/services', 'packages/m4d_spa/m4d_spa', 'packages/m4d_components/m4d_components', 'packages/m4d_core/m4d_ioc', 'packages/m4d_core/m4d_core'], function(dart_sdk, logging, interfaces, console_log_handler, services, m4d_spa, m4d_components, m4d_ioc, m4d_core) {
  'use strict';
  const core = dart_sdk.core;
  const async = dart_sdk.async;
  const math = dart_sdk.math;
  const _interceptors = dart_sdk._interceptors;
  const html = dart_sdk.html;
  const dart = dart_sdk.dart;
  const dartx = dart_sdk.dartx;
  const logging$ = logging.logging;
  const core__interfaces = interfaces.core__interfaces;
  const console_log_handler$ = console_log_handler.console_log_handler;
  const services$ = services.services;
  const m4d_spa$ = m4d_spa.m4d_spa;
  const m4d_components$ = m4d_components.m4d_components;
  const m4d_ioc$ = m4d_ioc.m4d_ioc;
  const m4d_core$ = m4d_core.m4d_core;
  const _root = Object.create(null);
  const main = Object.create(_root);
  const $toList = dartx.toList;
  const $map = dartx.map;
  const $_set = dartx._set;
  const $first = dartx.first;
  let VoidTovoid = () => (VoidTovoid = dart.constFn(dart.fnType(dart.void, [])))();
  let FutureOfvoid = () => (FutureOfvoid = dart.constFn(async.Future$(dart.void)))();
  let JSArrayOfString = () => (JSArrayOfString = dart.constFn(_interceptors.JSArray$(core.String)))();
  let StringToint = () => (StringToint = dart.constFn(dart.fnType(core.int, [core.String])))();
  let JSArrayOfChartDataSets = () => (JSArrayOfChartDataSets = dart.constFn(_interceptors.JSArray$(dart.anonymousJSType("ChartDataSets"))))();
  let TimerToNull = () => (TimerToNull = dart.constFn(dart.fnType(core.Null, [async.Timer])))();
  let JSArrayOfIOCModule = () => (JSArrayOfIOCModule = dart.constFn(_interceptors.JSArray$(m4d_ioc$.IOCModule)))();
  const _logger = Symbol('_logger');
  const _initStats = Symbol('_initStats');
  main.Application = class Application extends core__interfaces.MaterialApplication {
    run() {
      FutureOfvoid().delayed(new core.Duration.new({seconds: 1}), dart.fn(() => this[_initStats](), VoidTovoid()));
    }
    [_initStats]() {
      let rnd = math.Random.new();
      let months = JSArrayOfString().of(["January", "February", "March", "April", "May", "June"]);
      let data = {labels: months, datasets: JSArrayOfChartDataSets().of([{label: "My First dataset", backgroundColor: "rgba(220,220,220,0.2)", data: months[$map](core.int, dart.fn(_ => rnd.nextInt(100), StringToint()))[$toList]()}, {label: "My Second dataset", backgroundColor: "rgba(151,187,205,0.2)", data: months[$map](core.int, dart.fn(_ => rnd.nextInt(100), StringToint()))[$toList]()}])};
      let config = {type: "line", data: data, options: {responsive: true}};
      let chart = new dart.global.Chart.Chart(html.CanvasElement.as(html.querySelector("#canvas")), config);
      async.Timer.periodic(new core.Duration.new({milliseconds: 800}), dart.fn(_ => {
        data.datasets[$first].data[$_set](1, rnd.nextInt(100));
        data.datasets[$first].data[$_set](2, rnd.nextInt(100));
        dart.dsend(chart, 'update', []);
      }, TimerToNull()));
      this[_logger].info("Loaded!");
    }
  };
  (main.Application.new = function() {
    this[_logger] = logging$.Logger.new("main.ChartDemo.Application");
  }).prototype = main.Application.prototype;
  dart.addTypeTests(main.Application);
  dart.setMethodSignature(main.Application, () => ({
    __proto__: dart.getMethods(main.Application.__proto__),
    [_initStats]: dart.fnType(dart.void, [])
  }));
  dart.setFieldSignature(main.Application, () => ({
    __proto__: dart.getFields(main.Application.__proto__),
    [_logger]: dart.finalFieldType(logging$.Logger)
  }));
  main.main = function() {
    return async.async(dart.dynamic, function* main$() {
      console_log_handler$.configLogging({show: logging$.Level.INFO});
      m4d_ioc$.IOCContainer.bindModules(JSArrayOfIOCModule().of([new m4d_spa$.SPAModule.new(), new m4d_components$.CoreComponentsModule.new()])).bind(services$.Application).to(new main.Application.new());
      ;
      let app = (yield m4d_core$.componentHandler().upgrade(core__interfaces.MaterialApplication));
      app.run();
    });
  };
  dart.trackLibraries("web/main.ddc", {
    "main.dart": main
  }, '{"version":3,"sourceRoot":"","sources":["main.dart"],"names":[],"mappings":";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;AA2BQ,4BAAc,KAAC,iBAAQ,WAAU,KAAG,cAAM,gBAAU;IACxD;;AAKI,UAAI,MAAM,eAAW;AACrB,UAAI,SAAS,sBAAS,WAAW,YAAY,SAAS,SAAS,OAAO;AAEtE,UAAsB,OAAO,SAAwB,MAAM,YAAY,6BACnE,QACW,qCACU,+BACX,MAAM,MAAI,WAAC,QAAC,CAAC,IAAK,GAAG,QAAQ,CAAC,8BAAY,KACpD,QACW,sCACU,+BACX,MAAM,MAAI,WAAC,QAAC,CAAC,IAAK,GAAG,QAAQ,CAAC,8BAAY;AAGxD,UAAyB,SAAS,OACxB,cAAc,IAAI,WAAW,aAAyB;AAEhE,UAAY,YAAQ,uBAAK,uBAAC,AAAI,kBAAa,CAAC,aAAiC,MAAM;AAEnF,0BAAc,KAAC,iBAAQ,gBAAe,OAAK,QAAC,CAAC;AACzC,YAAI,SAAS,QAAM,KAAK,QAAC,GAAK,GAAG,QAAQ,CAAC;AAC1C,YAAI,SAAS,QAAM,KAAK,QAAC,GAAK,GAAG,QAAQ,CAAC;AAC1C,wBAAK;;AAGT,mBAAO,KAAK,CAAC;IACjB;;;IAxCa,aAAO,GAAG,AAAI,mBAAM,CAAC;EAIlC;;;;;;;;;;;AAuCG;AACH,wCAAa,QAAO,cAAK,KAAK;AAG9B,uCAA4B,CAAC,6BACzB,sBAAS,QAAI,wCAAoB,UAC9B,CAAa,qBAAW,IAAI,KAAC,oBAAW;AAAI;AAEnD,UAA0B,OAAM,MAAM,0BAAgB,UAAU;AAUhE,SAAG,IAAI;IACX","file":"main.ddc.js"}');
  // Exports:
  return {
    main: main
  };
});

//# sourceMappingURL=main.ddc.js.map

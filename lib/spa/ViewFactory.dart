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

part of m4d_spa;

/**
 * Loads additional "views" (html-Page) in SPA-Application
 *
 * Sample:
 *      configRouter() {
 *          final Router router = new Router(useFragment: true);
 *          final ViewFactory view = new ViewFactory();
 *
 *          router.root
 *              ..addRoute(name: 'typography', path: '/typography',
 *              enter: view("views/typography.html", new DemoController()))
 *
 *              ..addRoute(name: 'home', defaultRoute: true, path: '/',
 *              enter: view("views/home.html" ,new DemoController()))
 *
 *              ;
 *
 *          router.listen();
 *      }
 *
 * Until 2017.11.09 ViewFactory was "injectable". This should not be necessary.
 * Changing the ViewFactory to a individual version should be very easy without DI.
 * See example from above
 */
class ViewFactory {
    final Logger _logger = new Logger('mdlremote.ViewFactory');

    MaterialController _previousController;

    RouteEnterCallback call(final String url, final MaterialController controller, { final String selector: "#main"}) {
        return (final RouteEvent event,[ void onError(final Exception exception) ])
            => _enterHandler(event, url, controller, selector, onError);
    }

//    void call(final String url, final MaterialController controller, { final String selector: "#main"}) {
//         _enterHandler( url, controller, selector);
//    }

    //- private -----------------------------------------------------------------------------------

    void _enterHandler(final RouteEvent event, final String url,
                       final MaterialController controller, final String selector,
                       void onError(final Exception exception) ) {

        //Validate.notNull(event);
        Validate.notNull(url);
        Validate.notNull(controller);
        Validate.notBlank(selector);

        final Stopwatch stopwatch = new Stopwatch();
        final dom.HttpRequest request = new dom.HttpRequest();
        final dom.Element contentElement = dom.querySelector(selector);

        if(contentElement == null) {
            _logger.severe('Please add <div id="$selector" class="mdl-content">Loading...</div> to your index.html');
            return;
        }

        if(_previousController != null) {
            _previousController.unload();
        }
        _previousController = controller;

        request.open("GET", url);
        request.onLoadEnd.listen((final dom.ProgressEvent progressEvent) {
            //_logger.info('Request complete ${request.responseText}, Status: ${request.readyState}');

            if (request.readyState == dom.HttpRequest.DONE) {

                final String content = sanitizeResponseText(request.responseText);
                final MaterialContent main = MaterialContent.widget(contentElement);

                if(content == null || content.isEmpty || request.status == 404) {
                    onError(Exception("$url '${content}' ${request.status}"));
                } else {
                    main.render(content).then( (_) {

                        // TODO: Rename injector to iocContainer
                        controller.iocContainer = main.injector;
                        controller.loaded(event);

                        stopwatch.stop();
                        _logger.info("Page load and rendering took ${stopwatch.elapsedMilliseconds}ms");
                    });
                }
            }
        });

        stopwatch.start();
        request.send();
    }

}

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

abstract class MaterialController {
    /// [iocContainer] will be set after {ViewFactory} receives the {onLoadEnd} Event
    ioc.IOCContainer iocContainer;

    /// [loaded] is called after [ViewFactory] received the onLoadEnd-Event
    ///
    /// At this point the Template is already rendered
    void loaded(final RouteEnterEvent event);

    /// Called before the next controller is loaded
    void unload() {}
}

class DummyController extends MaterialController {
    final Logger _logger = new Logger('mdlapplication.DummyController');

    @override
    void loaded(final RouteEnterEvent event) {
        _logger.info("View loaded! (Route: ${event.route})");
    }

    @override
    void unload() {
        _logger.info("Unload Controller...");
    }
}
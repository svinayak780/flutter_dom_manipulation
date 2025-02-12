//
//  main.dart
//
//  Created by Vinayak Sharma on 12/02/25.
//

import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:web/web.dart' as web;

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: const HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {

  /// [TextEditingController] for the URL of the image.
  TextEditingController urlController = TextEditingController(text: "https://picsum.photos/1000");

  /// [GlobalKey] for the [ExpandableFabState].
  final _fabKey = GlobalKey<ExpandableFabState>();

  /// Toggles the fullscreen mode of the image.
  void toggleFullscreen(web.Event? event) {

    /// Finds the image element by id
    var elem = web.document.getElementById("html-image");
    if (elem == null) {
      return;
    }

    /// Exits fullscreen if already in fullscreen mode
    if (web.document.fullscreen) {
      web.document.exitFullscreen();
      return;
    }

    /// Requests fullscreen mode
    elem.requestFullscreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  /// [HtmlElementView] injects the <img> tag into the DOM.
                  child: HtmlElementView.fromTagName(
                    tagName: 'img',
                    onElementCreated: (Object image) {
                      image as web.HTMLImageElement;
                      image.src = urlController.text;
                      image.id = 'html-image';
                      image.style.objectFit = 'contain';
                      image.addEventListener('dblclick', toggleFullscreen.toJS);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Image URL'),
                    controller: urlController,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    /// Updates the image source of [HTMLImageElement].
                    var elem = web.document.getElementById("html-image");
                    if (elem == null) {
                      return;
                    }
                    elem as web.HTMLImageElement;
                    elem.src = urlController.text;
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                    child: Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      /// [ExpandableFab] to display fullscreen control buttons.
      floatingActionButton: ExpandableFab(
        key: _fabKey,
        type: ExpandableFabType.up,
        openButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double> progress) {
            return FloatingActionButton(
              onPressed: onPressed,
              child: const Icon(
                Icons.add,
                size: 40,
              ),
            );
          },
        ),
        closeButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double> progress) {
            return FloatingActionButton(
              onPressed: onPressed,
              child: const Icon(
                Icons.close,
                size: 40,
              ),
            );
          },
        ),
        /// Introduces an overlay around the buttons.
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.black.withValues(alpha: 0.75),
        ),
        children: [
          FloatingActionButton.extended(
            tooltip: 'Enter Fullscreen',
            icon: const Icon(Icons.fullscreen),
            label: Text('Enter Fullscreen'),
            onPressed: () {
              /// Toggle [ExpandableFabState] to close the buttons.
              _fabKey.currentState?.toggle();

              /// Requests fullscreen mode.
              if (web.document.fullscreen) {
                return;
              }
              var elem = web.document.getElementById("html-image");
              if (elem == null) {
                return;
              }
              elem.requestFullscreen();
            },
          ),
          FloatingActionButton.extended(
            tooltip: 'Exit Fullscreen',
            icon: const Icon(Icons.fullscreen_exit),
            label: Text('Exit Fullscreen'),
            onPressed: () {
              /// Toggle [ExpandableFabState] to close the buttons.
              _fabKey.currentState?.toggle();

              /// Exits fullscreen mode.
              web.document.fullscreen ? web.document.exitFullscreen() : null;
            },
          ),
        ],
      ),
    );
  }
}

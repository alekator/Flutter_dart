import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

/// Главная точка входа в приложение.
void main() {
  runApp(const MyApp());
}

/// Основной класс приложения.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Возвращает MaterialApp с темной темой и домашней страницей
    return MaterialApp(
      title: 'Image Viewer',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

/// Страница для отображения изображения.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// Состояние страницы с изображением.
class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  String? imageUrl; // Хранит URL изображения
  bool _isMenuOpen = false; // Состояние меню

  /// Переключение полноэкранного режима.
  void _toggleFullScreen() {
    if (html.document.fullscreenElement == null) {
      // Запрашиваем полноэкранный режим
      html.document.documentElement?.requestFullscreen();
    } else {
      // Выходим из полноэкранного режима
      html.document.exitFullscreen();
    }
  }

  /// Переключение состояния меню.
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Viewer')), // Заголовок приложения
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1, // Пропорции для отображения изображения
                    child: GestureDetector(
                      onDoubleTap: _toggleFullScreen, // Переключение полноэкранного режима по двойному тапу
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey, // Цвет фона контейнера
                          borderRadius: BorderRadius.circular(12), // Радиус скругления
                        ),
                        // Если изображение загружено, показываем его
                        child: imageUrl != null
                            ? HtmlElementView(viewType: 'imageElement')
                            : const Center(child: Text('No image loaded')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(hintText: 'Image URL'), // Поле для ввода URL изображения
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          imageUrl = _urlController.text; // Присваиваем URL
                          final imgElement = html.ImageElement()
                            ..src = imageUrl! // Устанавливаем источник изображения
                            ..style.width = '100%'; // Устанавливаем ширину изображения
                          // Регистрируем HTML-элемент для отображения
                          ui.platformViewRegistry.registerViewFactory(
                            'imageElement',
                            (int viewId) => imgElement,
                          );
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          // Отображаем меню, если оно открыто
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu, // Закрытие меню при клике
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          // Позиционированное меню с кнопками для полноэкранного режима
          if (_isMenuOpen)
            Positioned(
              right: 16,
              bottom: 80,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        html.document.documentElement?.requestFullscreen(); // Вход в полноэкранный режим
                        _toggleMenu(); // Закрываем меню
                      },
                      child: const Text('Enter Fullscreen'),
                    ),
                    TextButton(
                      onPressed: () {
                        html.document.exitFullscreen(); // Выход из полноэкранного режима
                        _toggleMenu(); // Закрываем меню
                      },
                      child: const Text('Exit Fullscreen'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMenu, // Открытие/закрытие меню по нажатию кнопки
        child: const Icon(Icons.add),
      ),
    );
  }
}

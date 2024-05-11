## Pages

**Pages** are widgets that contain state and other *smaller* widgets. You can think of a page as a way to organize content and encourage user interaction. For organizational purposes, we put all pages under a specific folder, `lib/pages`, which ensures a clear separation of code and functionality. 

Generally, you can apply quite a bit of knowledge from general graphic design principles when building these pages to make them look nice and neat, but in the end they should serve to be functional.

NOTE: `lib/pages/match_form.dart` is an important page to focus on for development. It's really the backbone of the app and it's where all scouting data comes from. So, it's highly important to keep it always up to date for the season. 

## Utils

**Utils** are any generic function or class that helps facilitate the state of the app. They can be found in `lib/utils`.

## Widgets

**Widgets** are the building blocks that help with code reuse and UI design. They can be found in `lib/widgets`

## Main

`lib/main.dart` is the main entry point for the app. Use it primarily as a way to set up additional state needed for specific functionality.

### Conclusion

Be wary that this codebase was initially built in a month, so a lot of the structure may be messy. Generally I tried cleaning this up, but there is always room for improvement. However, I'd like to take this section to talk about how *currently* things are done and where it can be done better.

One pain point with creating UI in Dart is the nesting that you encounter when building UI components. It can lead to spaghetti code and sometimes unreadable monstrosities, but there are ways to tackle it. For example, if you find yourself reusing specifc UI elements together consider separating that code into a function or widget class. Another way to tackle this is to try and simplify the elements used to build the UI into a flatter or linear structure. It's important to always reconsider your options in how everything is laid out.
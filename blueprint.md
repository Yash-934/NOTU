
# NOTU - Blueprint

## Overview

NOTU is a note-taking application for Flutter that allows users to organize their notes in a hierarchical structure, similar to books and chapters. The app supports rich text formatting using Markdown and HTML/CSS.

## Features

### Core
- **Book and Chapter Organization**: Notes are organized into books, which contain chapters.
- **Rich Text Editing**: Support for Markdown and HTML/CSS in notes.
- **Cross-platform**: Built with Flutter for a consistent experience on mobile and web.
- **Add New Books**: Users can create new books.
- **Add New Chapters**: Users can add new chapters to a book.

### Style & Design
- **Theme**: Modern, clean theme with support for light and dark modes.
- **Typography**: Clear and readable fonts.
- **Layout**: Intuitive and responsive layout.

## Current Plan

### Phase 4: Chapter Management

1.  **Add New Chapter FAB**: Add a `FloatingActionButton` to the `BookDetailsScreen`.
2.  **Add Chapter Screen**: Create a new screen `lib/screens/add_chapter_screen.dart` with a form to enter a chapter title and content.
3.  **State Management for Chapters**: Update `BookDetailsScreen` to be a `StatefulWidget` to manage the list of chapters.
4.  **Implement Add Chapter Logic**: Add logic to the `AddChapterScreen` to create a new chapter and add it to the book.

### Phase 3: Core Functionality (Completed)

1.  **Add New Book FAB**: Add a `FloatingActionButton` to the home page.
2.  **Add Book Screen**: Create a new screen `lib/screens/add_book_screen.dart` with a form to enter a book title.
3.  **State Management for Books**: Update `MyHomePage` to be a `StatefulWidget` to manage the list of books.
4.  **Implement Add Book Logic**: Add logic to the `AddBookScreen` to create a new book and add it to the list.

### Phase 2: Visual Polish (Completed)

1.  **Add `google_fonts`**: Include the `google_fonts` package for custom typography.
2.  **Enhance Theme**:
    - Update `lib/main.dart` to use Material 3 theming with `ColorScheme.fromSeed`.
    - Create a custom `TextTheme` using `google_fonts` (e.g., Oswald, Roboto, Open Sans).
    - Customize `appBarTheme` and other component themes for a consistent look.
    - Apply the new typography and styles throughout the app.

### Phase 1: Project Setup & Basic UI (Completed)

1.  **Initialize Project**: Set up a new Flutter project.
2.  **Add Dependencies**:
    - `flutter_markdown`: For rendering Markdown content.
    - `provider`: For state management.
3.  **Create `blueprint.md`**: Document the project plan and features.
4.  **Basic App Structure**:
    - Modify `lib/main.dart` with the app title "NOTU".
    - Create a basic home page.
    - Implement a simple theme.
5.  **Data Models**:
    - Create `lib/models/book.dart` for the book data structure.
    - Create `lib/models/chapter.dart` for the chapter data structure.
6.  **Display Books**: Update the home page to display a list of sample books.
7.  **Book Details Screen**:
    - Create `lib/screens/book_details_screen.dart` to display a book's chapters.
    - Implement navigation from the home page to the details screen.
8.  **Chapter Details Screen**:
    - Create `lib/screens/chapter_details_screen.dart` to display chapter content.
    - Implement navigation from the book details screen to the chapter details screen.

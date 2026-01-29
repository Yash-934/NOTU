# Project Blueprint

## 1. Project Overview

This is a note-taking application that allows users to create books and write chapters within them. The app supports different content types (Markdown and HTML) and allows for exporting and backing up data.

## 2. Implemented Features

*   Create, edit, and delete books.
*   Create, edit, and delete chapters.
*   Support for Markdown and HTML content.
*   Export individual books to JSON.
*   Backup and restore all data.
*   Themed UI with light and dark modes.
*   PDF and printing functionality for chapters.

## 3. Current Goal: Implement Chapter Reordering

The user wants to be able to reorder the chapters within a book.

## 4. Plan

*   **Step 1: Update `database_helper.dart`**
    *   Add a `display_order` column to the `chapters` table.
    *   Update `getChaptersForBook` to order by the new `display_order` column.
    *   Update `insertChapter` to set the initial `display_order`.
    *   Create a new method `updateChapterOrder` to update the `display_order` of multiple chapters at once.
*   **Step 2: Update `chapter.dart` Model**
    *   Add the `displayOrder` field to the `Chapter` class.
    *   Update the `fromMap` and `toMap` methods to include the new field.
*   **Step 3: Update `book_details_screen.dart`**
    *   Add a "Reorder" `IconButton` to the `AppBar`.
    *   When the "Reorder" button is pressed, navigate to a new `ReorderChaptersScreen`.
    *   Update the `_loadChapters` method to handle the new `display_order`.
*   **Step 4: Create `reorder_chapters_screen.dart`**
    *   Create a new stateful widget called `ReorderChaptersScreen`.
    *   Use a `ReorderableListView` to display the chapters.
    *   Implement the `onReorder` callback to update the order of the chapters in the local list.
    *   Add a "Save" button to the `AppBar`.
    *   When the "Save" button is pressed, call the `updateChapterOrder` method in `DatabaseHelper` to persist the new order.
*   **Step 5: Test the feature**
    *   Run the app and verify that the reordering functionality works as expected.

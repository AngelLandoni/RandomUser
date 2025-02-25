# Random user

A simple app which loads random users.

## Tech

To develop the project and keep it as straightforward as possible, no third-party frameworks were used. For simplicity, the UI was built with SwiftUI, with UIKit as a fallback for features not yet available in SwiftUI. The project follows the MVVM (Model-View-ViewModel) architecture, separating logic into presentation, domain, and data layers. MVVM was chosen because it integrates seamlessly with SwiftUI and helps maintain minimal, clean code.

## Project

- Compile with: Xcode 16.2
- The minimun target is: iOS 18.2

## Things to do

Not all planned features were implemented. Some of the missing features include:

- A proper logging system to track app events and errors.
- A nice custom UI.
- Localization.
- Integration tests (Layers are tested, but in isolation. It would be great to test from the Presentation to the Data layer, mocking the Repository so we can test the entire flow).

## Instructions

To run just open the `RandomUser.xcodeproj` file and execute the project.

## Whys

- The project heavily uses async/await to keep the UI thread (main thread) as free as possible to avoid any kind of stuttering.
- async/await Was used just for simplicity, GCD could achieve the same but it would take more time and code.
- AsyncImage was used to avoid manually handling image loading (e.g., canceling the request if the cell is out of scope, caching the uncompressed image, retrieving the image from cache, etc.).
- CoreData was use as it is the default tool it is provided to persist big volume of data.

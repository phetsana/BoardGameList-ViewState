# BoardGameList

This project is about testing and exploring SwiftUI and Combine using MVVM architecture with View-State.

This project follows the architecture described by Vadim Bulavin : [Modern MVVM iOS App Architecture with Combine and SwiftUI](https://www.vadimbulavin.com/modern-mvvm-ios-app-architecture-with-combine-and-swiftui/)

## MVVM

**MVVM** (Model View ViewModel) is among most popular architecture in iOS community. MVVM allows an easy separation of concerns and a better testability.
This project choose to use MVVM and explore **View-State** concept which handle model part.

### View-State

On MVVM architecture, Microsoft described the View linked to the **ViewModel** with data binding. 
A way to handle **ViewModel**, is to see it like a blackbox with **inputs** and **outputs**. It is a concept popularized with RxSwift and data streams.
A cons we can see with **inputs/ouputs** concept is that data binding can become quickly a spaghetti code. And another issue occured from two-way bindings approach is state explosion.

To try to solve this, we can use a concept from Redux where **ViewModel** will expose State and react to Event. With this approch, we end up with a **Finite State Machine** (FSM). A better control of what is going on. For a better separation of concerns, we use Feedback concept to handle side effect like I/O or networking.

## API

This project uses an open API [boardgameatlas.com](https://www.boardgameatlas.com/)

## Scenes

Our application contains 2 scenes.

### GamesList

The first scene is a list view with board games from networking request.
Each cell displays name and thumbnail image of a board game.

### GameDetail

The second scene is the detail of board game when clicking in a cell of first scene. 

## Tests

The chosen architecture permit to test easily the ViewModel part.

### Generated

To test our **ViewModel**, test equality of **State** which is declared in **Enum** which could contain various type. To avoid boilerplate code by following protocol **Equatable**, we use **Sourcery** to generate equalilty operator.

## Environments

I added fastlane to help us in **Continuous Integration**. We achieved this with environment files (of Ruby) and **.xcconfig** concept to handle our 3 _virtual_ environments (development, staging, production).

## Lessons learned

SwiftUI and Combine are powerful tools. It is amazing to have a built-in framework for **Function Reactive Programming**.
I enjoyed to set UI by declarative way and appreciated the previews to see each state of our views.
It is not hard to keep separation of concerns with SwiftUI (especially the **View** part).
I still have to practice to see if SwiftUI/Combine are production ready.


![Gamebook Engine](/images/github-title.png?raw=true)

Gamebook Engine is an iOS app for creating and playing gamebooks, a type of interactive fiction where the player gets to make decisions that influence the story.

## Features

* [x] Import and play gamebooks
* [x] Create gamebooks right on your iPad or iPhone
* [x] Export games to non-proprietary JSON files (`.gbook`)
* [ ] Analyzer ensures you don't create any unreachable pages or dead-ends

## Screenshots

![Gamebook Engine Screenshots](/images/github-screenshots.jpg?raw=true)

## Beta Test

If you're interested in using pre-release versions of Gamebook Engine and providing feedback, you can join the beta!

**[Sign up for the beta on TestFlight](https://testflight.apple.com/join/FjHHmoVy)**

## Gamebook Structure

* **Attributes**
  * These are essentially just global variables shared throughout a game
  * They hold a name, and an decimal value which defaults to 0.0
* **Pages**
  * **Content**
    * The text of the page, formatted with a limited set of Markdown attributes
  * **Consequences**
    * Method for manipulating a player's stored attributes
    * A consequence can affect attributes in three ways:
      * Set (to a value)
      * Increment (by a value)
      * Decrement (by a value)
      * Multiply (by a value)
  * **Decisions**
    * **Destination**
      * The page that the decision leads to
    * **Rules**
      * Match Any or All rules (based on the value of Attributes) to determine if a decision appears on the page

If you're curious about what an exported Gamebook looks like, view [An Introduction to Gamebook Engine.gbook](https://github.com/amiantos/gamebookengine/blob/master/GamebookEngine/Built-in%20Gamebooks/An%20Introduction%20to%20Gamebook%20Engine.gbook) as a simple example.

## To Install

1. `git clone https://github.com/amiantos/gamebookengine.git`
2. Open `GamebookEngine.xcworkspace` in Xcode 11 or higher.
3. Build :)

## Authors

* Brad Root - [amiantos](https://github.com/amiantos)
* Jerry Turcios - [jerryturcios08](https://github.com/jerryturcios08)

## Credits

* The app icon features the icon [magic, by Smalllike](https://thenounproject.com/icon/2721149/)

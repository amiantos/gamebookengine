# BRGamebookEngine

BRGamebookEngine is an open source iOS app for creating and playing "gamebooks", which are essentially interactive books where you get to make decisions that influence the story. For example, a popular brand of gamebook is Choose Your Own Adventure®, of which this project has no association.

## Features

* Create classic (or more advanced) gamebooks right on your iDevice
* Export and import games from non-proprietary JSON files
* Analyzer ensures you don't create any unreachable pages or dead-ends

## Gamebook Structure

* **Attributes**
  * These are essentially just global variables shared throughout a game
  * They hold a name, and an integer value which defaults to 0
* **Pages**
  * **Content**
    * The text of the page, written in [CommonMark](https://commonmark.org)
  * **Consequences**
    * The consequences of landing on a given page
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

## To Install

1. `git clone https://github.com/amiantos/brgamebookengine.git`
2. Open `BRGamebookEngine.xcworkspace` in Xcode 10.3 or higher.
3. Build :)

## Author

* Brad Root - [amiantos](https://github.com/amiantos)

## Credits

* The app icon features the icon [magic, by Smalllike](https://thenounproject.com/icon/2721149/)

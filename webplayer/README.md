# Gamebook Engine Web Player

A self-contained HTML5 web player for .gbook files created with Gamebook Engine.

## Features

- **Single File**: The entire player is contained in one HTML file - no dependencies, no build process
- **Drag & Drop**: Simply drag and drop a .gbook file onto the page to start playing
- **Auto-Save**: Your progress is automatically saved to browser localStorage
- **Markdown Support**: Full support for Markdown formatting in page content
- **Attribute System**: Supports the full attribute system including consequences and rules
- **Dark Mode**: Automatically adapts to your system's dark/light mode preference
- **Responsive Design**: Works on desktop, tablet, and mobile devices

## Usage

### Playing a Game

1. Open `index.html` in any modern web browser
2. Either:
   - Drag and drop a .gbook file onto the page, or
   - Click "Choose File" to select a .gbook file from your device
3. Start playing! Your progress is automatically saved as you play

### Controls

- **Restart Game**: Clears your progress and starts over from the beginning
- **Load Different Game**: Returns to the import screen to load a different .gbook file

## How It Works

### Save System

Progress is automatically saved to the browser's localStorage after each decision:
- Current page position
- All attribute values

Each game is saved separately using its UUID, so you can play multiple games without conflicts.

### Supported Features

The web player supports all Gamebook Engine features:

- **Pages**: First pages, normal pages, and ending pages
- **Decisions**: Choices that navigate between pages
- **Rules**: Conditional logic (equal, not_equal, greater_than, less_than)
- **Match Styles**: Both match_all and match_any rule evaluation
- **Attributes**: Numeric values tracked throughout the game
- **Consequences**: Modify attributes (set, add, subtract, multiply)
- **Markdown**: Headers, bold, italic, links, lists, blockquotes, and code
- **Fonts**: Serif and sans-serif font options

## Technical Details

- Pure HTML, CSS, and JavaScript - no external dependencies
- Markdown parser built from scratch for lightweight performance
- localStorage API for save game persistence
- Responsive CSS with dark mode support via prefers-color-scheme

## Testing

The player has been tested with:
- A Pirate Adventure.gbook (basic game without attributes)
- An Introduction to Gamebook Engine.gbook (game with attributes and rules)

## Browser Compatibility

Works in all modern browsers that support:
- ES6 JavaScript
- localStorage API
- CSS Grid and Flexbox
- File API

Tested in: Chrome, Firefox, Safari, and Edge (all current versions)

## License

Same license as Gamebook Engine (MIT License)
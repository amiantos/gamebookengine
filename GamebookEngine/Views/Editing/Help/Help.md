# Building Gamebooks

There are several core building blocks that should be understood to make games: Attributes, Pages, Decisions, and Consequences. Let's talk about them!

## Attributes

Attributes are values that you want to track changes to as the game progresses. They're simply a numerical value that you can manipulate in various ways as the player progresses through the game.

Consequences are assigned to a Page to manipulate Attributes.

## Pages

Pages are the core building block of any gamebook: a gamebook is composed of a series of Pages, linked to together by Decisions. At the bottom of every Page, the list of available Decisions is shown to the player for them to choose between.

## Decisions

Decisions link to other Pages. Their availability on a page can be determined by checking the value of Attributes (by setting up Rules), allowing you to create dynamic gamebooks that change in subtle ways due to the player's decisions.

## Consequences

Consequences are assigned on the Page level and manipulate the player's Attribute values when they land on that page.

For example, on the first page you could `Set Health to 100`, and if the player is wounded on a Page, you could create a Consequence on that page which will `Subtract Health by 20`, to create a record that the player is now down to `80 Health`.

On a later page, you could create a Decision that has a rule for `Health is less than 100` that allows the player to ask for aid. You can use this functionality in all sorts of ways, to track relationships the player has to other characters, whether they've experienced certain events, or much more. The possibilities are endless!

# Distributing Gamebooks

You can export your Gamebook to a file, which contains all the information about your gamebook in the JSON format. You can use this to share your game with friends or family, they just need to download BRGamebookEngine and import the file.

# 42889 iOS Application Development
## Developer: Yudong Lu
## Student ID: 25520723

Project Overview
 	•	Customizable Settings
Players can set their player name, game duration, and maximum number of bubbles.

	•	Menu Navigation
From the Menu, users can access game contents, game settings, game rules, and player high score easily.

	•	Pre-game Countdown
A countdown is displayed before the game begins.

	•	Dynamic Bubble Generation
Bubbles appear at random positions.

	•	Gmae Mode Distinction
It's up to players to play with a easy mode or hard mode in which a portion of bubbles will be refreshed every second.

	•	Game Control
Game can be paused (Stop) and resumed (Continue) during play, it's up to players.

	•   High Score System
Final scores are saved locally. Only the top 7 scores are displayed on the High Score Board.

	•	Difficulty Mode Display
Game mode and other settings are recorded and displayed in the high score records.



 ### View Layout
                ContentView
                      |
                      v
       RuleView <- MenuView -> SettingView -> GameView
                      |
                      v
                HighScoreView

### Github Repository (Private)

 https://github.com/Daniel01010100/42889_iOS_Assignment2.git  
						

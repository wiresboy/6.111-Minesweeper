# 6.111-Minesweeper
6.111 Fall 2019 Final Project

### Abstract: 
https://docs.google.com/document/d/1kpicSI_NTm1OP2iNs3wL2pfns05RuejjrBN7lXaf5ao/edit

### Proposal: 
https://docs.google.com/document/d/18RjtbRTTLjeQtlkCTbx3Tp7d5UVSjf1g_FCGGwVLvWc/edit


# Abstract
Our project will be to create the classic arcade game “minesweeper” on an FPGA. Minesweeper traditionally involves a grid upon which the player can click to guess whether a cell is an empty cell or contains a mine. If they click on a mine, then the game is over. If they click on an empty cell, the cell will reveal how many neighboring cells have mines.

This FPGA implementation will involve several core modules: VGA or HDMI to draw and interact with the game, FSMs to run the game logic, sound effects through piezoelectric speakers, and a USB-HID mouse to interact with the game. As stretch goals for the project we hope to use SD card or flash storage to create a leaderboard of fastest times by level difficulty and potentially ethernet to have several independent FPGAs communicate their leaderboards and combine them or have multiplayer minesweeper (race to who can clear the board fastest, or have one person place bombs and the other clear, etc.)

--[[

  _   _ ______ _______    _____ _ _     _           _                   
 | \ | |  ____|__   __|  / ____| (_)   | |         | |                  
 |  \| | |__     | |    | (___ | |_  __| | ___  ___| |__   _____      __
 | . ` |  __|    | |     \___ \| | |/ _` |/ _ \/ __| '_ \ / _ \ \ /\ / /
 | |\  | |       | |     ____) | | | (_| |  __/\__ \ | | | (_) \ V  V / 
 |_| \_|_|       |_|    |_____/|_|_|\__,_|\___||___/_| |_|\___/ \_/\_/  
                                                                        
                                                                        
NFT Slideshow allows creators to display NFTs in a slideshow format.

The NFTs can be filtered by owners, contract addresses, and token ids.

The slideshow is displayed and updated in screen-space and world-space UI.

=====
Setup
=====

1) Drag and drop the "Example Scene" template into the Hierarchy.
2) Preview the project.
3) Approach the signs and interact with the trigger to view the On Screen Slideshow.
4) Stop the preview. Select one of the NFT Slideshow template root object and open the Properties window.
5) Change the custom properties to desired NFT filter options.

==========
How to use
==========

The root of the template contains 6 custom properties.

- Title

This string will be displayed on the world and screen slideshow UI.

- Use Local Player

If true, then the local player's NFTs will be displayed.

- Owner Addresses

A comma-seperated list of owner addresses to use in the slideshow.

- Contract Addresses

A comma-seperated list of contract addresses to filter the NFTs in the slideshow.

- Token Ids

A comma-seperated list of token ids to filter the NFTs in the slideshow.

Disable Trigger

If true then the trigger will be disabled. This is useful for a single image that doesn't need a slideshow.

======
Devlog
======

1.1

- Trigger events now checks for local player only

1.2

- Deprecated `GetTokensForPlayer` is removed
- Uses `GetWalletsForPlayer` instead
- Image Template updated to use Aspect Ratio
- Disable Trigger custom property added

]]--
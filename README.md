<div align="center">

# NFT Slideshow

[![Build Status](https://github.com/ManticoreGamesInc/CC-NFT-Slideshow/workflows/CI/badge.svg)](https://github.com/ManticoreGamesInc/CC-NFT-Slideshow/actions/workflows/ci.yml?query=workflow%3ACI%29)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/ManticoreGamesInc/CC-NFT-Slideshow?style=plastic)

![TitleCard](/Screenshots/NFT_Slideshow.png)

</div>

## Finding the Component

This component can be found under the **CoreAcademy** account on Community Content.

## Overview

NFT Slideshow allows creators to display NFTs in a slideshow format.

The NFTs can be filtered by owners, contract addresses, and token ids.

The slideshow is displayed and updated in screen-space and world-space UI.

## Setup

1) Drag and drop the "Example Scene" template into the Hierarchy.
2) Preview the project.
3) Approach the signs and interact with the trigger to view the On Screen Slideshow.
4) Stop the preview. Select one of the NFT Slideshow template root object and open the Properties window.
5) Change the custom properties to desired NFT filter options.

## How to use

The root of the template contains 6 custom properties.

- Title

This string will be displayed on the world and screen slideshow UI.

- Use Local Player

If true, then the local player's NFTs will be displayed.

- Owner Addresses

A comma-separated list of owner addresses to use in the slideshow.

- Contract Addresses

A comma-separated list of contract addresses to filter the NFTs in the slideshow.

- Token Ids

A comma-separated list of token ids to filter the NFTs in the slideshow.

Disable Trigger

If true then the trigger will be disabled. This is useful for a single image that doesn't need a slideshow.


# Ads

We use the free DoubleClick for Publishers (DFP) for our ad serving needs on the sites. 

## Terminology

**Ad server** - When a reader visits one of our pages, requests to an ad server are returned with an advertisement for the visitor to see.

**Ad unit** - An ad unit is an area on our site that we dedicate to an advertisement. We give the ad unit a name and associate what size ads should be served by that unit.

**Targeting** - We can control which ads show up where with targeting. Things like the ad unit, device type, geographic area of the visitor, can all be targeted. 

**Placements** - Placements are groups of ad units. Example: A placement of all of the ad units that are shown in the stream. An ad can be targeted to one placement instead of targeting to multiple ad units manually.

**Orders** - An ad buy from an advertiser. Another way to think of it is as an account for a particular advertiser.

**Line Items** - A set of requirements for an ad to show, including how and when the ads should be shown, the sizes of the creatives it should show and the order in which to show them. Line items are part of an order.

**Creatives** - The actual ad whether it is images or HTML. Multiple creatives can be associated with a line item.

## Prefixes
We use prefixes to distinguish the different sites:

- `BP` - Billy Penn (Philadelphia)
- `PGH` - The Incline (Pittsburgh)

## Loading an Ad in DFP

Here's a workflow for loading a brand new ad into DFP.

### Create a New Order
Prefix it with your site's prefix followed by the name of your advertiser, `BP - The Pretzel Factory` or `PGH - S&T Bank`.

#### Settings:

- *Type*: See https://support.google.com/dfp_sb/answer/177279?hl=en
- *Start Time*: When the ad campaign should start delivering
- *End Time*: When the ad campaign should stop delivering
- *Quantity*: TKTKTK
- *Rate*: TKTKTK
- *Discount*: TKTKTK

#### Adjust Delivery
TKTKT


### Add a New Line Item
Create a new line item for the campaign like `Spring 2017 Campaign` or `Winter Sponsorship`

Enter all of the inventory sizes for the creatives associated with the ad campaign.

- *Type*: See https://support.google.com/dfp_sb/answer/177279?hl=en
- *Start Time*: When the ad campaign should start delivering
- *End Time*: When the ad campaign should stop delivering
- *Quantity*: TKTKTK
- *Rate*: TKTKTK
- *Discount*: TKTKTK

#### Adjust Delivery
TKTKT

#### Add Targeting
Include the ad units where you want the ads for this line item to appear on the site. You can also select a Placement to target a group of ad units all at once.

### Adding Creatives

Line items need creatives to deliver to visitors. In the Line Item edit screen, click on the Creatives tab. Click the *Add Creatives* button. Here you can upload multiple images at once. DFP will automatically identify the sizes of the creatives.

### Delivery
Once an order is approved DFP will mark the order as Ready. This means the ad is good to go and waiting for requests from our sites to start delivering the ad. The amount of time between when an order is ready and delivering varies from 10 minutes to an hour.

## Testing An Ad
If you need to test an ad before going live you can target the ad to an unused ad unit and use our ad testing tool:

- https://billypenn.com/ad-tester/
- https://theincline.com/ad-tester/

Enter the name of the ad unit and the size or sizes you want to display and click the *Test Ad Unit* button. The URL for that ad test can be copied and shared with anyone. 

## Ad Units
We define various ad units based on their position on the page. Our ad units can have multiple different ad sizes associated with them. To see all of the ad units on a page add `?show-ad-units` to the end of a URL. Example: https://billypenn.com/?show-ad-units or https://theincline.com/2017/03/21/parents-advocates-push-for-pittsburgh-to-end-suspensions-for-younger-students/?show-ad-units

If there are multiple sizes associated with an ad unit you can click on the ad units to cycle through different sizes. The ad unit sizes can change based on the size of your browser. Resize the browser and refresh the page to see ad units for mobile.

### Business Logic
There are various rules we have put in place via code to make sure certain sized ads appear in the correct place.

- If the width of the ad is larger than the width of the browser window, then don't show that ad size.
- 300x250 ads in the stream should only be shown if the browser window is less than 640px wide.
- 640x150 ads in the stream should only be shown if the browser window width is 640px or greater.

### For Devs
Adding an ad unit is a matter of calling the `macros.dfp_unit()` twig function. It takes two arguements: 1) the ad unit code, 2) a comma separated list of sizes supported by the ad unit. Example `{{ macros.dfp_unit( 'PGH_Stream_04', '640x150,300x250,300x450' ) }}`. This ad unit can be targeted in DFP for `PGH_Stream_04` and supports the sizes `640x150`, `300x250`, or `300x450`. 

Ad units are registered dynamically based on the markup of the page via `dfp-load.js`.


record SmashedItem
{
    item it;
    float wads_found;
};

SmashedItem SmashedItemMake(item it, float wads_found)
{
    SmashedItem result;
    result.it = it;
    result.wads_found = wads_found;
    return result;
}

void listAppend(SmashedItem [int] list, SmashedItem entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

        
void pulverizeAlterOutputList(string [int] output_list)
{
    //Alter lines so items aren't split up by word wrap:
    int number_seen = 0;
    foreach key in output_list
    {
        string line = output_list[key];
        
        if (number_seen < output_list.count() - 1) //comma needs to be part of the group
            line += ",";
        line = HTMLGenerateDivOfClass(line, "r_word_wrap_group");
        
        output_list[key] = line;
        number_seen += 1;
    }
}
void SPulverizeGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    if (!$skill[pulverize].have_skill())
        return;
    if (!in_ronin()) //list is far too long with your main inventory, and you can buy wads at this point
        return;
    
    
    /*
     Smashable item types:
     BRICKO brick
     candycaine powder
     chunk of depleted Grimacite
     cold cluster
     cold nuggets
     cold powder
     cold wad
     corrupted stardust
     effluvious emerald
     epic wad
     glacial sapphire
     handful of Smithereens
     hot cluster
     hot nuggets
     hot powder
     hot wad
     sea salt crystal
     sleaze cluster
     sleaze nuggets
     sleaze powder
     sleaze wad
     spooky cluster
     spooky nuggets
     spooky powder
     spooky wad
     steamy ruby
     stench cluster
     stench nuggets
     stench powder
     stench wad
     sugar shard
     tawdry amethyst
     twinkly nuggets
     twinkly powder
     twinkly wad
     ultimate wad
     unearthly onyx
     useless powder
     wad of Crovacite
     */
    
    boolean [item] smashables_wanted = $items[cold wad,hot wad,sleaze wad,spooky wad,stench wad];
    
    string [int] details;
    
    string blacklist_string = "fireman's helmet,fire axe,enchanted fire extinguisher,fire hose,rainbow pearl earring,rainbow pearl necklace,rainbow pearl ring,steaming evil,ring of detect boring doors,giant discarded torn-up glove,giant discarded plastic fork,giant discarded bottlecap,toy ray gun,toy space helmet,toy jet pack,MagiMechTech NanoMechaMech,astronaut pants,ancient hot dog wrapper";
    
    if (!__quest_state["Level 13"].state_boolean["past keys"])
        blacklist_string += ",Tambourine,jungle drum,hippy bongo,bone rattle,black kettle drum,big bass drum";
    if (!__quest_state["Level 12"].finished)
        blacklist_string += ",reinforced beaded headband,bullet-proof corduroys,round purple sunglasses,beer helmet,distressed denim pants,bejeweled pledge pin";
    if (!__quest_state["Level 11 Hidden City"].state_boolean["Hospital finished"])
        blacklist_string += ",head mirror,surgical apron,bloodied surgical dungarees,surgical mask,half-size scalpel";
    string [int] blacklist_source = split_string_alternate(blacklist_string, ",");
    boolean [item] blacklist;
    foreach key in blacklist_source
        blacklist[blacklist_source[key].to_item()] = true;
    
    SmashedItem [int] available_smashed_items;
    //To generate a list of everything:
    //clear; ashq foreach it in $items[] if (it.get_related("pulverize").count() > 0 && it.tradeable && !it.quest && it.discardable && it.get_related("pulverize").to_json().contains_text("wad")) print(it.entity_encode());
    //We use this method because it's faster (saves ~20ms or so?) than iterating through all the items.
    foreach it in $items[yakskin pants,acoustic guitarrr,mesh cap,leather chaps,batblade,denim axe,heavy metal thunderrr guitarrr,drywall axe,ridiculously huge sword,Mohawk wig,giant needle,glowing red eye,furry pants,wolf mask,star sword,star crossbow,star staff,star pants,star hat,star buckler,star shirt,giant discarded plastic fork,yakskin skirt,yakskin kilt,furry skirt,furry kilt,giant discarded bottlecap,giant discarded torn-up glove,star spatula,hippy protest button,Lockenstock&trade; sandals,didgeridooka,bullet-proof corduroys,round purple sunglasses,wicker shield,black sword,black helmet,black shield,kick-ass kicks,beer helmet,distressed denim pants,perforated battle paddle,toy ray gun,toy space helmet,astronaut pants,toy jet pack,pygmy nose-bone,big bad voodoo mask,pygmy spear,headhunter necktie,pointed stick,black belt,lead pipe,reinforced beaded headband,fire poi,bejeweled pledge pin,Gaia beads,hippy medical kit,Slow Talkin' Elliot's dogtags,longhaired hippy wig,C.A.R.N.I.V.O.R.E. button,orange peel hat,flowing hippy skirt,bottle opener belt buckle,keg shield,giant foam finger,war tongs,asbestos apron,beaten-up Chucks,wreath of laurels,Danglin' Chad's loincloth,tube sock,energy drink IV,Elmley shades,beer bong,goatskin umbrella,wool hat,round green sunglasses,Ankh of Badahnkadh,giant cactus quill,wonderwall shield,palm-frond capris,extra-large palm-frond toupee,palm-frond cloak,Iiti Kitty phone charm,nasty rat mask,ratskin belt,bat hat,bat-ass leather jacket,catskin cap,catskin buckler,mummy mask,gauze shorts,black greaves,black cowboy hat,Maxwell's Silver Hammer,happiness,armgun,beer-a-pult,cast-iron legacy paddle,giant driftwood sculpture,massive sitar,stone baseball cap,blackberry slippers,blackberry moccasins,blackberry combat boots,battered hubcap,shiny hood ornament,furniture dolly,Earring of Fire,Pendant of Fire,Ring of Fire,Ice-Cold Beerring,Ice-Cold Aluminum Necklace,Ice-Cold Beer Ring,Unspeakable Earring,Choker of the Ultragoth,The Ring,Nose Ring of Putrescence,Putrid Pendant,Ring of the Sewer Snake,Mudflap-Girl Earring,Mudflap-Girl Necklace,Mudflap-Girl Ring,grumpy old man charrrm bracelet,tarrrnished charrrm bracelet,witty rapier,yohohoyo,booty chest charrrm bracelet,cannonball charrrm bracelet,copper ha'penny charrrm bracelet,silver tongue charrrm bracelet,buoybottoms,grungy flannel shirt,grungy bandana,grassy cutlass,solid gold pegleg,flamin' bindle,freezin' bindle,stinkin' bindle,spooky bindle,sleazy bindle,'WILL WORK FOR BOOZE' sign,panhandle panhandling hat,cup of infinite pencils,gatorskin umbrella,C.H.U.M. knife,lucky bottlecap,corncob pipe,Mr. Joe's bangles,frayed rope belt,club of the five seasons,rainbow crossbow,groovy prism necklace,six-rainbow shield,decaying wooden oar,giant fishhook,rusty old lantern,jungle drum,world's smallest violin,a butt tuba,charming flute,black kettle drum,magilaser blastercannon,frozen seal spine,rusty piece of rebar,cyber-mattock,X-37 gun,crown-shaped beanie,hopping socks,poodle skirt,letterman's jacket,silver pat&eacute; knife,silver cheese-slicer,pipe wrench,sleep mask,sock garters,heavy leather-bound tome,guard turtle shell,crowbar,spaghetti cult rosary,spaghetti cult mask,spangly mariachi pants,spangly mariachi vest,spangly sombrero,snailmail coif,snailmail breeches,snailmail hauberk,T&Icirc;&curren;&loz;lisman of Bai&oslash;&Dagger;,blackberry galoshes,trout fang,bindlestocking,keel-haulin' knife,ancient ice cream scoop,auxiliary backbone,gold crown,flaming sword,giant gym membership card,giant penguin keychain,giant turkey leg,pewter claymore,giant artisanal rice peeler,brown felt tophat,Mark I Steam-Hat,Mark II Steam-Hat,Mark III Steam-Hat,Mark IV Steam-Hat,Mark V Steam-Hat,punk rock jacket,giant safety pin,floral-print skirt,spectral axe,super-strong air freshener,Mer-kin gutgirdle,antique machete,surgical mask,head mirror,half-size scalpel,surgical apron,bloodied surgical dungarees,short-handled mop,smirking shrunken head,attorney's badge,pygmy briefs,sphygmomanometer,compression stocking,midriff scrubs,cold water bottle,accordionoid rocca,pygmy concertinette,ghost accordion,peace accordion,alarm accordion,fire hose,plain paper hat,&quot;honey&quot; dipper,skull gearshift knob,Sketcherz&trade;,unrequired jacket,tommy gun,breadchucks,combat fan,red silk skirt,Saturday Night Special,black blade,Jefferson wings,lynyrdskin cap,lynyrdskin tunic,lynyrdskin breeches,Kashmir sweater,red book,red masque,red hot poker,Red X Shield,red badge,red shirt,red coat,red shoe,coal shovel,Bram's choker,plaid pocket square,plaid skirt,sommelier's towel,tarnished tastevin,ghast iron cleaver,ghast iron Garibaldi,ghast iron heater shield,ghast iron codpiece,Pendant of Gargalesis,8-billed baseball cap,extremely wet T-shirt,giant shrimp fork,little black book,black cloak,Lord Soggyraven's Slippers,rubber cape,vampire pellet,unsanitized scalpel]
    {
        //if (!it.tradeable || it.quest || !it.discardable) //probably valuable
            //continue;
        if (it.available_amount() == 0)
            continue;
        int [item] pulverizations = it.get_related("pulverize");
        if (pulverizations.count() == 0)
            continue;
        if (blacklist[it])
            continue;
        
        
        int total_desired_smash_items_acquired = 0;
        foreach smashed_item in pulverizations
        {
            int smash_amount = pulverizations[smashed_item];
            if (!smashables_wanted[smashed_item])
                continue;
            
            total_desired_smash_items_acquired += smash_amount;
        }
        if (total_desired_smash_items_acquired > 0)
        {
            float average_total_smash_items_acquired = total_desired_smash_items_acquired.to_float() / 1000000.0;
            available_smashed_items.listAppend(SmashedItemMake(it, average_total_smash_items_acquired));
            
        }
    }
    
    sort available_smashed_items by -(value.wads_found * value.it.available_amount());
    
    int total_number_available = 0;
    string [int] spleen_wad_output_list;
    foreach key in available_smashed_items
    {
        SmashedItem smashed_item = available_smashed_items[key];
        string line;
        
        line = smashed_item.it;
        
        spleen_wad_output_list.listAppend(line);
        total_number_available += smashed_item.it.available_amount();
    }
    if (true)
    {
        pulverizeAlterOutputList(spleen_wad_output_list);
    }
    if (spleen_wad_output_list.count() > 0 && !(availableSpleen() == 0 || my_path_id() == PATH_SLOW_AND_STEADY))
        details.listAppend("Can smash " + spleen_wad_output_list.listJoinComponents(" ", "and").capitalizeFirstLetter() + " for spleen wads.");
    
    
    if (($classes[sauceror,pastamancer] contains my_class()) && guild_store_available() && $skill[Transcendental Noodlecraft].have_skill() && $skill[The Way of Sauce].have_skill()) //can make hi mein?
    {
        string [int] elemental_nuggets_list;
        
        foreach it in $items[icy-hot katana,frozen nunchaku,asbestos helmet turtle,flaming talons,titanium assault umbrella,glowing red eye,furry pants,spiked femur,lihc face,rusty grave robbing shovel,clockwork hat,spooky bicycle chain,furry skirt,furry kilt,ring of cold resistance,ring of fire resistance,Cerebral Crossbow,giant discarded torn-up glove,flypaper staff,smoldering staff,hot cross bow,carob cannon,shuddersword,projectile icemaker,buffalo blade,giant cheesestick,potato pistol,goulauncher,enchantlers,ram-battering staff,Snow Queen Crown,broken sword,lupine sword,round purple sunglasses,kick-ass kicks,distressed denim pants,makeshift turban,eXtreme Bi-Polar Fleece Vest,toy ray gun,toy space helmet,Gaia beads,asbestos apron,wool hat,demon buckler,demonskin jacket,gnauga hide vest,palm-frond cloak,Iiti Kitty phone charm,mummy mask,happiness,Earring of Fire,Pendant of Fire,Ring of Fire,Ice-Cold Beerring,Ice-Cold Aluminum Necklace,Ice-Cold Beer Ring,Unspeakable Earring,Choker of the Ultragoth,The Ring,Nose Ring of Putrescence,Putrid Pendant,Ring of the Sewer Snake,Mudflap-Girl Earring,Mudflap-Girl Necklace,Mudflap-Girl Ring,shamanic beads,dilapidated wizard hat,tarrrnished charrrm bracelet,yohohoyo,grungy bandana,gatorskin umbrella,C.H.U.M. lantern,C.H.U.M. knife,club of the five seasons,rainbow crossbow,jungle drum,a butt tuba,bone flute,magilaser blastercannon,turtlemail breeches,infernal toilet brush,shadowy seal eye,Abyssal ember,frozen seal spine,mannequin leg,painted shield,tortoboggan shield,sock garters,snailmail breeches,The Lost Glasses,skeleton skis,Bonestabber,iron helmet,gold crown,flaming sword,orcish stud-finder,Whoompa Fur Pants,stolen necklace,oil cap,oil lamp,floral-print skirt,spectral axe,super-strong air freshener,head mirror,short-handled mop,pygmy briefs,midriff scrubs,cold water bottle,boilgun,tin tam,tin drum,bone bandoneon,pentatonic accordion,autocalliope,ghost accordion,peace accordion,fire hose,plain paper hat,skull gearshift knob,breadchucks,combat fan,Saturday Night Special,black blade,Jefferson wings,Kashmir sweater,red masque,red hot poker,red shoe,rubber ribcage,half-melted spoon,creepy doll head,haunted paddle-ball,ghost toga,coal shovel,ghast iron cleaver,ghast iron Garibaldi,ghast iron codpiece,space heater,space needle,silent pea shooter,frozen turtle shell,plastic nunchaku,radiator heater shield,heavy-duty clipboard,jangly bracelet]
        {
            if (it.available_amount() == 0)
                continue;
            elemental_nuggets_list.listAppend(it);
        }
        
        
        pulverizeAlterOutputList(elemental_nuggets_list);
        if (elemental_nuggets_list.count() > 0)
            details.listAppend("Can smash " + elemental_nuggets_list.listJoinComponents(" ", "and").capitalizeFirstLetter() + " for elemental nuggets for hi meins.");
    }
    
    
    
    string [int] coal_output_list;
    
    foreach it in $items[A Light that Never Goes Out,Frankly Mr. Shank,Hairpiece On Fire,Half a Purse,Hand in Glove,Hand that Rocks the Ladle,Meat Tenderizer is Murder,Ouija Board\, Ouija Board,Saucepanic,Shakespeare's Sister's Accordion,Sheila Take a Crossbow,Staff of the Headmaster's Victuals,Vicar's Tutu,Work is a Four Letter Sword]
    {
        if (it.available_amount() > 1)
            coal_output_list.listAppend(it.pluralize());
        else if (it.available_amount() > 0)
            coal_output_list.listAppend(it);
    }
    pulverizeAlterOutputList(coal_output_list);
    if (coal_output_list.count() > 0)
        details.listAppend("Can smash " + coal_output_list.listJoinComponents(" ", "and").capitalizeFirstLetter() + " for handful of smithereens.");
    
    
    
    if (details.count() > 0)
    {
        string title;
        title = "Pulverizable equipment";
        string url = "craft.php?mode=smith";
        if ($item[tenderizing hammer].available_amount() == 0)
        {
            url = "store.php?whichstore=s";
            details.listAppend("Acquire a tenderizing hammer.");
        }
        available_resources_entries.listAppend(ChecklistEntryMake("pulverize", url, ChecklistSubentryMake(title, "", details), 10));
    }
}
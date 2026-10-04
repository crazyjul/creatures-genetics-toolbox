package creatures;

/**
 * Names of the Creatures 3 chemicals, by chemical number.
 *
 * Numbers and names are taken from the Creatures Wiki's "C3 Chemical List"
 * (https://creatures.fandom.com/wiki/C3_Chemical_List, CC BY-SA). The game calls any chemical that is not
 * listed "unknownase"; it has no effect.
 */
class Chemicals {
    static var table : Map<Int, String>;

    static var Names : Array<Array<Dynamic>> = [
        [1, "Lactate"], [2, "Pyruvate"], [3, "Glucose"], [4, "Glycogen"], [5, "Starch"], [6, "Fatty acid"],
        [7, "Cholesterol"], [8, "Triglyceride"], [9, "Adipose tissue"], [10, "Fat"], [11, "Muscle tissue"],
        [12, "Protein"], [13, "Amino acid"], [17, "Downatrophin"], [18, "Upatrophin"],
        [24, "Dissolved carbon dioxide"], [25, "Urea"], [26, "Ammonia"], [29, "Air"], [30, "Oxygen"],
        [33, "Water"], [34, "Energy"], [35, "ATP"], [36, "ADP"], [39, "Arousal potential"],
        [40, "Libido lowerer"], [41, "Opposite sex pheromone"], [46, "Oestrogen"], [48, "Progesterone"],
        [53, "Testosterone"], [54, "Inhibin"], [66, "Heavy metals"], [67, "Cyanide"], [68, "Belladonna"],
        [69, "Geddonase"], [70, "Glycotoxin"], [71, "Sleep toxin"], [72, "Fever toxin"], [73, "Histamine A"],
        [74, "Histamine B"], [75, "Alcohol"], [78, "ATP decoupler"], [79, "Carbon monoxide"],
        [80, "Fear toxin"], [81, "Muscle toxin"],
        [82, "Antigen 0"], [83, "Antigen 1"], [84, "Antigen 2"], [85, "Antigen 3"], [86, "Antigen 4"],
        [87, "Antigen 5"], [88, "Antigen 6"], [89, "Antigen 7"],
        [90, "Wounded"], [92, "Medicine one"], [93, "Anti-oxidant"], [94, "Prostaglandin"], [95, "EDTA"],
        [96, "Sodium thiosulphate"], [97, "Arnica"], [98, "Vitamin E"], [99, "Vitamin C"], [100, "Antihistamine"],
        [112, "Anabolic steroid"], [113, "Pistle"], [114, "Insulin"], [115, "Glycolase"], [116, "Dehydrogenase"],
        [117, "Adrenaline"], [118, "Grendel nitrate"], [119, "Ettin nitrate"], [121, "Protease"],
        [124, "Activase"], [125, "Life"], [127, "Injury"], [128, "Stress"], [129, "Sleepase"],
        [131, "Pain backup"], [132, "Hunger for protein backup"], [133, "Hunger for carb backup"],
        [134, "Hunger for fat backup"], [135, "Coldness backup"], [136, "Hotness backup"],
        [137, "Tiredness backup"], [138, "Sleepiness backup"], [139, "Loneliness backup"],
        [140, "Crowdedness backup"], [141, "Fear backup"], [142, "Boredom backup"], [143, "Anger backup"],
        [144, "Sex drive backup"], [145, "Comfort drive backup"],
        [148, "Pain"], [149, "Hunger for protein"], [150, "Hunger for carb"], [151, "Hunger for fat"],
        [152, "Coldness"], [153, "Hotness"], [154, "Tiredness"], [155, "Sleepiness"], [156, "Loneliness"],
        [157, "Crowded"], [158, "Fear"], [159, "Boredom"], [160, "Anger"], [161, "Sex Drive"],
        [162, "Comfort drive"],
        [165, "CA Sound"], [166, "CA Light"], [167, "CA Heat"], [168, "CA Water (from the sky)"],
        [169, "CA Nutrient (plants)"], [170, "CA Water (bodies of)"], [171, "CA Protein"],
        [172, "CA Carbohydrate"], [173, "CA Fat"], [174, "CA Flowers"], [175, "CA Machinery"],
        [176, "CA Creature egg"], [177, "CA Norn smell"], [178, "CA Grendel smell"], [179, "CA Ettin smell"],
        [180, "CA Norn home smell"], [181, "CA Grendel home smell"], [182, "CA Ettin home smell"],
        [183, "CA Gadget smell"], [184, "CA smell 19 [not used]"],
        [187, "Stress (high H4C) [hunger for carbohydrate]"], [188, "Stress (high H4P) [hunger for protein]"],
        [189, "Stress (high H4F) [hunger for fat]"], [190, "Stress (high Anger)"], [191, "Stress (high Fear)"],
        [192, "Stress (high Pain)"], [193, "Stress (high Tired)"], [194, "Stress (high Sleep)"],
        [195, "Stress (high Crowded)"],
        [198, "Disappointment"], [199, "Up"], [200, "Down"], [201, "Exit"], [202, "Enter"], [203, "Wait"],
        [204, "Reward"], [205, "Punishment"], [206, "Brain chemical 9"], [207, "Brain chemical 10"],
        [208, "Brain chemical 11"], [209, "Brain chemical 12"], [210, "Brain chemical 13"],
        [211, "Brain chemical 14"], [212, "Pre - REM"], [213, "REM"]
    ];

    static function names() : Map<Int, String> {
        if(table == null) {
            table = new Map<Int, String>();

            for(entry in Names) {
                table[entry[0]] = entry[1];
            }
        }

        return table;
    }

    /** Whether the chemical has a name in the game's list. */
    public static function isKnown(chemical : Int) : Bool {
        return names().exists(chemical);
    }

    /** The chemical's name; "Unknownase" for chemicals the game does not list, and "none" for chemical 0. */
    public static function name(chemical : Int) : String {
        if(chemical == 0) {
            return "none";
        }

        var found = names().get(chemical);

        return found != null ? found : "Unknownase";
    }

    /** The name followed by the number, as in "Protein (12)". */
    public static function label(chemical : Int) : String {
        return chemical == 0 ? "none" : name(chemical) + " (" + chemical + ")";
    }

    /** How many chemicals have names. */
    public static function knownCount() : Int {
        return Lambda.count(names());
    }
}

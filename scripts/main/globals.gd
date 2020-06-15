extends Node
#enum ROD_IDX {START, END, NONE}

enum PHYS_LAYERS {WORLD, RODS, BG_RODS}

#tools
enum TOOLS {LINETOOL, ERASETOOL, MOVETOOL, WHEELTOOL, BG_LINE_TOOL, MOTORTOOL, SAVETOOL, THRUSTERTOOL}

const PHYS_OBJECTS = [TOOLS.WHEELTOOL, TOOLS.MOTORTOOL, TOOLS.THRUSTERTOOL]

signal gravity_change(gravityStatus)
const GRAVITY_CHANGE_SIGNAL = "gravity_change"


signal interactive_object_clicked
const INTERACTIVE_OBJECT_CLICKED = "interactive_object_clicked"

var ROD_COLOR = ColorN("Yellow")
var BG_ROD_COLOR = ColorN("Blue")
const ROD_THICKNESS = 5.0
const JOINT_RADIUS = 4.0
const NEAR_JOINT_RADIUS = 7.0
const ROD_ATTACH_MOUSE_HOVER_DIST = 10
const BASE_WEIGHT = .04

func _ready():
	pass

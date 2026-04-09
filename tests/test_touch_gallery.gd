extends RefCounted

var _GalleryScript: GDScript = preload(
	"res://scripts/ui/card_gallery_ui.gd"
)

const PILE_ORDER: Array[String] = ["draw", "hand", "discard"]


func test_swipe_to_pile_forward_cycles() -> void:
	var gallery := Control.new()
	gallery.set_script(_GalleryScript)
	gallery.call("set_active_pile", "hand")
	gallery.call("swipe_to_pile", 1)
	var pile: String = gallery.call("get_active_pile") as String
	TestAssert.assert_eq(
		pile, "discard",
		"swipe left from hand goes to discard"
	)


func test_swipe_to_pile_backward_cycles() -> void:
	var gallery := Control.new()
	gallery.set_script(_GalleryScript)
	gallery.call("set_active_pile", "hand")
	gallery.call("swipe_to_pile", -1)
	var pile: String = gallery.call("get_active_pile") as String
	TestAssert.assert_eq(
		pile, "draw",
		"swipe right from hand goes to draw"
	)


func test_swipe_to_pile_wraps_forward() -> void:
	var gallery := Control.new()
	gallery.set_script(_GalleryScript)
	gallery.call("set_active_pile", "discard")
	gallery.call("swipe_to_pile", 1)
	var pile: String = gallery.call("get_active_pile") as String
	TestAssert.assert_eq(
		pile, "draw",
		"swipe left from discard wraps to draw"
	)


func test_swipe_to_pile_wraps_backward() -> void:
	var gallery := Control.new()
	gallery.set_script(_GalleryScript)
	gallery.call("set_active_pile", "draw")
	gallery.call("swipe_to_pile", -1)
	var pile: String = gallery.call("get_active_pile") as String
	TestAssert.assert_eq(
		pile, "discard",
		"swipe right from draw wraps to discard"
	)


func test_get_active_pile_default_is_hand() -> void:
	var gallery := Control.new()
	gallery.set_script(_GalleryScript)
	var pile: String = gallery.call("get_active_pile") as String
	TestAssert.assert_eq(
		pile, "hand", "default active pile is hand"
	)


func test_set_active_pile_draw() -> void:
	var gallery := Control.new()
	gallery.set_script(_GalleryScript)
	gallery.call("set_active_pile", "draw")
	var pile: String = gallery.call("get_active_pile") as String
	TestAssert.assert_eq(pile, "draw")

class_name Buggy extends BoxContainer


@export var max_entries_visible: int = 10
@export var label_settings: LabelSettings:
	get:
		return label_settings if label_settings else preload("res://tools/buggy_label_settings.tres")


func add_entry(kname: String, node: Node) -> void:
	var existing := get_node_or_null(kname)
	if existing:
		push_error("entry with kname '%s' exists" % [ kname ])
		existing.name = "DELETED" + existing.name
		existing.queue_free()

	var entries: Array[Node] = get_children().filter(func(child:Node): return child is Control)
	var over := maxi(1 + entries.size() - max_entries_visible, 0)
	for i in range(over):
		var e := entries[i] as Control
		e.visible = false

	add_child(node)


func speaker_kname(speaker: Node, key: String) -> String:
	return "k%X" % [ hash(speaker) ^ hash(key) ]


func say(speaker: Node, key: String, msg) -> void:
	var kname := speaker_kname(speaker, key)
	var entry := get_node_or_null(kname) as Label
	if not entry:
		entry = Label.new()
		speaker.tree_exiting.connect(entry.queue_free)
		add_entry(key, entry)
	entry.name = kname
	_label(entry, "%s: %s" % [ key, msg ])


func _label(node: Label, text: String) -> void:
	node.text = text
	node.label_settings = label_settings
	node.visible = true


func _deferred_setup() -> void:
	var overlayer := get_node_or_null("/root/Overlayer")
	if overlayer:
		reparent(overlayer)


func _init() -> void:
	z_as_relative = false
	z_index = 99
	vertical = true


func _ready() -> void:
	call_deferred(&"_deferred_setup")

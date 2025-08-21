extends Node2D

# ลาก World/BG/TileMap (หรือที่ใช้จริง) มาใส่ใน Inspector ตรงนี้
@export var tilemap_path: NodePath

@onready var cam: Camera2D = $Player/Camera2D
@onready var tilemap: TileMap = get_node_or_null(tilemap_path) as TileMap

func _ready() -> void:
	cam.enabled = true
	cam.make_current()

	if tilemap == null:
		# ค้นหา TileMap ตัวแรกแบบ recursive โดย “พิมพ์ชนิด” ทุกตัวแปร
		tilemap = _find_first_tilemap(self)
		if tilemap == null:
			push_error("ไม่พบ TileMap: กรุณาลากโหนด TileMap ใส่ใน tilemap_path ที่ Inspector")
			return

	_set_camera_limits_from_tilemap(tilemap)


func _find_first_tilemap(node: Node) -> TileMap:
	for child: Node in node.get_children():
		if child is TileMap:
			return child as TileMap
		var found: TileMap = _find_first_tilemap(child)
		if found != null:
			return found
	return null


func _set_camera_limits_from_tilemap(t: TileMap) -> void:
	var used: Rect2i = t.get_used_rect()  # พื้นที่ที่มี tile จริง (หน่วยเป็น cell)

	var tl_local: Vector2 = t.map_to_local(used.position)
	var br_local: Vector2 = t.map_to_local(used.position + used.size)

	# แปลงเป็นพิกัดโลก เผื่อ TileMap อยู่ลึก/มีการย้ายตำแหน่ง
	var tl: Vector2 = t.to_global(tl_local)
	var br: Vector2 = t.to_global(br_local)

	cam.limit_left   = int(floor(min(tl.x, br.x)))
	cam.limit_top    = int(floor(min(tl.y, br.y)))
	cam.limit_right  = int(ceil(max(tl.x, br.x)))
	cam.limit_bottom = int(ceil(max(tl.y, br.y)))

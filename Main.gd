
extends Control

var save_path = "user://savegame.json"

# ============================
# Nhân vật
# ============================
var player = {
    "name": "Anh Hùng",
    "class": "Warrior",
    "hp": 100,
    "mp": 50,
    "exp": 0,
    "level": 1,
    "gold": 0,
    "inventory": [],
    "skills": ["Chém thường", "Skill đặc biệt"],
    "equipment": {
        "weapon_main": null,
        "weapon_sub": null,
        "armor_chest": null,
        "armor_pants": null,
        "ring": null,
        "necklace": null
    }
}

# ============================
# Quái vật & Boss
# ============================
var monsters = [
    {"name": "Slime", "hp": 20, "atk": 5, "exp": 10, "gold": 5},
    {"name": "Goblin", "hp": 35, "atk": 8, "exp": 20, "gold": 10},
    {"name": "Orc", "hp": 50, "atk": 12, "exp": 35, "gold": 20},
    {"name": "Boss Rồng", "hp": 200, "atk": 25, "exp": 200, "gold": 100}
]

# ============================
# Trang bị (OM < SOS < SOM < SUM)
# ============================
var equipment_pool = [
    {"name": "OM Sword", "slot": "weapon_main"},
    {"name": "SOS Armor", "slot": "armor_chest"},
    {"name": "SOM Ring", "slot": "ring"},
    {"name": "SUM Necklace", "slot": "necklace"}
]

# ============================
# Game start
# ============================
func _ready():
    load_game()
    $StartButton.connect("pressed", self, "_on_start_pressed")

func _on_start_pressed():
    fight_monster()
    save_game()  # Lưu sau mỗi trận

# ============================
# Combat cơ bản
# ============================
func fight_monster():
    var monster = monsters[randi() % monsters.size()]
    print("⚔️ Đụng độ: %s (HP %d)" % [monster["name"], monster["hp"]])
    var monster_hp = monster["hp"]
    var player_hp = player["hp"]

    while monster_hp > 0 and player_hp > 0:
        # Player attack
        monster_hp -= 15
        print("👊 Player đánh, quái còn %d HP" % monster_hp)
        if monster_hp <= 0:
            print("🎉 %s đã bị hạ!" % monster["name"])
            gain_reward(monster)
            break

        # Monster attack
        player_hp -= monster["atk"]
        print("💥 %s đánh, Player còn %d HP" % [monster["name"], player_hp])

    print("📊 Trận kết thúc, EXP: %d, Vàng: %d" % [player["exp"], player["gold"]])

# ============================
# Nhận thưởng sau khi hạ quái
# ============================
func gain_reward(monster):
    player["exp"] += monster["exp"]
    player["gold"] += monster["gold"]

    # Tỉ lệ rơi trang bị
    var roll = randi() % 100
    var eq = null
    if roll < 40:
        eq = equipment_pool[0]
    elif roll < 65:
        eq = equipment_pool[1]
    elif roll < 85:
        eq = equipment_pool[2]
    elif roll < 95:
        eq = equipment_pool[3]

    if eq != null:
        player["inventory"].append(eq)
        print("🪄 Nhặt được trang bị: %s" % eq["name"])

# ============================
# SAVE / LOAD
# ============================
func save_game():
    var file = File.new()
    if file.open(save_path, File.WRITE) == OK:
        file.store_string(to_json(player))
        file.close()
        print("💾 Game đã được lưu.")

func load_game():
    var file = File.new()
    if file.file_exists(save_path):
        if file.open(save_path, File.READ) == OK:
            var data = parse_json(file.get_as_text())
            if typeof(data) == TYPE_DICTIONARY:
                player = data
                print("🔄 Game đã load: LV %d, EXP %d, GOLD %d" %
                      [player["level"], player["exp"], player["gold"]])
            file.close()

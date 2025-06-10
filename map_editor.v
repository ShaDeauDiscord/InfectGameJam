import gg
import os
import Linklancien.playint

const bg_color = gg.Color{135, 206, 235, 255}
const plants = [
	Plant{.root, true, false, true, false, 150000, -1, 300000, -1, Seed{.root, 300000, -1}},
]!
const tile_cant_walk_on = [Tiles.inf_elder_tree, Tiles.elder_tree]

enum Plant_type {
	none = -1
	root
}

enum Tiles {
	inf_elder_tree = -4
	inf_robinet
	inf_pot
	inf_grass
	none        = 0
	grass       = 1
	pot
	robinet
	elder_tree
}

struct App {
mut:
	ctx &gg.Context = unsafe { nil }

	// DATA
	map        [][]Tiles
	plant_map  [][]Plant
	seed_map   [][]Seed
	blessed_huge_tree Elder_tree
	infected_huge_tree Elder_tree
	cure_infected_huge_tree_condition [][]int
	player     Gardener


	last_frame int

	window_width int
	window_height int
	tile_size int

	init bool = true
	main_menu bool = true


	// IMAGES
	grass          gg.Image
	gardener_right       gg.Image
	gardener_down       gg.Image
	gardener_left      gg.Image
	gardener_up       gg.Image
	infected_grass gg.Image
	infected_root  gg.Image
	watering_can   gg.Image
	pelle          gg.Image
	robinet        gg.Image
	pot            gg.Image
	infected_pot   gg.Image
	root           gg.Image
	root_seed      gg.Image
	blessed_root   gg.Image
	huge_tree gg.Image
	infect_huge_tree gg.Image
}

struct Plant {
mut:
	id                 Plant_type = .none
	infected           bool
	blessed            bool
	collision          bool
	potted             bool
	pot_cure_cooldown  f32
	time_of_potting    f32
	make_seed_cooldown f32
	time_of_last_seed  f32
	child              Seed
}

struct Seed {
mut:
	parent           Plant_type = .none
	grow_time        f32
	time_of_planting f32
}

struct Elder_tree {
mut:
	x int
	y int
	infected bool
	radius_squared int
	radius_squared_of_effect int
}

struct Gardener {
	water_capacity f32 = 10
mut:
	x            int
	y            int
	orientation  u8
	plant_item   Plant
	seed_item    Seed
	tool         u8
	water_in_can f32 = 10
}

import gg
import time
import rand
import os

const bg_color = gg.Color{135, 206, 235, 255}
const time_for_one_frame = int(1.0 / 60.0 * 1000)
const plants = [
	Plant{.root, true, false, true, false, 30000, -1, 60000, -1, Seed{.root, 60000, -1}},
]!
const tile_cant_walk_on = [Tiles.inf_elder_tree, Tiles.elder_tree, Tiles.none]

enum Plant_type {
	none = -1
	root
}

enum Tiles {
	inf_elder_tree = -15
	inf_robinet
	inf_pot
	inf_grass12
	inf_grass11
	inf_grass10
	inf_grass9
	inf_grass8
	inf_grass7
	inf_grass6
	inf_grass5
	inf_grass4
	inf_grass3
	inf_grass2
	inf_grass1
	none        = 0
	grass1      = 1
	grass2
	grass3
	grass4
	grass5
	grass6
	grass7
	grass8
	grass9
	grass10
	grass11
	grass12
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
	grass1          gg.Image
	grass2          gg.Image
	grass3          gg.Image
	grass4          gg.Image
	grass5          gg.Image
	grass6          gg.Image
	grass7          gg.Image
	grass8          gg.Image
	grass9          gg.Image
	grass10          gg.Image
	grass11          gg.Image
	grass12          gg.Image

	infected_grass1 gg.Image
	infected_grass2 gg.Image
	infected_grass3 gg.Image
	infected_grass4 gg.Image
	infected_grass5 gg.Image
	infected_grass6 gg.Image
	infected_grass7 gg.Image
	infected_grass8 gg.Image
	infected_grass9 gg.Image
	infected_grass10 gg.Image
	infected_grass11 gg.Image
	infected_grass12 gg.Image

	gardener_right       gg.Image
	gardener_down       gg.Image
	gardener_left      gg.Image
	gardener_up       gg.Image

	gardener_right_shovel       gg.Image
	gardener_down_shovel       gg.Image
	gardener_left_shovel      gg.Image
	gardener_up_shovel       gg.Image

	gardener_right_can       gg.Image
	gardener_down_can       gg.Image
	gardener_left_can      gg.Image
	gardener_up_can       gg.Image

	gardener_right_plant       gg.Image
	gardener_down_plant       gg.Image
	gardener_left_plant      gg.Image
	gardener_up_plant       gg.Image

	gardener_right_seed       gg.Image
	gardener_down_seed       gg.Image
	gardener_left_seed      gg.Image
	gardener_up_seed       gg.Image

	infected_root  gg.Image
	root           gg.Image
	root_seed      gg.Image
	blessed_root   gg.Image

	watering_can   gg.Image
	pelle          gg.Image
	robinet        gg.Image

	pot            gg.Image
	infected_pot   gg.Image

	huge_tree gg.Image
	infect_huge_tree gg.Image

	main_hub gg.Image
	hub_pot gg.Image

	lake gg.Image
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
	water_capacity f32 = 25
mut:
	x            int
	y            int
	orientation  u8
	plant_item   Plant
	seed_item    Seed
	tool         u8
	water_in_can f32 = 25
}

fn main() {
	mut app := &App{
		blessed_huge_tree: Elder_tree{9, 9, false, 9, 100}
		infected_huge_tree: Elder_tree{90, 90, true, 9, 100}
		cure_infected_huge_tree_condition: [[87, 87], [93, 87], [93, 93], [87, 93]]
	}

	app.ctx = gg.new_context(
		create_window: true
		fullscreen:    true
		window_title:  '- Infect_Game_Jam -'
		user_data:     app
		bg_color:      bg_color
		frame_fn:      on_frame
		event_fn:      on_event
		sample_count:  2
	)

	// LOAD IMAGES
	app.grass1 = app.ctx.create_image('grass1.png') or { panic(err) }
	app.grass2 = app.ctx.create_image('grass2.png') or { panic(err) }
	app.grass3 = app.ctx.create_image('grass3.png') or { panic(err) }
	app.grass4 = app.ctx.create_image('grass4.png') or { panic(err) }
	app.grass5 = app.ctx.create_image('grass5.png') or { panic(err) }
	app.grass6 = app.ctx.create_image('grass6.png') or { panic(err) }
	app.grass7 = app.ctx.create_image('grass7.png') or { panic(err) }
	app.grass8 = app.ctx.create_image('grass8.png') or { panic(err) }
	app.grass9 = app.ctx.create_image('grass9.png') or { panic(err) }
	app.grass10 = app.ctx.create_image('grass10.png') or { panic(err) }
	app.grass11 = app.ctx.create_image('grass11.png') or { panic(err) }
	app.grass12 = app.ctx.create_image('grass12.png') or { panic(err) }

	app.infected_grass1 = app.ctx.create_image('infected_grass1.png') or { panic(err) }
	app.infected_grass2 = app.ctx.create_image('infected_grass2.png') or { panic(err) }
	app.infected_grass3 = app.ctx.create_image('infected_grass3.png') or { panic(err) }
	app.infected_grass4 = app.ctx.create_image('infected_grass4.png') or { panic(err) }
	app.infected_grass5 = app.ctx.create_image('infected_grass5.png') or { panic(err) }
	app.infected_grass6 = app.ctx.create_image('infected_grass6.png') or { panic(err) }
	app.infected_grass7 = app.ctx.create_image('infected_grass7.png') or { panic(err) }
	app.infected_grass8 = app.ctx.create_image('infected_grass8.png') or { panic(err) }
	app.infected_grass9 = app.ctx.create_image('infected_grass9.png') or { panic(err) }
	app.infected_grass10 = app.ctx.create_image('infected_grass10.png') or { panic(err) }
	app.infected_grass11 = app.ctx.create_image('infected_grass11.png') or { panic(err) }
	app.infected_grass12 = app.ctx.create_image('infected_grass12.png') or { panic(err) }

	app.gardener_right = app.ctx.create_image('gardener_right.png') or { panic(err) }
	app.gardener_down = app.ctx.create_image('gardener_down.png') or { panic(err) }
	app.gardener_left = app.ctx.create_image('gardener_left.png') or { panic(err) }
	app.gardener_up = app.ctx.create_image('gardener_up.png') or { panic(err) }

	app.gardener_right_shovel = app.ctx.create_image('gardener_right_shovel.png') or { panic(err) }
	app.gardener_down_shovel = app.ctx.create_image('gardener_down_shovel.png') or { panic(err) }
	app.gardener_left_shovel = app.ctx.create_image('gardener_left_shovel.png') or { panic(err) }
	app.gardener_up_shovel = app.ctx.create_image('gardener_up_shovel.png') or { panic(err) }

	app.gardener_right_can = app.ctx.create_image('gardener_right_can.png') or { panic(err) }
	app.gardener_down_can = app.ctx.create_image('gardener_down_can.png') or { panic(err) }
	app.gardener_left_can = app.ctx.create_image('gardener_left_can.png') or { panic(err) }
	app.gardener_up_can = app.ctx.create_image('gardener_up_can.png') or { panic(err) }

	app.gardener_right_plant = app.ctx.create_image('gardener_right_plant.png') or { panic(err) }
	app.gardener_down_plant = app.ctx.create_image('gardener_down_plant.png') or { panic(err) }
	app.gardener_left_plant = app.ctx.create_image('gardener_left_plant.png') or { panic(err) }
	app.gardener_up_plant = app.ctx.create_image('gardener_up_plant.png') or { panic(err) }

	/*app.gardener_right = app.ctx.create_image('gardener_right_seed.png') or { panic(err) }
	app.gardener_down = app.ctx.create_image('gardener_down_seed.png') or { panic(err) }
	app.gardener_left = app.ctx.create_image('gardener_left_seed.png') or { panic(err) }
	app.gardener_up = app.ctx.create_image('gardener_up_seed.png') or { panic(err) }*/

	app.infected_root = app.ctx.create_image('infected_root.png') or { panic(err) }
	app.root = app.ctx.create_image('root.png') or { panic(err) }
	app.blessed_root = app.ctx.create_image('blessed_root.png') or { panic(err) }
	app.root_seed = app.ctx.create_image('root_seed.png') or { panic(err) }

	app.robinet = app.ctx.create_image('robinet.png') or { panic(err) }
	app.watering_can = app.ctx.create_image('watering_can.png') or { panic(err) }
	app.pelle = app.ctx.create_image('pelle.png') or { panic(err) }

	app.pot = app.ctx.create_image('pot.png') or { panic(err) }
	app.infected_pot = app.ctx.create_image('infected_pot.png') or { panic(err) }

	app.huge_tree = app.ctx.create_image('huge_tree.png') or { panic(err) }
	app.infect_huge_tree = app.ctx.create_image('infected_huge_tree.png') or { panic(err) }

	app.main_hub = app.ctx.create_image('main_hub.png') or { panic(err) }
	app.hub_pot = app.ctx.create_image('hub_pot.png') or { panic(err) }

	app.lake = app.ctx.create_image('lake.png') or { panic(err) }


	// lancement du programme/de la fenêtre
	app.ctx.run()
}

fn on_frame(mut app App) {
	println(app.player.x)
	println(app.player.y)
	if app.init {
		app.window_width = gg.window_size().width
		app.window_height = gg.window_size().height
		if app.window_height > app.window_width {
			app.tile_size = app.window_width / 20
		} else {
			app.tile_size = app.window_height / 20
		}
		//app.init = false
	}
	if !app.main_menu {
		frame_time := time_to_mili(time.now())
		for i in 0 .. app.plant_map.len {
			for j in 0 .. app.plant_map[0].len {
				if app.plant_map[i][j].id != .none {
					if app.plant_map[i][j].potted {
						if app.plant_map[i][j].infected
							&& frame_time - app.plant_map[i][j].time_of_potting >= app.plant_map[i][j].pot_cure_cooldown {
							app.plant_map[i][j].infected = false
							app.plant_map[i][j].time_of_potting = -1
							app.plant_map[i][j].time_of_last_seed = time_to_mili(time.now())
						}
					}
					if app.plant_map[i][j].potted && !app.plant_map[i][j].infected {
						if app.plant_map[i][j].time_of_last_seed != -1 {
							if frame_time - app.plant_map[i][j].time_of_last_seed >= app.plant_map[i][j].make_seed_cooldown {
								app.plant_map[i][j].time_of_last_seed = -1
							}
						}
					}
					if int(app.map[i][j]) < 0 && app.map[i][j] != Tiles.inf_pot{
						if rand.int_in_range(0, 1000) or { 0 } == 0 {
							app.plant_map[i][j].infected = true
							app.plant_map[i][j].blessed = false
						}
					}
				}
				if app.seed_map[i][j].parent != .none {
					if app.seed_map[i][j].time_of_planting != -1 {
						if frame_time - app.seed_map[i][j].time_of_planting >= app.seed_map[i][j].grow_time {
							app.plant_map[i][j] = plants[int(Plant_type.root)]
							app.plant_map[i][j].infected = false
							app.plant_map[i][j].blessed = true
							app.seed_map[i][j] = Seed{}
						}
						if int(app.map[i][j]) < 0 {
							if rand.int_in_range(0, 1000) or { 0 } == 0 {
								app.seed_map[i][j].parent = .none
							}
						}
					}
				}
			}
		}

		if frame_time - app.last_frame > int(time_for_one_frame) {
			app.global_bless_and_infect()
		}
		
		if frame_time - app.last_frame > time_for_one_frame {
			app.check_win_condition()
		}

		app.last_frame = frame_time
	}

	// Draw
	app.ctx.begin()
	app.affiche()
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	if app.main_menu {
		match e.typ {
			.key_down {
				match e.key_code {
					.escape {
						app.ctx.quit()
					}
					else {}
				}
			}
			.mouse_up {
				if app.ctx.mouse_pos_x >= app.tile_size * 9 && app.ctx.mouse_pos_x <= app.tile_size * 11 {
					if app.ctx.mouse_pos_y >= app.tile_size * 8 && app.ctx.mouse_pos_y <= app.tile_size * 9 {
						app.init_map()
						app.main_menu = false
					} else if app.ctx.mouse_pos_y >= app.tile_size * 9 + app.tile_size / 2 && app.ctx.mouse_pos_y <= app.tile_size * 10 + app.tile_size / 2 {
						if os.exists('saved_map') {
							os.rm('saved_map') or {exit}
						}
						app.init_map()
						app.main_menu = false
					}
				}
			}
			else {}
		}
	} else {
		match e.typ {
			.key_down {
				match e.key_code {
					.escape {
						app.save() or {}
						app.ctx.quit()
					}
					.up {
						if app.player.y - 1 >= 0
							&& !app.plant_map[app.player.y - 1][app.player.x].collision && app.player.orientation == 3 && !(app.map[app.player.y - 1][app.player.x] in tile_cant_walk_on) {
							app.player.y -= 1

						}
						app.player.orientation = 3
					}
					.down {
						if app.player.y + 1 < app.map.len
							&& !app.plant_map[app.player.y + 1][app.player.x].collision && app.player.orientation == 1 && !(app.map[app.player.y + 1][app.player.x] in tile_cant_walk_on) {
							app.player.y += 1
						}
						app.player.orientation = 1
					}
					.left {
						if app.player.x - 1 >= 0
							&& !app.plant_map[app.player.y][app.player.x - 1].collision && app.player.orientation == 2 && !(app.map[app.player.y][app.player.x - 1] in tile_cant_walk_on) {
							app.player.x -= 1
						}
						app.player.orientation = 2
					}
					.right {
						if app.player.x + 1 < app.map[0].len
							&& !app.plant_map[app.player.y][app.player.x + 1].collision && app.player.orientation == 0 && !(app.map[app.player.y][app.player.x + 1] in tile_cant_walk_on) {
							app.player.x += 1
						}
						app.player.orientation = 0
					}
					.q {
						if app.player.plant_item.id == .none && app.player.seed_item.parent == .none {
							if app.player.tool == 1 {
								app.player.tool = 0
							} else {
								app.player.tool = 1
							}
						}
					}
					.a {
						if app.player.plant_item.id == .none && app.player.seed_item.parent == .none {
							if app.player.tool == 2 {
								app.player.tool = 0
							} else {
								app.player.tool = 2
							}
						}
					}
					.space {
						match app.player.tool {
							0 {
								if app.player.seed_item.parent != .none {
									app.player.plant_seed(mut app)
								} else {
									app.player.pickup_seed(mut app)
								}
							}
							1 {
								if app.map[app.player.y][app.player.x] == .robinet {
									app.player.water_in_can = app.player.water_capacity
								} else {
									app.player.arroser(mut app)
								}
							}
							2 {
								app.player.pickup_plant(mut app)
							}
							else {}
						}
					}
					else {}
				}
			}
			else {}
		}
	}
}

fn (app App) affiche() {
	if app.main_menu {
		app.ctx.draw_rect_filled(app.tile_size * 9,
			app.tile_size * 8,
			2 * app.tile_size,
			app.tile_size, 
			gg.Color{150, 255, 150, 255})
		app.ctx.draw_text_def(app.tile_size * 9 + app.tile_size / 4,
			app.tile_size * 8 + app.tile_size / 8,
			"Continue")
		app.ctx.draw_rect_filled(app.tile_size * 9,
			app.tile_size * 9 + app.tile_size / 2,
			2 * app.tile_size,
			app.tile_size, 
			gg.Color{150, 255, 150, 255})
		app.ctx.draw_text_def(app.tile_size * 9 + app.tile_size / 4,
			app.tile_size * 9 + app.tile_size / 2 + app.tile_size / 8,
			"New game")
	} else {
		dep_i := (app.player.y / 20) * 20
		fin_i := (app.player.y / 20 + 1) * 20
		dep_j := (app.player.x / 20) * 20
		fin_j := (app.player.x / 20 + 1) * 20
		for i in dep_i .. fin_i {
			for j in dep_j .. fin_j {
				match app.map[i][j] {
					.grass1 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass1) }
					.grass2 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass2) }
					.grass3 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass3) }
					.grass4 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass4) }
					.grass5 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass5) }
					.grass6 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass6) }
					.grass7 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass7) }
					.grass8 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass8) }
					.grass9 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass9) }
					.grass10 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass10) }
					.grass11 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass11) }
					.grass12 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.grass12) }

					.inf_grass1 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass1) }
					.inf_grass2 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass2) }
					.inf_grass3 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass3) }
					.inf_grass4 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass4) }
					.inf_grass5 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass5) }
					.inf_grass6 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass6) }
					.inf_grass7 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass7) }
					.inf_grass8 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass8) }
					.inf_grass9 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass9) }
					.inf_grass10 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass10) }
					.inf_grass11 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass11) }
					.inf_grass12 { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infected_grass12) }

					.robinet { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.robinet) }

					.pot { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i, app.tile_size,
							app.tile_size, app.pot) }
					.inf_pot { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i, app.tile_size,
							app.tile_size, app.infected_pot) }

					.inf_elder_tree { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.infect_huge_tree) }
					.elder_tree { app.ctx.draw_image(app.tile_size * j - app.tile_size * dep_j, app.tile_size * i - app.tile_size * dep_i,
							app.tile_size, app.tile_size, app.huge_tree) }
					else {}
				}
			}
		}
		if dep_i == 0 && dep_j == 0 {
			app.ctx.draw_image(app.tile_size/3, 0, 19 * app.tile_size, 19 * app.tile_size, app.main_hub)
			app.ctx.draw_image(5 * app.tile_size, 12 * app.tile_size, app.tile_size, app.tile_size, app.hub_pot)
			app.ctx.draw_image(8 * app.tile_size, 14 * app.tile_size, app.tile_size, app.tile_size, app.hub_pot)
			app.ctx.draw_image(11 * app.tile_size, 14 * app.tile_size, app.tile_size, app.tile_size, app.hub_pot)
			app.ctx.draw_image(14 * app.tile_size, 12 * app.tile_size, app.tile_size, app.tile_size, app.hub_pot)
			app.ctx.draw_image(13 * app.tile_size + app.tile_size / 2, 9 * app.tile_size, 3 * app.tile_size, app.tile_size * 3, app.lake)
		}
		for i in dep_i .. fin_i {
			for j in dep_j .. fin_j {
				match app.plant_map[i][j].id {
					.root {
						mut pot := 0
						if app.map[i][j] == .pot || app.map[i][j] == .inf_pot {
							pot = app.tile_size / 4
						}
						if app.plant_map[i][j].infected {
							app.ctx.draw_image(app.tile_size * j + pot - app.tile_size * dep_j, app.tile_size * i + pot - app.tile_size * dep_i,
								app.tile_size - 2 * pot, app.tile_size - 2 * pot, app.infected_root)
						} else if app.plant_map[i][j].blessed {
							app.ctx.draw_image(app.tile_size * j + pot - app.tile_size * dep_j, app.tile_size * i + pot - app.tile_size * dep_i,
								app.tile_size - 2 * pot, app.tile_size - 2 * pot, app.blessed_root)
						} else {
							app.ctx.draw_image(app.tile_size * j + pot - app.tile_size * dep_j, app.tile_size * i + pot - app.tile_size * dep_i,
								app.tile_size - 2 * pot, app.tile_size - 2 * pot, app.root)
						}
						if app.plant_map[i][j].potted && !app.plant_map[i][j].infected
							&& app.plant_map[i][j].time_of_last_seed == -1 {
							app.ctx.draw_image(app.tile_size * j + app.tile_size / 2 - app.tile_size * dep_j, app.tile_size * i + app.tile_size / 16 - app.tile_size * dep_i,
								app.tile_size / 2, app.tile_size / 2, app.root_seed)
						}
					}
					else {}
				}
				match app.seed_map[i][j].parent {
					.root {
						if app.plant_map[i][j].id != .none {
							app.ctx.draw_image(app.tile_size * j + app.tile_size / 2 - app.tile_size * dep_j, app.tile_size * i + app.tile_size / 16 - app.tile_size * dep_i,
								app.tile_size / 2, app.tile_size / 2, app.root_seed)
						} else {
							app.ctx.draw_image(app.tile_size * j + app.tile_size / 4 - app.tile_size * dep_j, app.tile_size * i + app.tile_size / 4 - app.tile_size * dep_i,
								app.tile_size / 2, app.tile_size / 2, app.root_seed)
						}
					}
					else {}
				}
			}
		}




		mut item := false

		match app.player.tool {
			1 {
				match app.player.orientation {
					0 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_right_can)}
					1 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_down_can)}
					2 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_left_can)}
					3 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_up_can)}
					else {}
				}
				app.ctx.draw_image(app.window_width - app.tile_size * 3, app.tile_size,
					app.tile_size * 2, app.tile_size * 2, app.watering_can)
				app.ctx.draw_rect_filled(app.window_width - app.tile_size * 3, app.tile_size + (25 - app.player.water_in_can) * app.tile_size * 2 / 25,
					app.tile_size * 2, app.tile_size * 2 - (25 - app.player.water_in_can) * app.tile_size * 2 / 25, gg.Color{50, 100, 200, 100})
				item = true

			}
			2 {
				match app.player.orientation {
					0 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_right_shovel)}
					1 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_down_shovel)}
					2 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_left_shovel)}
					3 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_up_shovel)}
					else {}
				}
				app.ctx.draw_image(app.window_width - app.tile_size * 3, app.tile_size,
					app.tile_size * 2, app.tile_size * 2, app.pelle)
				item = true
			}
			else {}
		}
		match app.player.plant_item.id {
			.root {
				if app.player.plant_item.infected {
					app.ctx.draw_image(app.window_width - app.tile_size * 3, app.tile_size,
						app.tile_size * 2, app.tile_size * 2, app.infected_root)
				} else if app.player.plant_item.blessed {
					app.ctx.draw_image(app.window_width - app.tile_size * 3, app.tile_size,
						app.tile_size * 2, app.tile_size * 2, app.blessed_root)
				} else {
					app.ctx.draw_image(app.window_width - app.tile_size * 3, app.tile_size,
						app.tile_size * 2, app.tile_size * 2, app.root)
				}
				match app.player.orientation {
					0 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_right_plant)}
					1 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_down_plant)}
					2 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_left_plant)}
					3 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_up_plant)}
					else {}
				}
				item = true
			}
			else {}
		}
		match app.player.seed_item.parent {
			.root {
				app.ctx.draw_image(app.window_width - app.tile_size * 3, app.tile_size,
					app.tile_size * 2, app.tile_size * 2, app.root_seed)
				match app.player.orientation {
					0 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_right_seed)}
					1 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_down_seed)}
					2 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_left_seed)}
					3 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
						app.tile_size, app.tile_size + app.tile_size/2, app.gardener_up_seed)}
					else {}
				}
				item = true
			}
			else {}
		}
		if !item {
			match app.player.orientation {
				0 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
					app.tile_size, app.tile_size + app.tile_size/2, app.gardener_right)}
				1 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
					app.tile_size, app.tile_size + app.tile_size/2, app.gardener_down)}
				2 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
					app.tile_size, app.tile_size + app.tile_size/2, app.gardener_left)}
				3 {app.ctx.draw_image(app.tile_size * app.player.x - app.tile_size * dep_j, app.tile_size * app.player.y - app.tile_size/2 - app.tile_size * dep_i ,
					app.tile_size, app.tile_size + app.tile_size/2, app.gardener_up)}
				else {}
			}
		}
	}
}

fn (mut g Gardener) arroser(mut app App) {
	if g.water_in_can > 0 {
		mut t1 := [0, 0]
		mut t2 := [0, 0]
		mut t3 := [0, 0]
		mut t4 := [0, 0]
		mut t5 := [0, 0]
		match g.orientation {
			0 {
				t1 = [g.x + 1, g.y - 1]
				t2 = [g.x, g.y]
				t3 = [g.x + 1, g.y]
				t4 = [g.x + 2, g.y]
				t5 = [g.x + 1, g.y + 1]
			}
			1 {
				t1 = [g.x, g.y]
				t2 = [g.x - 1, g.y + 1]
				t3 = [g.x, g.y + 1]
				t4 = [g.x + 1, g.y + 1]
				t5 = [g.x, g.y + 2]
			}
			2 {
				t1 = [g.x - 1, g.y - 1]
				t2 = [g.x, g.y]
				t3 = [g.x - 1, g.y]
				t4 = [g.x - 2, g.y]
				t5 = [g.x - 1, g.y + 1]
			}
			3 {
				t1 = [g.x, g.y]
				t2 = [g.x - 1, g.y - 1]
				t3 = [g.x, g.y - 1]
				t4 = [g.x + 1, g.y - 1]
				t5 = [g.x, g.y - 2]
			}
			else {}
		}
		if t1[0] >= 0 && t1[1] >= 0 && t1[0] < app.map[0].len && t1[1] < app.map.len
			&& app.plant_map[t1[1]][t1[0]].id != .root && int(app.map[t1[1]][t1[0]]) <= 0 {
			app.map[t1[1]][t1[0]] = unsafe { Tiles(-int(app.map[t1[1]][t1[0]])) }
		}
		if t2[0] >= 0 && t3[1] >= 0 && t2[0] < app.map[0].len && t2[1] < app.map.len
			&& app.plant_map[t2[1]][t2[0]].id != .root && int(app.map[t2[1]][t2[0]]) <= 0 {
			app.map[t2[1]][t2[0]] = unsafe { Tiles(-int(app.map[t2[1]][t2[0]])) }
		}
		if t3[0] >= 0 && t3[1] >= 0 && t3[0] < app.map[0].len && t3[1] < app.map.len
			&& app.plant_map[t3[1]][t3[0]].id != .root && int(app.map[t3[1]][t3[0]]) <= 0 {
			app.map[t3[1]][t3[0]] = unsafe { Tiles(-int(app.map[t3[1]][t3[0]])) }
		}
		if t4[0] >= 0 && t4[1] >= 0 && t4[0] < app.map[0].len && t4[1] < app.map.len
			&& app.plant_map[t4[1]][t4[0]].id != .root && int(app.map[t4[1]][t4[0]]) <= 0 {
			app.map[t4[1]][t4[0]] = unsafe { Tiles(-int(app.map[t4[1]][t4[0]])) }
		}
		if t5[0] >= 0 && t5[1] >= 0 && t5[0] < app.map[0].len && t5[1] < app.map.len
			&& app.plant_map[t5[1]][t5[0]].id != .root && int(app.map[t5[1]][t5[0]]) <= 0 {
			app.map[t5[1]][t5[0]] = unsafe { Tiles(-int(app.map[t5[1]][t5[0]])) }
		}
		g.water_in_can -= 1
	}
}

fn (mut g Gardener) pickup_plant(mut app App) {
	mut t := [0, 0]
	match g.orientation {
		0 {
			t = [g.x + 1, g.y]
		}
		1 {
			t = [g.x, g.y + 1]
		}
		2 {
			t = [g.x - 1, g.y]
		}
		3 {
			t = [g.x, g.y - 1]
		}
		else {}
	}
	if t[0] >= 0 && t[1] >= 0 && t[0] < app.map[0].len && t[1] < app.map.len {
		if g.plant_item.id == .none && app.plant_map[t[1]][t[0]].id != .none {
			g.plant_item = app.plant_map[t[1]][t[0]]
			app.plant_map[t[1]][t[0]].potted = false
			g.plant_item.time_of_potting = -1
			app.plant_map[t[1]][t[0]].id = .none
			app.plant_map[t[1]][t[0]].collision = false
		} else if g.plant_item.id != .none && app.plant_map[t[1]][t[0]].id == .none {
			app.plant_map[t[1]][t[0]] = g.plant_item
			app.plant_map[t[1]][t[0]].potted = false
			app.plant_map[t[1]][t[0]].time_of_potting = -1
			app.plant_map[t[1]][t[0]].time_of_last_seed = time_to_mili(time.now())
			if app.map[t[1]][t[0]] == .pot {
				app.plant_map[t[1]][t[0]].potted = true
				if g.plant_item.infected == true {
					app.plant_map[t[1]][t[0]].time_of_potting = time_to_mili(time.now())
				}
			}
			g.plant_item.id = .none
		}
	}
}

fn (mut g Gardener) pickup_seed(mut app App) {
	mut t := [0, 0]
	match g.orientation {
		0 {
			t = [g.x + 1, g.y]
		}
		1 {
			t = [g.x, g.y + 1]
		}
		2 {
			t = [g.x - 1, g.y]
		}
		3 {
			t = [g.x, g.y - 1]
		}
		else {}
	}
	if t[0] >= 0 && t[1] >= 0 && t[0] < app.map[0].len && t[1] < app.map.len {
		if g.plant_item.id == .none && app.plant_map[t[1]][t[0]].id != .none {
			if app.seed_map[t[1]][t[0]].parent != .none {
				g.seed_item = app.seed_map[t[1]][t[0]]
				app.seed_map[t[1]][t[0]].parent = .none
			}
			if app.plant_map[t[1]][t[0]].potted && !app.plant_map[t[1]][t[0]].infected
				&& app.plant_map[t[1]][t[0]].time_of_last_seed == -1 {
				g.seed_item = app.plant_map[t[1]][t[0]].child
				app.plant_map[t[1]][t[0]].time_of_last_seed = time_to_mili(time.now())
			}
		}
	}
}

fn (mut g Gardener) plant_seed(mut app App) {
	mut t := [0, 0]
	match g.orientation {
		0 {
			t = [g.x + 1, g.y]
		}
		1 {
			t = [g.x, g.y + 1]
		}
		2 {
			t = [g.x - 1, g.y]
		}
		3 {
			t = [g.x, g.y - 1]
		}
		else {}
	}
	if t[0] >= 0 && t[1] >= 0 && t[0] < app.map[0].len && t[1] < app.map.len {
		if g.seed_item.parent != .none && app.plant_map[t[1]][t[0]].id == .none
			&& app.seed_map[t[1]][t[0]].parent == .none {
			app.seed_map[t[1]][t[0]] = g.seed_item
			g.seed_item.parent = .none
			app.seed_map[t[1]][t[0]].time_of_planting = time_to_mili(time.now())
		}
	}
}

fn (mut app App) tile_infect(x int, y int) {
	if !((x <= 0 || int(app.map[y][x - 1]) < 0)
		&& (x >= app.map[0].len - 1 || int(app.map[y][x + 1]) < 0)
		&& (y <= 0 || int(app.map[y - 1][x]) < 0)
		&& (y <= app.map.len - 1 || int(app.map[y + 1][x]) < 0)) {
		match rand.int_in_range(1, 5_001) or { 0 } {
			1...8 {
				match rand.int_in_range(1, 4) or { 0 } {
					1 {
						if y > 0 && int(app.map[y - 1][x]) > 0 {
							app.map[y - 1][x] = unsafe { Tiles(-int(app.map[y - 1][x])) }
						}
					}
					2 {
						if y < app.map.len - 1 && int(app.map[y + 1][x]) > 0 {
							app.map[y + 1][x] = unsafe { Tiles(-int(app.map[y + 1][x])) }
						}
					}
					3 {
						if x > 0 && int(app.map[y][x - 1]) > 0 {
							app.map[y][x - 1] = unsafe { Tiles(-int(app.map[y][x - 1])) }
						}
					}
					4 {
						if x < app.map[0].len - 1 && int(app.map[y][x + 1]) > 0 {
							app.map[y][x + 1] = unsafe { Tiles(-int(app.map[y][x + 1])) }
						}
					}
					else {}
				}
			}
			9...12 {
				match rand.int_in_range(1, 6) or { 0 } {
					1 {
						if y > 0 && int(app.map[y - 1][x]) > 0 {
							app.map[y - 1][x] = unsafe { Tiles(-int(app.map[y - 1][x])) }
						}
						if y < app.map.len - 1 && int(app.map[y + 1][x]) > 0 {
							app.map[y + 1][x] = unsafe { Tiles(-int(app.map[y + 1][x])) }
						}
					}
					2 {
						if y > 0 && int(app.map[y - 1][x]) > 0 {
							app.map[y - 1][x] = unsafe { Tiles(-int(app.map[y - 1][x])) }
						}
						if x > 0 && int(app.map[y][x - 1]) > 0 {
							app.map[y][x - 1] = unsafe { Tiles(-int(app.map[y][x - 1])) }
						}
					}
					3 {
						if y > 0 && int(app.map[y - 1][x]) > 0 {
							app.map[y - 1][x] = unsafe { Tiles(-int(app.map[y - 1][x])) }
						}
						if x < app.map[0].len - 1 && int(app.map[y][x + 1]) > 0 {
							app.map[y][x + 1] = unsafe { Tiles(-int(app.map[y][x + 1])) }
						}
					}
					4 {
						if y < app.map.len - 1 && int(app.map[y + 1][x]) > 0 {
							app.map[y + 1][x] = unsafe { Tiles(-int(app.map[y + 1][x])) }
						}
						if x > 0 && int(app.map[y][x - 1]) > 0 {
							app.map[y][x - 1] = unsafe { Tiles(-int(app.map[y][x - 1])) }
						}
					}
					5 {
						if y < app.map.len - 1 && int(app.map[y + 1][x]) > 0 {
							app.map[y + 1][x] = unsafe { Tiles(-int(app.map[y + 1][x])) }
						}
						if x < app.map[0].len - 1 && int(app.map[y][x + 1]) > 0 {
							app.map[y][x + 1] = unsafe { Tiles(-int(app.map[y][x + 1])) }
						}
					}
					6 {
						if x > 0 && int(app.map[y][x - 1]) > 0 {
							app.map[y][x - 1] = unsafe { Tiles(-int(app.map[y][x - 1])) }
						}
						if x < app.map[0].len - 1 && int(app.map[y][x + 1]) > 0 {
							app.map[y][x + 1] = unsafe { Tiles(-int(app.map[y][x + 1])) }
						}
					}
					else {}
				}
			}
			13...14 {
				match rand.int_in_range(1, 4) or { 0 } {
					1 {
						if y > 0 && int(app.map[y - 1][x]) > 0 {
							app.map[y - 1][x] = unsafe { Tiles(-int(app.map[y - 1][x])) }
						}
						if y < app.map.len - 1 && int(app.map[y + 1][x]) > 0 {
							app.map[y + 1][x] = unsafe { Tiles(-int(app.map[y + 1][x])) }
						}
						if x > 0 && int(app.map[y][x - 1]) > 0 {
							app.map[y][x - 1] = unsafe { Tiles(-int(app.map[y][x - 1])) }
						}
					}
					2 {
						if y > 0 && int(app.map[y - 1][x]) > 0 {
							app.map[y - 1][x] = unsafe { Tiles(-int(app.map[y - 1][x])) }
						}
						if y < app.map.len - 1 && int(app.map[y + 1][x]) > 0 {
							app.map[y + 1][x] = unsafe { Tiles(-int(app.map[y + 1][x])) }
						}
						if x < app.map[0].len - 1 && int(app.map[y][x + 1]) > 0 {
							app.map[y][x + 1] = unsafe { Tiles(-int(app.map[y][x + 1])) }
						}
					}
					3 {
						if y > 0 && int(app.map[y - 1][x]) > 0 {
							app.map[y - 1][x] = unsafe { Tiles(-int(app.map[y - 1][x])) }
						}
						if x > 0 && int(app.map[y][x - 1]) > 0 {
							app.map[y][x - 1] = unsafe { Tiles(-int(app.map[y][x - 1])) }
						}
						if x < app.map[0].len - 1 && int(app.map[y][x + 1]) > 0 {
							app.map[y][x + 1] = unsafe { Tiles(-int(app.map[y][x + 1])) }
						}
					}
					4 {
						if y < app.map.len - 1 && int(app.map[y + 1][x]) > 0 {
							app.map[y + 1][x] = unsafe { Tiles(-int(app.map[y + 1][x])) }
						}
						if x > 0 && int(app.map[y][x - 1]) > 0 {
							app.map[y][x - 1] = unsafe { Tiles(-int(app.map[y][x - 1])) }
						}
						if x < app.map[0].len - 1 && int(app.map[y][x + 1]) > 0 {
							app.map[y][x + 1] = unsafe { Tiles(-int(app.map[y][x + 1])) }
						}
					}
					else {}
				}
			}
			15...15 {
				if y > 0 && int(app.map[y - 1][x]) > 0 {
					app.map[y - 1][x] = unsafe { Tiles(-int(app.map[y - 1][x])) }
				}
				if y < app.map.len - 1 && int(app.map[y + 1][x]) > 0 {
					app.map[y + 1][x] = unsafe { Tiles(-int(app.map[y + 1][x])) }
				}
				if x > 0 && int(app.map[y][x - 1]) > 0 {
					app.map[y][x - 1] = unsafe { Tiles(-int(app.map[y][x - 1])) }
				}
				if x < app.map[0].len - 1 && int(app.map[y][x + 1]) > 0 {
					app.map[y][x + 1] = unsafe { Tiles(-int(app.map[y][x + 1])) }
				}
			}
			else {}
		}
	}
}

fn (mut app App) plante_infect(plante Plant, x int, y int) {
	match plante.id {
		.none {}
		.root { app.root_infect(plante, x, y) }
	}
}

fn (mut app App) root_infect(root Plant, x int, y int) {
	mut infect_array := [5][5]bool{}

	for i in 0 .. 5 {
		for j in 0 .. 5 {
			infect_array[i][j] = ((rand.int_in_range(1, 11) or { 0 }) == 10)
		}
	}

	infect_array[0][0] = false
	infect_array[0][4] = false
	infect_array[4][0] = false
	infect_array[4][4] = false
	infect_array[2][2] = true

	for i in 0 .. 5 {
		for j in 0 .. 5 {
			if x + j - 2 < app.map[0].len && x + j - 2 >= 0 && y + i - 2 < app.map.len
				&& y + i - 2 >= 0 && int(app.map[y + i - 2][x + j - 2]) > 0 && infect_array[i][j] {
				app.map[y + i - 2][x + j - 2] = unsafe { Tiles(-int(app.map[y + i - 2][x + j - 2])) }
			}
		}
	}
}

fn (mut app App) plante_bless (plante Plant, x int, y int) {
	match plante.id {
		.none {}
		.root { app.root_bless(plante, x, y) }
	}
}

fn (mut app App) root_bless (root Plant, x int, y int) {
	mut infect_array := [5][5]bool{}

	for i in 0 .. 5 {
		for j in 0 .. 5 {
			infect_array[i][j] = ((rand.int_in_range(1, 11) or { 0 }) == 10)
		}
	}

	infect_array[0][0] = false
	infect_array[0][4] = false
	infect_array[4][0] = false
	infect_array[4][4] = false
	infect_array[2][2] = false

	for i in 0 .. 5 {
		for j in 0 .. 5 {
			if x + j - 2 < app.map[0].len && x + j - 2 >= 0 && y + i - 2 < app.map.len
				&& y + i - 2 >= 0 && int(app.map[y + i - 2][x + j - 2]) < 0 && infect_array[i][j] {
				app.map[y + i - 2][x + j - 2] = unsafe { Tiles(-int(app.map[y + i - 2][x + j - 2])) }
			}
		}
	}
}

fn (mut app App) huge_tree_bless_and_infect (i int, j int) {
	mut d := 0
	mut r := 0
	if !app.blessed_huge_tree.infected {
		d = dist_squared(j, i, app.blessed_huge_tree.x, app.blessed_huge_tree.y)
		for k in 1 .. 11 {
			if d <= app.blessed_huge_tree.radius_squared_of_effect * (k - 1) / k {
				r = rand.int_in_range(1, k*10) or {0}
				if r == 1 && int(app.map[i][j]) <= 0 {
					app.map[i][j] = unsafe { Tiles(- int(app.map[i][j])) }
				}
			}
		}
	}
	if app.infected_huge_tree.infected {
		d = dist_squared(j, i, app.infected_huge_tree.x, app.infected_huge_tree.y)
		for k in 1 .. 11 {
			if d <= app.infected_huge_tree.radius_squared_of_effect * (k - 1) / k {
				r = rand.int_in_range(1, k) or {0}
				if r == 1 && int(app.map[i][j]) >= 0 {
					app.map[i][j] = unsafe { Tiles(- int(app.map[i][j])) }
				}
			}
		}
	} else {
		d = dist_squared(j, i, app.infected_huge_tree.x, app.infected_huge_tree.y)
		for k in 1 .. 11 {
			if d <= app.infected_huge_tree.radius_squared_of_effect * (k - 1) / k {
				r = rand.int_in_range(1, k+1000) or {0}
				if r == 1 && int(app.map[i][j]) <= 0 {
					app.map[i][j] = unsafe { Tiles(- int(app.map[i][j])) }
				}
			}
		}
	}
}

fn (mut app App) global_bless_and_infect() {
	for i in 0 .. app.map.len {
		for j in 0 .. app.map[0].len {
			if int(app.map[i][j]) < 0 {
				app.tile_infect(j, i)
			}
			if app.plant_map[i][j].id != .none && app.plant_map[i][j].infected
				&& !app.plant_map[i][j].potted {
				app.plante_infect(app.plant_map[i][j], j, i)
			}
			if app.plant_map[i][j].id != .none && app.plant_map[i][j].blessed {
				app.plante_bless(app.plant_map[i][j], j, i)
			}
			app.huge_tree_bless_and_infect(i, j)
		}
	}
}

fn (mut app App) check_win_condition () {
	mut win := true
	for i in app.cure_infected_huge_tree_condition {
		win = win && app.plant_map[i[1]][i[0]].id != .none && app.plant_map[i[1]][i[0]].blessed == true
	}
	if win {
		app.cure_elder_tree()
	}
}

fn (mut app App) cure_elder_tree () {
	app.infected_huge_tree.infected = false
	mut dep_i := 0
	mut fin_i := 0
	mut dep_j := 0
	mut fin_j := 0
	if (app.infected_huge_tree.x - app.infected_huge_tree.radius_squared) >= 0 {
		dep_i = app.infected_huge_tree.x - app.infected_huge_tree.radius_squared
	} else {
		dep_i = 0
	}
	if (app.infected_huge_tree.x + app.infected_huge_tree.radius_squared) <= app.map.len {
		fin_i = app.infected_huge_tree.x + app.infected_huge_tree.radius_squared
	} else {
		fin_i = app.map.len
	}
	if (app.infected_huge_tree.y - app.infected_huge_tree.radius_squared) >= 0 {
		dep_j = app.infected_huge_tree.y - app.infected_huge_tree.radius_squared
	} else {
		dep_j = 0
	}
	if (app.infected_huge_tree.y + app.infected_huge_tree.radius_squared) <= app.map[0].len {
		fin_j = app.infected_huge_tree.y + app.infected_huge_tree.radius_squared
	} else {
		fin_j = app.map[0].len
	}
	for i in dep_i .. fin_i {
		for j in dep_j .. fin_j {
			if app.map[i][j] == .inf_elder_tree {
				app.map[i][j] = .elder_tree
			}
		}
	}
	for i in app.cure_infected_huge_tree_condition {
		app.map[i[1]][i[0]] = .pot
	}
}

fn (mut app App) save() ! {
	mut file := os.open_file('saved_map', 'w')!
	unsafe { file.write_ptr(u32(app.map.len), int(sizeof(u32))) }
	unsafe { file.write_ptr(u32(app.map[0].len), int(sizeof(u32))) }
	for i in 0 .. app.map.len {
		unsafe { file.write_ptr(app.map[i].data, app.map[i].len * int(sizeof(Tiles))) }
	}
	for i in 0 .. app.map.len {
		unsafe { file.write_ptr(app.plant_map[i].data, app.map[i].len * int(sizeof(Plant))) }
	}
	for i in 0 .. app.map.len {
		unsafe { file.write_ptr(app.seed_map[i].data, app.map[i].len * int(sizeof(Seed))) }
	}
	unsafe { file.write_ptr(app.player, int(sizeof(Gardener))) }
	unsafe { file.write_ptr(app.infected_huge_tree.infected, int(sizeof(bool))) }
	file.close()
}

fn (mut app App) load() ! {
	mut f := os.open('saved_map')!

	u32_size := sizeof(u32)
	tile_size := sizeof(Tiles)
	plant_size := sizeof(Plant)
	seed_size := sizeof(Seed)
	player_size := sizeof(Gardener)

	mut read_n := u32(0)

	mut map_len := u32(0)
	f.read_struct_at(mut map_len, read_n)!
	read_n += u32_size

	mut map_len_i := u32(0)
	f.read_struct_at(mut map_len_i, read_n)!
	read_n += u32_size

	app.map = [][]Tiles{}
	app.plant_map = [][]Plant{}
	app.seed_map = [][]Seed{}

	mut app_map_i_j := Tiles.none
	mut app_plant_map_i_j := Plant{}
	mut app_seed_map_i_j := Seed{}

	for i in 0 .. map_len {
		app.map << []Tiles{}
		app.plant_map << []Plant{}
		app.seed_map << []Seed{}
		for _ in 0 .. map_len_i {
			f.read_struct_at(mut app_map_i_j, read_n)!
			app.map[i] << app_map_i_j

			f.read_struct_at(mut app_plant_map_i_j,
				((read_n - 2 * u32_size) / tile_size) * plant_size + 2 * u32_size +
				map_len * map_len_i * tile_size)!
			app.plant_map[i] << app_plant_map_i_j

			f.read_struct_at(mut app_seed_map_i_j,
				((read_n - 2 * u32_size) / tile_size) * seed_size + 2 * u32_size +
				map_len * map_len_i * tile_size + map_len * map_len_i * plant_size)!
			app.seed_map[i] << app_seed_map_i_j

			read_n += sizeof(Tiles)
		}
	}

	app.player = Gardener{}
	f.read_struct_at(mut app.player, 2 * u32_size + map_len * map_len_i * tile_size +
		map_len * map_len_i * plant_size + map_len * map_len_i * seed_size)!
	
	f.read_struct_at(mut app.infected_huge_tree.infected, 2 * u32_size + map_len * map_len_i * tile_size +
		map_len * map_len_i * plant_size + map_len * map_len_i * seed_size + player_size)!
	if !app.infected_huge_tree.infected {
		app.cure_elder_tree()
	}

	f.close()
}

fn (mut app App) init_map () {
	if os.exists('saved_map') {
		app.load() or {}
	} else {
		for i in 0 .. 100 {
			app.map << []Tiles{}
			app.plant_map << []Plant{}
			app.seed_map << []Seed{}
			for j in 0 .. 100 {
				app.plant_map[i] << Plant{}
				app.seed_map[i] << Seed{}
				/*if dist_squared(j, i, app.blessed_huge_tree.x, app.blessed_huge_tree.y) <= app.blessed_huge_tree.radius_squared {
					app.map[i] << Tiles.elder_tree
				} else */if dist_squared(j, i, app.infected_huge_tree.x, app.infected_huge_tree.y) <= app.infected_huge_tree.radius_squared {
					app.map[i] << Tiles.inf_elder_tree
				} else {
					mut tile_is_infected_pot := false
					for k in app.cure_infected_huge_tree_condition {
						tile_is_infected_pot = tile_is_infected_pot || (i == k[1] && j == k[0])
					}
					if tile_is_infected_pot {
						app.map[i] << Tiles.inf_pot
					} else {
						app.map[i] << unsafe{ Tiles(rand.int_in_range(-12, 0) or {0}) } // infected grass 1 to 12 randomly
					}
				}
			}
		}

		app.map[10][5] = .none
		app.map[10][6] = .none
		app.map[10][7] = .none
		app.map[11][7] = .none
		app.map[12][7] = .none
		app.map[12][6] = .none
		app.map[11][8] = .none
		app.map[11][9] = .none
		app.map[11][10] = .none
		app.map[11][11] = .none
		app.map[11][12] = .none
		app.map[12][12] = .none
		app.map[12][13] = .none
		app.map[10][12] = .none
		app.map[9][11] = .none
		app.map[9][10] = .none
		app.map[9][8] = .none
		app.map[9][7] = .none
		app.map[9][14] = .none
		app.map[10][14] = .none
		app.map[10][15] = .none
		app.map[11][14] = .none
		app.map[11][13] = .none

		app.map[7][12] = .robinet
		app.map[9][13] = .robinet
		app.map[10][13] = .robinet
		app.map[9][15] = .robinet
		app.map[10][16] = .robinet
		app.map[11][16] = .robinet
		app.map[11][15] = .robinet

		app.map[12][5] = .pot
		app.map[14][8] = .pot
		app.map[14][11] = .pot
		app.map[12][14] = .pot
		
		app.plant_map[09][25] = plants[int(Plant_type.root)]
		
		app.plant_map[14][49] = plants[int(Plant_type.root)]
		
		app.plant_map[03][95] = plants[int(Plant_type.root)]
		app.plant_map[07][89] = plants[int(Plant_type.root)]
		app.plant_map[17][83] = plants[int(Plant_type.root)]
		app.plant_map[13][94] = plants[int(Plant_type.root)]
		
		app.plant_map[26][76] = plants[int(Plant_type.root)]
		app.plant_map[28][78] = plants[int(Plant_type.root)]
		
		app.plant_map[57][16] = plants[int(Plant_type.root)]
		
		app.plant_map[43][32] = plants[int(Plant_type.root)]
		app.plant_map[44][28] = plants[int(Plant_type.root)]
		
		app.plant_map[42][43] = plants[int(Plant_type.root)]
		app.plant_map[57][50] = plants[int(Plant_type.root)]
		app.plant_map[47][55] = plants[int(Plant_type.root)]
		
		app.plant_map[44][75] = plants[int(Plant_type.root)]
		app.plant_map[56][68] = plants[int(Plant_type.root)]
		
		app.plant_map[76][22] = plants[int(Plant_type.root)]
		app.plant_map[64][33] = plants[int(Plant_type.root)]
		
		app.plant_map[65][78] = plants[int(Plant_type.root)]
		app.plant_map[68][63] = plants[int(Plant_type.root)]
		app.plant_map[79][65] = plants[int(Plant_type.root)]
		app.plant_map[60][76] = plants[int(Plant_type.root)]
		
		app.plant_map[64][90] = plants[int(Plant_type.root)]
		app.plant_map[63][98] = plants[int(Plant_type.root)]
		app.plant_map[75][86] = plants[int(Plant_type.root)]
		app.plant_map[73][93] = plants[int(Plant_type.root)]
		app.plant_map[78][82] = plants[int(Plant_type.root)]
		
		app.plant_map[84][00] = plants[int(Plant_type.root)]
		app.plant_map[87][16] = plants[int(Plant_type.root)]
		app.plant_map[92][13] = plants[int(Plant_type.root)]
		app.plant_map[97][08] = plants[int(Plant_type.root)]
		
		app.plant_map[88][33] = plants[int(Plant_type.root)]
		
		app.plant_map[82][60] = plants[int(Plant_type.root)]
		app.plant_map[93][68] = plants[int(Plant_type.root)]
		app.plant_map[89][67] = plants[int(Plant_type.root)]
		
		app.plant_map[83][81] = plants[int(Plant_type.root)]
		app.plant_map[91][86] = plants[int(Plant_type.root)]
		app.plant_map[87][88] = plants[int(Plant_type.root)]
		app.plant_map[23][90] = plants[int(Plant_type.root)]
		app.plant_map[92][93] = plants[int(Plant_type.root)]
		app.plant_map[98][83] = plants[int(Plant_type.root)]
		app.plant_map[95][97] = plants[int(Plant_type.root)]
		app.plant_map[85][98] = plants[int(Plant_type.root)]
		app.plant_map[89][99] = plants[int(Plant_type.root)]
		app.plant_map[81][95] = plants[int(Plant_type.root)]
	}
}

fn time_to_mili(t time.Time) int {
	return t.year * 31556952000 + t.month * 2629746000 + t.day * 86400000 + t.hour * 3600000 +
		t.minute * 60000 + t.second * 1000
}

fn dist_squared (x1 int, y1 int, x2 int, y2 int) int {
	return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
}

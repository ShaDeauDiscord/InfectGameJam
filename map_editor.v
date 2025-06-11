import gg
import os
import linklancien.playint
import math.vec { Vec2 }

const font_path = os.resource_abs_path('FontMono.ttf')
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
	playint.Opt
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



fn main() {
	mut app := &App{}
	app.ctx = gg.new_context(
		fullscreen:    true
		width:         100 * 8
		height:        100 * 8
		create_window: true
		window_title:  '--'
		user_data:     app
		bg_color:      bg_color
		init_fn:       on_init
		frame_fn:      on_frame
		event_fn:      on_event
		click_fn:      on_click
		resized_fn:    on_resized
		sample_count:  4
		font_path:     font_path
	)
	app.init()
	app.ctx.run()
}

fn on_init(mut app App) {
	// app.new_action(function, 'fonction_name', -1 or int(KeyCode. ))
	app.buttons_list << [
		playint.Button{
			text:           'Options'
			pos:            Vec2[f32]{4 * 'Options'.len + 5, 16}
			function:       playint.option_pause
			is_visible:     params_is_visible
			is_actionnable: params_is_actionnable
		},
	]
}

fn on_frame(mut app App) {
	app.window_width = gg.window_size().width
	app.window_height = gg.window_size().height
	if app.window_height > app.window_width {
		app.tile_size = app.window_width / 20
	} else {
		app.tile_size = app.window_height / 20
	}
	app.ctx.begin()
	app.settings_render()
	app.buttons_draw(mut app)
	app.main_menu_render()
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	app.on_event(e, mut app)
}

fn on_click(x f32, y f32, button gg.MouseButton, mut app App) {
	app.check_buttons_options()
	app.buttons_check(mut app)
}

fn on_resized(e &gg.Event, mut app App) {
	size := gg.window_size()
	old_x := app.ctx.width
	old_y := app.ctx.height
	new_x := size.width
	new_y := size.height

	app.buttons_pos_resize(old_x, old_y, new_x, new_y)

	app.ctx.width = size.width
	app.ctx.height = size.height
}

// main menu fn:

fn (mut app App) main_menu_render() {
	mut transparency := u8(255)
	if app.changing_options {
		transparency = 175
	}
	x := app.ctx.width / 2
	y := app.ctx.height / 2
	playint.text_rect_render(app.ctx, app.text_cfg, x, y, true, true, 'TITLE', transparency)
}

// main fn:

fn params_is_visible(mut app playint.Appli) bool {
	return true
}

fn params_is_actionnable(mut app playint.Appli) bool {
	return true
}

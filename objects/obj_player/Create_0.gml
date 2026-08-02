image_speed = 0;

player_state = new Statement(self);

h_speed = 0;
v_speed = 0;
acceleration = 2;
j_acceleration = 3;
f_acceleration = 3;
max_speed = 10;
v_max_speed = 20;
f_riction = 1;
jump_drift = 2;
slide_max_speed = 10;

idle_state = new StatementState(self, "Idle")
	.AddEnter(function() {
		image_index = 0;
		h_speed = 0;
	})
	.AddUpdate(function() {
		if !place_meeting(x,y+v_speed,obj_brick) {
			player_state.ChangeState("Falling");
			return;
		}
		
		// check controls and change state accordingly
		if (keyboard_check(vk_down)) {
			player_state.ChangeState("Crouch");
			return;
		}
		if (keyboard_check(vk_space)) {
			player_state.ChangeState("Jumping");
			return;
		}
		rightkey_down = keyboard_check(vk_right);
		leftkey_down = keyboard_check(vk_left);
		move_dir = rightkey_down - leftkey_down;
		if (move_dir != 0) {
			if place_meeting(x+(move_dir*5),y,obj_brick) {
				//player_state.ChangeState("Idle");
				return;
			} else {
				player_state.ChangeState("Running");	
			}
		}
	})
	
crouch_state = new StatementState(self, "Crouch")
	.AddEnter(function() {
		image_index = 5;
	})
	.AddUpdate(function() {
		if !place_meeting(x,y+v_speed,obj_brick) {
			player_state.ChangeState("Falling");
			return;
		}
		
		if (!keyboard_check(vk_down)) {
			player_state.ChangeState("Idle");	
		}
		if (h_speed > 0) {
			h_speed = max(0, h_speed - 2 * f_riction);
		} else if (h_speed < 0) {
			h_speed = min(0, h_speed + 2 * f_riction);
		}
		if place_meeting(x+h_speed,y,obj_brick) {
			player_state.ChangeState("Idle");
			return;
		} else {
			self.x += h_speed;
		}
	})
	
running_state = new StatementState(self, "Running")
	.AddEnter(function() {
		image_index = 1;
	})
	.AddUpdate(function() {
		if !place_meeting(x,y+v_speed,obj_brick) {
			player_state.ChangeState("Falling");
			return;
		}
		
		if (keyboard_check(vk_down)) {
			player_state.ChangeState("Crouch");
			return;
		}
		if (keyboard_check(vk_space)) {
			player_state.ChangeState("Jumping");
			return;
		}
		rightkey_down = keyboard_check(vk_right);
		leftkey_down = keyboard_check(vk_left);
		move_dir = rightkey_down - leftkey_down;
		if (move_dir == 1) {
			if (h_speed < 0) {
				// moving left, enter slide
				show_debug_message("moving left, enter slide")
				show_debug_message(string(h_speed));
				player_state.ChangeState("Sliding");
				return;
			}
			h_speed = min(max_speed, h_speed + acceleration);
			image_index = 1;
			image_xscale = 1;
		} else if (move_dir == -1) {
			if (h_speed > 0) {
				// moving right, enter slide
				show_debug_message("moving right, enter slide")
				player_state.ChangeState("Sliding");
				return;
			}
			h_speed = max(-max_speed, h_speed - acceleration);
			image_index = 1;
			image_xscale = -1;
		} else { // no input
			// slow to a stop
			if (h_speed > 0) {
				h_speed = max(0, h_speed - 1 * f_riction);
			} else if (h_speed < 0) {
				h_speed = min(0, h_speed + 1 * f_riction);
			} 
			if (h_speed == 0) {
				// go back to idle
				player_state.ChangeState("Idle");
			}
		}
		if place_meeting(x+h_speed,y,obj_brick) {
			player_state.ChangeState("Idle");
			return;
		} else {
			self.x += h_speed;
		}
	})
	
jumping_state = new StatementState(self, "Jumping")
	.AddEnter(function () {
		image_index = 2;	
	})
	.AddUpdate(function () {
		// account for player inputs with jump_drift
		
		
		if (player_state.GetStateTime() >= 10) {
			player_state.ChangeState("Floating");
			return;
		}
		if (keyboard_check(vk_space)) {
			v_speed = v_max_speed;
			self.y -= v_speed;
		} else {
			player_state.ChangeState("Floating");
			return;
		}
		
		rightkey_down = keyboard_check(vk_right);
		leftkey_down = keyboard_check(vk_left);
		move_dir = rightkey_down - leftkey_down;
		
		if (h_speed > 0) {
			if (move_dir == 1) {
				h_speed = min(max_speed, h_speed + acceleration);
			} else if (move_dir == -1) {
				h_speed = max(-max_speed, h_speed - jump_drift);
			}
		} else if (h_speed < 0) {
			if (move_dir == 1) {
				h_speed = min(max_speed, h_speed + jump_drift);
			} else if (move_dir == -1) {
				h_speed = max(-max_speed, h_speed - acceleration);
			}
		} else if (h_speed == 0) {
			if (image_xscale == 1) {
				if (move_dir == 1) {
					h_speed = acceleration;
				} else if (move_dir == -1) {
					h_speed = jump_drift;
				}
			} else if (image_xscale == -1) {
				if (move_dir == 1) {
					h_speed = jump_drift;
				} else if (move_dir == -1) {
					h_speed = acceleration;
				}
			}
		} else { // no input
			// slow to a stop
			if (h_speed > 0) {
				h_speed = max(0, h_speed - 2 * f_riction);
			} else if (h_speed < 0) {
				h_speed = min(0, h_speed + 2 * f_riction);
			} else if (h_speed == 0) {
				// go back to idle
			}
		}
		if place_meeting(x+h_speed,y,obj_brick) {
			player_state.ChangeState("Idle");
			return;
		} else {
			self.x += h_speed;
		}
	});
	
floating_state = new StatementState(self, "Floating")
	.AddEnter(function() {
		
	})
	.AddUpdate(function () {
		if (player_state.GetStateTime() > 5) {
			player_state.ChangeState("Falling");	
			return;
		}
		
		if place_meeting(x,y+v_speed,obj_brick) {
			player_state.ChangeState("Idle");
			return;
		}
		
		v_speed = max(v_max_speed, v_speed - j_acceleration);
		self.y += v_speed;
		
		rightkey_down = keyboard_check(vk_right);
		leftkey_down = keyboard_check(vk_left);
		move_dir = rightkey_down - leftkey_down;
		
		if (h_speed > 0) {
			if (move_dir == 1) {
				h_speed = min(max_speed, h_speed + acceleration);
			} else if (move_dir == -1) {
				h_speed = max(-max_speed, h_speed - jump_drift);
			}
		} else if (h_speed < 0) {
			if (move_dir == 1) {
				h_speed = min(max_speed, h_speed + jump_drift);
			} else if (move_dir == -1) {
				h_speed = max(-max_speed, h_speed - acceleration);
			}
		} else if (h_speed == 0) {
			if (image_xscale == 1) {
				if (move_dir == 1) {
					h_speed = acceleration;
				} else if (move_dir == -1) {
					h_speed = jump_drift;
				}
			} else if (image_xscale == -1) {
				if (move_dir == 1) {
					h_speed = jump_drift;
				} else if (move_dir == -1) {
					h_speed = acceleration;
				}
			}
		} else { // no input
			// slow to a stop
			if (h_speed > 0) {
				h_speed = max(0, h_speed - 2 * f_riction);
			} else if (h_speed < 0) {
				h_speed = min(0, h_speed + 2 * f_riction);
			} else if (h_speed == 0) {
				// go back to idle
			}
		}
		if place_meeting(x+h_speed,y,obj_brick) {
			player_state.ChangeState("Idle");
			return;
		} else {
			self.x += h_speed;
		}
	})
	
falling_state = new StatementState(self, "Falling")
	.AddEnter(function() {
		image_index = 8;
	})
	.AddUpdate(function() {
		v_speed = max(v_max_speed, v_speed - f_acceleration);
		if place_meeting(x,y+v_speed,obj_brick) {
			player_state.ChangeState("Running");
			return;
		}
		self.y += v_speed;
		
		rightkey_down = keyboard_check(vk_right);
		leftkey_down = keyboard_check(vk_left);
		move_dir = rightkey_down - leftkey_down;
		
		if (h_speed > 0) {
			if (move_dir == 1) {
				h_speed = min(max_speed, h_speed + acceleration);
			} else if (move_dir == -1) {
				h_speed = max(-max_speed, h_speed - jump_drift);
			}
		} else if (h_speed < 0) {
			if (move_dir == 1) {
				h_speed = min(max_speed, h_speed + jump_drift);
			} else if (move_dir == -1) {
				h_speed = max(-max_speed, h_speed - acceleration);
			}
		} else if (h_speed == 0) {
			if (image_xscale == 1) {
				if (move_dir == 1) {
					h_speed = acceleration;
				} else if (move_dir == -1) {
					h_speed = jump_drift;
				}
			} else if (image_xscale == -1) {
				if (move_dir == 1) {
					h_speed = jump_drift;
				} else if (move_dir == -1) {
					h_speed = acceleration;
				}
			}
		} else { // no input
			// slow to a stop
			if (h_speed > 0) {
				h_speed = max(0, h_speed - 2 * f_riction);
			} else if (h_speed < 0) {
				h_speed = min(0, h_speed + 2 * f_riction);
			} else if (h_speed == 0) {
				// go back to idle
			}
		}
		if place_meeting(x+h_speed,y,obj_brick) {
			player_state.ChangeState("Idle");
			return;
		} else {
			self.x += h_speed;
		}
	});
	
sliding_state = new StatementState(self, "Sliding")
	.AddEnter(function() {
		image_index = 3;
		if (h_speed < 0) {
			image_xscale = -1;
			h_speed = -slide_max_speed;	
		} else if (h_speed > 0) {
			image_xscale = 1;
			h_speed = slide_max_speed;	
		}
	})
	.AddUpdate(function() {
		if !place_meeting(x,y+v_speed,obj_brick) {
			player_state.ChangeState("Falling");
			return;
		}
		
		if (keyboard_check(vk_space)) {
			player_state.ChangeState("Backflipping");
		}
		
		if (h_speed > 0) {
			h_speed = max(0, h_speed - f_riction);
		} else if (h_speed < 0) {
			// mirror sprite
			h_speed = min(0, h_speed + f_riction);
		} else if (h_speed == 0) {
			player_state.ChangeState("Running");	
		}
		if place_meeting(x+h_speed,y,obj_brick) {
			player_state.ChangeState("Idle");
			return;
		} else {
			self.x += h_speed;
		}
	});
	
backflipping_state = new StatementState(self, "Backflipping")
	.AddEnter(function () {
		image_index = 4;
		// invert horizontal speed
		h_speed = 0 - h_speed;	
	})
	.AddUpdate(function () {
		if (player_state.GetStateTime() >= 10) {
			player_state.ChangeState("Floating");
			return;
		}
		
		v_speed = v_max_speed;
		self.y -= v_speed;
		
		if (move_dir == 1) {
			h_speed = min(max_speed, h_speed + acceleration);
		} else if (move_dir == -1) {
			h_speed = max(-max_speed, h_speed - acceleration);
		} else { // no input

			if (h_speed > 0) {
				h_speed = max(0, h_speed - 2 * f_riction);
			} else if (h_speed < 0) {
				h_speed = min(0, h_speed + 2 * f_riction);
			} else if (h_speed == 0) {
				
			}
		}
		if place_meeting(x+h_speed,y,obj_brick) {

		} else {
			self.x += h_speed;
		}
	});
	
player_state.AddState(idle_state);
player_state.AddState(running_state);
player_state.AddState(crouch_state);
player_state.AddState(jumping_state);
player_state.AddState(falling_state);
player_state.AddState(floating_state);
player_state.AddState(sliding_state);
player_state.AddState(backflipping_state);
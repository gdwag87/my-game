//! Stage 1: V's dash and double jump, driven from design/abilities.json (via abilities.rs).
//! Method (hooks.json kinematic_controller + no_scripted_fall_death, from the ER field note):
//! after physics each frame, move the player by writing CSChrPhysicsModule.position and
//! chr_proxy_pos_update_requested; turn the game's gravity off while we drive, restore it after.
use crate::{abilities::*, log};
use eldenring::{cs::{CSHavokMan, PlayerIns, WorldChrMan}, fd4::FD4TaskData, position::{HavokPosition, PositionDelta}};
use fromsoftware_shared::FromStatic;
use glam::{Quat, Vec3};

const RAY_FILTER_MAP: u32 = 0x2000058; // map collision only (field note)
const BODY_RADIUS: f32 = 0.45;

#[derive(Default)]
pub struct Movement {
    drive_left: f32,        // seconds our controller still drives
    velocity: Vec3,         // metres per second while driving
    saved_gravity: Option<f32>,
    dash_cooldown: f32,
    air_jump_used: bool,
    was_down: [bool; 2],    // dash, jump
    frames: u64,
}

fn key_down(vk: i32) -> bool {
    unsafe { windows_sys::Win32::UI::Input::KeyboardAndMouse::GetAsyncKeyState(vk) as u16 & 0x8000 != 0 }
}

fn game_focused() -> bool {
    use windows_sys::Win32::{System::Threading::GetCurrentProcessId, UI::WindowsAndMessaging::{GetForegroundWindow, GetWindowThreadProcessId}};
    let mut pid = 0u32;
    unsafe { GetWindowThreadProcessId(GetForegroundWindow(), &mut pid); pid == GetCurrentProcessId() }
}

fn vk_of(key_id: &str) -> i32 {
    crate::keys::KEYS.iter().find(|k| k.id == key_id).map(|k| k.vk as i32).unwrap_or(0)
}

impl Movement {
    pub fn tick(&mut self, data: &FD4TaskData) {
        self.frames += 1;
        let dt = data.delta_time.time.clamp(0.0, 0.1);
        let Ok(wcm) = (unsafe { WorldChrMan::instance_mut() }) else { return };
        let Some(player) = wcm.main_player.as_mut() else { return };
        let player: &mut PlayerIns = player;
        if self.dash_cooldown > 0.0 { self.dash_cooldown -= dt; }

        // input (edge-triggered, only while the game window has focus)
        let focused = game_focused();
        let dash_down = focused && key_down(vk_of(DASH.key));
        let jump_down = focused && key_down(vk_of(DOUBLE_JUMP.key));
        let dash_pressed = dash_down && !self.was_down[0];
        let jump_pressed = jump_down && !self.was_down[1];
        self.was_down = [dash_down, jump_down];

        let on_ground = { let ph = &player.chr_ins.modules.physics; ph.standing_on_solid_ground || ph.is_touching_ground };
        if on_ground { self.air_jump_used = false; }

        if self.drive_left <= 0.0 {
            if dash_pressed && self.dash_cooldown <= 0.0 && self.pay_stamina(player, DASH.stamina_cost) {
                let fwd = self.forward(player);
                self.start(player, fwd * (DASH.distance_m / DASH.duration_s), DASH.duration_s);
                self.dash_cooldown = DASH.cooldown_s;
                log(&format!("[dash] fwd=({:.2},{:.2},{:.2}) pos={:?}", fwd.x, fwd.y, fwd.z, pos3(player)));
            } else if jump_pressed && !on_ground && !self.air_jump_used && self.pay_stamina(player, DOUBLE_JUMP.stamina_cost) {
                // rise distance_m over duration_s, keeping a little forward drift
                let fwd = self.forward(player) * 2.0;
                self.start(player, Vec3::new(fwd.x, DOUBLE_JUMP.distance_m / DOUBLE_JUMP.duration_s, fwd.z), DOUBLE_JUMP.duration_s);
                self.air_jump_used = true;
                log(&format!("[double_jump] pos={:?}", pos3(player)));
            }
        }

        if self.drive_left > 0.0 { self.drive(player, dt); }
    }

    fn forward(&self, player: &PlayerIns) -> Vec3 {
        let o = player.chr_ins.modules.physics.orientation; // XYZW
        let q = Quat::from_xyzw(o.0, o.1, o.2, o.3);
        let f = q * Vec3::Z;
        Vec3::new(f.x, 0.0, f.z).normalize_or_zero()
    }

    fn pay_stamina(&self, player: &mut PlayerIns, cost: i32) -> bool {
        let data = &mut player.chr_ins.modules.data;
        if data.stamina < cost { log(&format!("[stamina] need {cost}, have {}", data.stamina)); return false; }
        data.stamina -= cost;
        true
    }

    fn start(&mut self, player: &mut PlayerIns, velocity: Vec3, duration: f32) {
        let ph = &mut player.chr_ins.modules.physics;
        if self.saved_gravity.is_none() { self.saved_gravity = Some(ph.gravity_multiplier); }
        ph.gravity_multiplier = 0.0;
        ph.gravity_disabled = true;
        self.velocity = velocity;
        self.drive_left = duration;
    }

    fn drive(&mut self, player: &mut PlayerIns, dt: f32) {
        let step = self.velocity * dt.min(self.drive_left);
        let origin = player.chr_ins.modules.physics.position;
        // probe at chest height for walls/obstacles in the way
        let chest = HavokPosition(origin.0, origin.1 + 1.0, origin.2, origin.3);
        let dir = step.normalize_or_zero();
        let probe = step + dir * BODY_RADIUS;
        let blocked = match unsafe { CSHavokMan::instance() } {
            Ok(havok) => havok.phys_world.cast_ray(RAY_FILTER_MAP, &chest, PositionDelta(probe.x, probe.y, probe.z), player).is_some(),
            Err(_) => true, // no physics world -> don't move
        };
        if blocked {
            log(&format!("[move] blocked at {:?}", pos3(player)));
            self.stop(player);
            return;
        }
        let ph = &mut player.chr_ins.modules.physics;
        ph.position = HavokPosition(origin.0 + step.x, origin.1 + step.y, origin.2 + step.z, origin.3);
        ph.chr_proxy_pos_update_requested = true;
        self.drive_left -= dt;
        if self.drive_left <= 0.0 { log(&format!("[move] done at {:?}", pos3(player))); self.stop(player); }
    }

    fn stop(&mut self, player: &mut PlayerIns) {
        let ph = &mut player.chr_ins.modules.physics;
        if let Some(g) = self.saved_gravity.take() { ph.gravity_multiplier = g; }
        ph.gravity_disabled = false;
        self.drive_left = 0.0;
        self.velocity = Vec3::ZERO;
    }
}

fn pos3(player: &PlayerIns) -> (f32, f32, f32) {
    let p = player.chr_ins.modules.physics.position;
    ((p.0 * 100.0).round() / 100.0, (p.1 * 100.0).round() / 100.0, (p.2 * 100.0).round() / 100.0)
}

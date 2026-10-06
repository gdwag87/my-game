//! Stage 0 of "V in the Lands Between".
//! Proves three hooks.json rows on the player's PC without touching game memory:
//!   loader  - ModEngine2 loads this DLL into eldenring.exe
//!   log     - we write v_in_elden.log next to the DLL (the test oracle)
//!   read_input (partial) - we see our ability keys (polling; the DirectInput hook comes in stage 1)
use std::{fs::OpenOptions, io::Write, path::PathBuf, time::{Duration, Instant}};
use windows_sys::Win32::{
    Foundation::{BOOL, HMODULE, HWND, LPARAM, TRUE, FALSE},
    System::{LibraryLoader::GetModuleFileNameW, SystemServices::DLL_PROCESS_ATTACH, Threading::GetCurrentProcessId},
    UI::{Input::KeyboardAndMouse::GetAsyncKeyState,
         WindowsAndMessaging::{EnumWindows, GetWindowThreadProcessId, IsWindowVisible}},
};

mod keys; // generated from design/keys.json by gen.py

static mut MODULE: HMODULE = std::ptr::null_mut();

fn log_path() -> PathBuf {
    let mut buf = [0u16; 1024];
    let n = unsafe { GetModuleFileNameW(MODULE, buf.as_mut_ptr(), buf.len() as u32) } as usize;
    let mut p = PathBuf::from(String::from_utf16_lossy(&buf[..n]));
    p.set_file_name("v_in_elden.log");
    p
}

fn log(msg: &str) {
    if let Ok(mut f) = OpenOptions::new().create(true).append(true).open(log_path()) {
        let _ = writeln!(f, "{msg}");
    }
}

unsafe extern "system" fn find_own_window(hwnd: HWND, found: LPARAM) -> BOOL {
    let mut pid = 0u32;
    GetWindowThreadProcessId(hwnd, &mut pid);
    if pid == GetCurrentProcessId() && IsWindowVisible(hwnd) != 0 {
        *(found as *mut bool) = true;
        return FALSE;
    }
    TRUE
}

fn game_window_visible() -> bool {
    let mut found = false;
    unsafe { EnumWindows(Some(find_own_window), &mut found as *mut bool as LPARAM) };
    found
}

fn run() {
    log(&format!("[boot] v_in_elden stage0 {} loaded into pid {}", env!("CARGO_PKG_VERSION"), unsafe { GetCurrentProcessId() }));
    let start = Instant::now();
    // boot gate (hooks.json): wait for the visible game window before anything else
    while !game_window_visible() {
        std::thread::sleep(Duration::from_millis(250));
        if start.elapsed() > Duration::from_secs(300) { log("[boot] no game window after 300 s, giving up"); return; }
    }
    log(&format!("[boot] game window visible after {:.1} s", start.elapsed().as_secs_f32()));
    let mut was_down = [false; keys::KEYS.len()];
    loop {
        for (i, k) in keys::KEYS.iter().enumerate() {
            let down = unsafe { GetAsyncKeyState(k.vk as i32) } as u16 & 0x8000 != 0;
            if down && !was_down[i] { log(&format!("[input] {} ({}) pressed", k.id, k.name)); }
            was_down[i] = down;
        }
        std::thread::sleep(Duration::from_millis(16));
    }
}

#[no_mangle]
pub extern "system" fn DllMain(module: HMODULE, reason: u32, _: *mut core::ffi::c_void) -> BOOL {
    if reason == DLL_PROCESS_ATTACH {
        unsafe { MODULE = module };
        // never do game work on DllMain's thread (field note gotcha 1)
        std::thread::spawn(|| run());
    }
    TRUE
}

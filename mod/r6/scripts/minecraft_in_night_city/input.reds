// GENERATED from design/controls.json
module MinecraftInNightCity

// State the CET Lua reads from the player: Game.GetPlayer().mcBreakHeld etc.
@addField(PlayerPuppet) public let mcBreakHeld: Bool;
@addField(PlayerPuppet) public let mcPlaceCount: Int32;
@addField(PlayerPuppet) public let mcScroll: Int32;
@addField(PlayerPuppet) public let mcSlot: Int32;

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
  let name: CName = ListenerAction.GetName(action);
  let type: gameinputActionType = ListenerAction.GetType(action);
  let down: Bool = Equals(type, gameinputActionType.BUTTON_PRESSED);
  let up: Bool = Equals(type, gameinputActionType.BUTTON_RELEASED);

  // Discovery mode: every distinct button action is logged so the sheet's unknown names can be filled in.
  if down { LogChannel(n"DEBUG", s"[MCraft] action pressed: \(NameToString(name))"); }

  if Equals(name, n"__UNSET__") { if down { this.mcBreakHeld = true; } if up { this.mcBreakHeld = false; } }
  if Equals(name, n"__UNSET__") && down { this.mcPlaceCount += 1; }
  if Equals(name, n"NextWeapon") && down { this.mcScroll += 1; }
  if Equals(name, n"PreviousWeapon") && down { this.mcScroll -= 1; }
  if down {
    if Equals(name, n"WeaponSlot1") { this.mcSlot = 1; }
    if Equals(name, n"WeaponSlot2") { this.mcSlot = 2; }
    if Equals(name, n"WeaponSlot3") { this.mcSlot = 3; }
    if Equals(name, n"WeaponSlot4") { this.mcSlot = 4; }
  }
  return wrappedMethod(action, consumer);
}

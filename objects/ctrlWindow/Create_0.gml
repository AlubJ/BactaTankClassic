// min number of game instances (one based)
global.GAME_INSTANCE_MIN = 1;

// max number of game instances (one based)
global.GAME_INSTANCE_MAX = 2;

// define game instance (zero based); increase one to game instance id environment and global variables
global.GAME_INSTANCE_ID = int64(bool(EnvironmentGetVariableExists("GAME_INSTANCE_ID")) ? EnvironmentGetVariable("GAME_INSTANCE_ID") : string(0));
EnvironmentSetVariable("GAME_INSTANCE_ID", string(global.GAME_INSTANCE_ID + 1));

if (global.GAME_INSTANCE_ID == 0)
{ // if parent processs of game instance 1
  // previous run file cleanup
  var dname = game_save_id + "/proc/";
  if directory_exists(dname)
  {
    directory_destroy(dname);
  }
  directory_create(dname);
  // duplicate current process by executing its own command line
  global.CHILD_PROCESS_ID = ExecProcessFromArgVAsync(GetArgVFromProcid(ProcIdFromSelf())); // define child process id for later use
  //window_set_position((display_get_width() / 2) - window_get_width(), (display_get_height() / 2) - window_get_height());
}
else if (global.GAME_INSTANCE_ID == 1)
{ // if child process of game instance 0
  // duplicate current process by executing its own command line
  global.CHILD_PROCESS_ID = ProcIdFromSelf(); // define child process id for later use
  //window_set_position((display_get_width() / 2), (display_get_height() / 2) - window_get_height());
  window_set_size(400, 400);
  window_set_caption("test");
}
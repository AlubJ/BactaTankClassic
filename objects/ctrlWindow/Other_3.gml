// if game instance has child
if (global.GAME_INSTANCE_ID <= global.GAME_INSTANCE_MAX - 1) { // if parent process
  // global.CHILD_PROCESS_ID == 0 if not successfully executed and CompletionStatusFromExecutedProcess() == true if child is dead
  if (global.CHILD_PROCESS_ID != 0 && !CompletionStatusFromExecutedProcess(global.CHILD_PROCESS_ID)) {
    // tell grandchild process the child process is going to die so grandchild can also die (see step event)
    var fname = game_save_id + "/proc/" + string(global.CHILD_PROCESS_ID) + ".tmp";
    var fd = file_text_open_write(fname);
    if (fd != -1) {
      file_text_write_string(fd, "CHILD_PROCESS_DIED");
      file_text_writeln(fd);
      file_text_close(fd);
    } else {
      show_error("ERROR: failed to open file for writing!\n\nERROR DETAILS: Too many file descriptors opened by the current process or insufficient priviledges to access file!", true);
    }
  }
}

// if game instance has parent
if (global.GAME_INSTANCE_ID > global.GAME_INSTANCE_MIN - 1) { // if child process
  // tell parent process im dead so parent can also die (see step event)
  var fname = game_save_id + "/proc/" + string(ProcIdFromSelf()) + ".tmp";
  var fd = file_text_open_write(fname);
  if (fd != -1) {
    file_text_write_string(fd, "CHILD_PROCESS_DIED");
    file_text_writeln(fd);
    file_text_close(fd);
  } else {
    show_error("ERROR: failed to open file for writing!\n\nERROR DETAILS: Too many file descriptors opened by the current process or insufficient priviledges to access file!", true);
  }
}
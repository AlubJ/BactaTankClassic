function window_set_clamp_size(min_width = -1, min_height = -1, max_width = -1, max_height = -1)
{
	window_set_min_width(min_width);
	window_set_min_height(min_height);
	window_set_max_width(max_width);
	window_set_max_height(max_height);
}

#region Multi Windows

function GetArgVFromProcid(proc_id) {
  var kinfo_proc, kinfo_argv;
  kinfo_proc = ProcInfoFromProcIdEx(proc_id, KINFO_EXEP | KINFO_ARGV);
  kinfo_argv[0] = ExecutableImageFilePath(kinfo_proc);
  if (CommandLineLength(kinfo_proc) >= 2) {
    for (var i = 1; i < CommandLineLength(kinfo_proc); i++) {
      kinfo_argv[i] = CommandLine(kinfo_proc, i);
    }
  }
  FreeProcInfo(kinfo_proc);
  return kinfo_argv;
}

function ExecProcessFromArgVAsync(kinfo_argv) {
  var cmdline = "";
  for (var i = 0; i < array_length(kinfo_argv); i++) {
    var tmp = string_replace_all(kinfo_argv[i], "\\", "\\\\");
	tmp = "\"" + string_replace_all(tmp, "\"", "\\\"") + "\"";
	if (i < array_length(kinfo_argv) - 1) tmp += " ";
	cmdline += tmp;
  }
  return ProcessExecuteAsync(cmdline);
}

#endregion
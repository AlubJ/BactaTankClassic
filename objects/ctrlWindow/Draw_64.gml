/// @desc
draw_text(32, 32, 
"GAME_INSTANCE_ID: " + string(global.GAME_INSTANCE_ID) + "\n" + "CURRENT_PROCESS_ID: " + string(ProcIdFromSelf()) + "\n" +
"CHILD_PROCESS_ID: " + ((global.CHILD_PROCESS_ID != ProcIdFromSelf()) ? (string(global.CHILD_PROCESS_ID) + "\n") : "None\n"));
// ReceiverSplitter by meanwhile_0 with help from Tinter <3
//
// Potential issue: Double tape pickups in the geometry room may
// fail to split? So far it seems to work, but if it ever fails 
// to split for you, let me know and I'll see if I can investigate
// it further.

state("Receiver") {
    byte isGrounded : 0x00838C90, 0x8, 0x1C, 0x18, 0x2C, 0x74;
    byte unplayedTapes : 0x008627E8, 0x4, 0x4, 0x24, 0x28, 0x1D0;
    byte tapeInProgress : 0x008627E8, 0x4, 0x4, 0x24, 0x28, 0x1CC;
    byte heardTapes : 0x008627E8, 0x0, 0x8, 0x18, 0xA0, 0x8, 0x8;
    byte isReset : 0x0085F74C, 0x23;
}

startup {
    // These are the variables we'll be using.
    vars.lastTapeCount = 0;
    vars.totalTapes = 0;
    vars.runStarted = false;

    print("[ReceiverSplitter] Startup block completed");
}

init {
    // In order to prevent any potentially funky behaviour,
    // we reset all the variables upon init. Just a safeguard.
    print("[ReceiverSplitter] Resetting variables");

    vars.lastTapeCount = 0;
    vars.totalTapes = 0;
    vars.runStarted = false;

    print("[ReceiverSplitter] Init block completed");
}

update {
    vars.totalTapes = current.unplayedTapes + current.tapeInProgress + current.heardTapes;
}

start {
    // isGrounded is 4 when the player's colliding with the floor.
    // isReset is 63 when the run isn't being reset
    if ((vars.runStarted == false) && (current.isGrounded == 4) && (current.isReset == 63)) {
        // Paranoid about tape counts not being what they're supposed to be
        // so lets reset the tapes again just to be sure.
        vars.runStarted = true;
        vars.lastTapeCount = 0;
        vars.totalTapes = 0;
        print("[ReceiverSplitter] Run started");
        return true;
    }
}

reset {
    // isReset counts down from 63 when it's time to reset, with 60
    // being the number it resets at.
    if ((vars.runStarted == true) && (current.isReset == 60)) {
        vars.runStarted = false;
        print("[ReceiverSplitter] Run reset");
        return true;
    }
}

split {
    if ((vars.runStarted == true) && (vars.totalTapes > vars.lastTapeCount)) {
        vars.lastTapeCount++;
        print("[ReceiverSplitter] Split done");
        return true;
    }
}
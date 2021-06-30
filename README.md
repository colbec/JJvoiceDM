# JJvoiceDM
A voice interaction dialog manager written in Julia interfacing with Julius

The goal of this project is to provide a voice interface to [Julius speech recognizer](https://github.com/julius-speech/julius) running as a socket server. The dialog manager makes various checks to ensure the background facilities are running and then enters a loop to receive voice prompts. The prompts are interpreted by the recognizer according to the active grammar (established independently by the user) and results are returned to the user. The entire system runs on a local machine without need for cloud facilities, and the voice model is primarily a speaker-dependent model but might be a speaker-independent model if the situation warrants it; the former allows much greater flexibility in modifying the grammar and vocabulary and establishing meaningful specialist contexts.

The system uses facilities from both [Flite](https://github.com/festvox/flite) and [Festival](https://github.com/festvox/festival). Julia dependencies are [LightXML](https://github.com/JuliaIO/LightXML.jl), [Sockets](https://github.com/JuliaLang/julia/tree/master/stdlib/Sockets).

To run the DM:
  1. navigate to a suitable directory in a terminal window
  2. start the Julius backend with previously prepared language and acoustic models on the default socket 10500. The current test is for an active process with configuration file that contains "mod.jconf". Also ensure that both flite and festival (as server) are available and running correctly for your purposes
  3. in a separate terminal window run "`julia dm.jl`"
  4. monitor the outputs in both terminal windows to watch for issues
  5. in the current code, the voice command "ZULU ZULU" causes the DM to terminate. Alternatively, terminating the running Julia in the terminal window will of couse stop the process. Normal termination of the DM also terminates the Julius socket server and closes the socket
  6. If there is no response from the audio but there is a response from the request for the STATUS this might indicate that the Julius server needs to be started with `padsp` if Pulseaudio is running your sound system.

Tested on openSUSE Linux with Julia master and 1.6.1

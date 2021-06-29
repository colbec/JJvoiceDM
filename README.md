# voiceDM
A voice interaction dialog manager written in Julia interfacing with Julius

The goal of this project is to provide a voice interface to [Julius speech recognizer](https://github.com/julius-speech/julius) running as a socket server. The dialog manager makes various checks to ensure the background facilities are running and then enters a loop to receive voice prompts. The prompts are interpreted by the recognizer according to the active grammar (established independently by the user) and results are returned to the user. The entire system runs on a local machine without need for cloud facilities, and the voice model is primarily a speaker-dependent model but might be a speaker-independent model if the situation warrants it; the former allows much greater flexibility in modifying the vocabulary and estabilishing meaningful specialist contexts.

The system uses facilities from both [Flite](https://github.com/festvox/flite) and [Festival](https://github.com/festvox/festival).

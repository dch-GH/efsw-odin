// Copyright (c) 2020 Martín Lucas Golini

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// This software is a fork of the "simplefilewatcher" by James Wynn (james@jameswynn.com)
// http://code.google.com/p/simplefilewatcher/ also MIT licensed.

// Odin bindings for "Entropia File System Watcher" (https://github.com/SpartanJ/efsw).
package esfw

import c "core:c/libc"

when ODIN_DEBUG {
	@(extra_linker_flags = "/NODEFAULTLIB:msvcrt")
	foreign import lib "efsw-debug.lib"
} else {
	@(extra_linker_flags = "/NODEFAULTLIB:msvcrt")
	foreign import lib "efsw.lib"
}

Watcher :: rawptr
WatchId :: c.long

Action :: enum c.int {
	EFSW_ADD      = 1, // Sent when a file is created or renamed
	EFSW_DELETE   = 2, // Sent when a file is deleted or renamed
	EFSW_MODIFIED = 3, // Sent when a file is modified
	EFSW_MOVED    = 4, // Sent when a file is moved
}

Option :: enum c.int {
	/** For Windows, the default buffer size of 63*1024 bytes sometimes is not enough and
	file system events may be dropped. For that, using a different (bigger) buffer size
	can be defined here, but note that this does not work for network drives,
	because a buffer larger than 64K will fail the folder being watched, see
	http://msdn.microsoft.com/en-us/library/windows/desktop/aa365465(v=vs.85).aspx)**/
	EFSW_OPT_WIN_BUFFER_SIZE   = 1,
	/** For Windows, per default all events are captured but we might only be interested
	in a subset; the value of the option should be set to a bitwise or'ed set of
	FILE_NOTIFY_CHANGE_* flags. **/
	EFSW_OPT_WIN_NOTIFY_FILTER = 2,
}

Watcher_Option :: struct {
	option: Option,
	value:  c.int,
}

File_Action_Callback :: proc "c" (
	watcher: Watcher,
	watchid: WatchId,
	dir, filename: cstring,
	action: Action,
	old_filename: cstring,
	param: rawptr,
)

@(default_calling_convention = "c", link_prefix = "efsw_")
foreign lib {
	create :: proc(generic_mode: c.int) -> Watcher ---
	release :: proc(watcher: Watcher) ---
	getlasterror :: proc() -> cstring ---
	clearlasterror :: proc() ---
	addwatch :: proc(watcher: Watcher, directory: cstring, callback_fn: File_Action_Callback, recursive: c.int, param: rawptr) -> WatchId ---
	addwatch_withoptions :: proc(watcher: Watcher, directory: cstring, callback_fn: File_Action_Callback, recursive: c.int, options: [^]Watcher_Option, options_number: c.int, param: rawptr) -> WatchId ---
	removewatch :: proc(watcher: Watcher, directory: cstring) ---
	removewatch_byid :: proc(watcher: Watcher, watchid: WatchId) ---
	watch :: proc(watcher: Watcher) ---
	follow_symlinks :: proc(watcher: Watcher, enable: c.int) ---
	follow_symlinks_isenabled :: proc(watcher: Watcher) -> c.int ---
	allow_outofscopelinks :: proc(watcher: Watcher, allow: c.int) ---
	outofscopelinks_isallowed :: proc(watcher: Watcher) -> c.int ---
}

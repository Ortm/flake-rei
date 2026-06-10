/**
 * Glide Browser Configuration
 * File: ~/.config/glide/glide.ts
 *
 * For API details and configuration cookbook, visit:
 * https://glide-browser.app/
 */

// --- TypeScript Definitions for API & Autocomplete ---

interface SearchEngine {
	name: string;
	keyword: string;
	search_url: string;
	favicon_url?: string;
	is_default?: boolean;
}

interface KeymapContext {
	tab_id: number;
	url?: string;
}

interface AutocmdContext {
	tab_id: number;
	url: string;
}

interface GlideOptions {
	native_tabs?: "show" | "hide" | "autohide";
	hint_chars?: string;
	switch_mode_on_focus?: boolean;
	go_next_patterns?: string[];
	go_previous_patterns?: string[];
	keymaps_use_physical_layout?: boolean;
	keyboard_layouts?: string[];
}

interface GlideSearchEngines {
	add(engine: SearchEngine): void;
}

interface GlideKeymaps {
	set(
		mode: "normal" | "insert" | "visual" | "hint" | "command" | "ignore",
		key: string,
		action: string | ((context: KeymapContext) => void | Promise<void>),
	): void;
	del(
		mode: "normal" | "insert" | "visual" | "hint" | "command" | "ignore",
		key: string,
	): void;
}

interface GlideAutocmds {
	create(
		event:
			| "UrlEnter"
			| "ConfigLoaded"
			| "ModeChanged"
			| "TabEnter"
			| "CommandLineExit"
			| "AddonInstalled",
		pattern: RegExp,
		callback: (context: AutocmdContext) => void | Promise<void>,
	): void;
	remove(id: string): void;
}

interface GlideExcmds {
	create(
		meta: { name: string; description: string },
		callback: (args: string[]) => void | Promise<void>,
	): void;
}

interface StyleOptions {
	id: string;
	css: string;
	overwrite?: boolean;
}

interface GlideStyles {
	add(type: "css", options: StyleOptions): void;
	has(id: string): boolean;
	get(id: string): string | null;
}

interface GlideAddons {
	install(
		xpi_url: string,
		opts?: { force?: boolean; private_browsing_allowed?: boolean },
	): Promise<void>;
	list(types?: string | string[]): Promise<unknown[]>;
}

interface GlidePrefs {
	set(name: string, value: string | number | boolean): void;
	get(name: string): string | number | boolean | undefined;
	clear(name: string): void;
}

interface GlideAPI {
	o: GlideOptions;
	search_engines: GlideSearchEngines;
	keymaps: GlideKeymaps;
	autocmds: GlideAutocmds;
	excmds: GlideExcmds;
	styles: GlideStyles;
	addons: GlideAddons;
	prefs: GlidePrefs;
	include(path: string): void;
}

declare const glide: GlideAPI;

// --- Configuration ---

// Customize core behavior of the browser.
glide.o.native_tabs = "show"; // options: "show" | "hide" | "autohide"
glide.o.hint_chars = "asdfghjkl"; // characters used for link hint labels (home-row friendly)
glide.o.switch_mode_on_focus = true; // auto switch to insert mode when a text input gains focus

// Define custom search engines for the address bar.
glide.search_engines.add({
	name: "Google",
	keyword: "g",
	search_url: "https://www.google.com/search?q={searchTerms}",
	is_default: true,
});

glide.search_engines.add({
	name: "GitHub",
	keyword: "gh",
	search_url: "https://github.com/search?q={searchTerms}",
	is_default: false,
});

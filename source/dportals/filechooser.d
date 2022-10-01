module dportals.filechooser;
import dportals.promise;
import dportals;
import ddbus;
import std.array;


struct FileChoice {
    string id;
    string label;
    FileChoiceItem[] choices;
    string default_;
}

struct FileChoiceItem {
    string id;
    string label;
}

struct FileFilterItem {
    uint id;
    string type;
}

struct FileFilter {
    string humanName;
    FileFilterItem[] items;
}

struct OpenFileResponse {
    struct OpenFileResponseChoice {
        string k;
        string v;
    }

    string[] uris;
    OpenFileResponseChoice[] choices;
    FileFilter currentFilter;
}

struct FileOpenOptions {
    /**
        A string that will be used as the last element of the handle. 
        Must be a valid object path element. 
        See the org.freedesktop.portal.Request documentation for more information about the handle. 
    */
    string handleToken = null;

    /**
        Label for the accept button. Mnemonic underlines are allowed. 
    */
    string acceptLabel = null;

    /**
        Whether the dialog should be modal. Default is yes. 
    */
    bool modal = true;

    /**
        Whether multiple files can be selected or not. Default is single-selection. 
    */
    bool multiple = false;

    /**
        Whether to select for folders instead of files. Default is to select files. This option was added in version 3. 
    */
    bool directory = false;

    /**
    List of serialized file filters.

    Each item in the array specifies a single filter to offer to the user. 
    The first string is a user-visible name for the filter. 
    The a(us) specifies a list of filter strings, 
    which can be either a glob-style pattern (indicated by 0) or a mimetype (indicated by 1). 
    Patterns are case-sensitive. To match different capitalizations of, e.g. '*.ico', use a pattern like '*.[iI][cC][oO]'.

    Example: [('Images', [(0, '*.ico'), (1, 'image/png')]), ('Text', [(0, '*.txt')])]

    Note that filters are purely there to aid the user in making a useful selection. 
    The portal may still allow the user to select files that don't match any filter criteria, 
    and applications must be prepared to handle that. 
    */
    FileFilter[] filters;

    /**
        Request that this filter be set by default at dialog creation. 
        If the filters list is nonempty, it should match a filter in the list to set the default filter from the list. 
        Alternatively, it may be specified when the list is empty to apply the filter unconditionally. 
    */
    FileFilter* currentFilter;

    /**
    List of serialized combo boxes to add to the file chooser.

    For each element, the first string is an ID that will be returned with the response, 
    the second string is a user-visible label. 
    The a(ss) is the list of choices, each being an ID and a user-visible label. 
    The final string is the initial selection, or "", to let the portal decide which choice will be initially selected. 
    None of the strings, except for the initial selection, should be empty.

    As a special case, passing an empty array for the list of choices indicates a boolean choice that is typically displayed 
    as a check button, using "true" and "false" as the choices.

    Example: [('encoding', 'Encoding', [('utf8', 'Unicode (UTF-8)'), ('latin15', 'Western')], 'latin15'), ('reencode', 'Reencode', [], 'false')] 
    */
    FileChoice[] choices;
}

struct FileSaveOptions {
    /**
        A string that will be used as the last element of the handle. 
        Must be a valid object path element. 
        See the org.freedesktop.portal.Request documentation for more information about the handle. 
    */
    string handleToken = null;

    /**
        Label for the accept button. Mnemonic underlines are allowed. 
    */
    string acceptLabel = null;

    /**
        Whether the dialog should be modal. Default is yes. 
    */
    bool modal = true;

    /**
        List of serialized file filters.

        Each item in the array specifies a single filter to offer to the user. 
        The first string is a user-visible name for the filter. 
        The a(us) specifies a list of filter strings, 
        which can be either a glob-style pattern (indicated by 0) or a mimetype (indicated by 1). 
        Patterns are case-sensitive. To match different capitalizations of, e.g. '*.ico', use a pattern like '*.[iI][cC][oO]'.

        Example: [('Images', [(0, '*.ico'), (1, 'image/png')]), ('Text', [(0, '*.txt')])]

        Note that filters are purely there to aid the user in making a useful selection. 
        The portal may still allow the user to select files that don't match any filter criteria, 
        and applications must be prepared to handle that. 
    */
    FileFilter[] filters;

    /**
        Request that this filter be set by default at dialog creation. 
        If the filters list is nonempty, it should match a filter in the list to set the default filter from the list. 
        Alternatively, it may be specified when the list is empty to apply the filter unconditionally. 
    */
    FileFilter* currentFilter;

    /**
        List of serialized combo boxes to add to the file chooser.

        For each element, the first string is an ID that will be returned with the response, 
        the second string is a user-visible label. 
        The a(ss) is the list of choices, each being an ID and a user-visible label. 
        The final string is the initial selection, or "", to let the portal decide which choice will be initially selected. 
        None of the strings, except for the initial selection, should be empty.

        As a special case, passing an empty array for the list of choices indicates a boolean choice that is typically displayed 
        as a check button, using "true" and "false" as the choices.

        Example: [('encoding', 'Encoding', [('utf8', 'Unicode (UTF-8)'), ('latin15', 'Western')], 'latin15'), ('reencode', 'Reencode', [], 'false')] 
    */
    FileChoice[] choices;

    /**
        Suggested filename.
    */
    string currentName;

    /**
        Suggested folder to save the file in.
    */
    string currentFolder;

    /**
        The current file (when saving an existing file).
    */
    string currentFile;
}

/**
    Opens a file open dialog

    See: https://flatpak.github.io/xdg-desktop-portal/#gdbus-method-org-freedesktop-portal-FileChooser.OpenFile
*/
Promise dpFileChooserOpenFile(string parentWindow, string title, FileOpenOptions options = FileOpenOptions.init) {
    PathIface obj = new PathIface(
        dpConn,
        busName("org.freedesktop.portal.Desktop"), 
        ObjectPath("/org/freedesktop/portal/desktop"), 
        interfaceName("org.freedesktop.portal.FileChooser"), 
    );


    Variant!DBusAny[string] optionsKV;
    if (!options.handleToken.empty) optionsKV["handle_token"] = variant(DBusAny(options.handleToken));
    if (!options.acceptLabel.empty) optionsKV["accept_label"] = variant(DBusAny(options.acceptLabel));
    optionsKV["modal"] = variant(DBusAny(options.modal));
    optionsKV["multiple"] = variant(DBusAny(options.multiple));
    optionsKV["directory"] = variant(DBusAny(options.directory));
    if (!options.filters.empty) optionsKV["filters"] = variant(DBusAny(options.filters));
    if (options.currentFilter) optionsKV["current_filter"] = variant(DBusAny(*options.currentFilter));
    if (!options.choices.empty) optionsKV["choices"] = variant(DBusAny(options.choices));

    ObjectPath path = obj.call!ObjectPath("OpenFile", parentWindow, title, optionsKV);
    return new Promise(MessagePattern(path, interfaceName("org.freedesktop.portal.Request"), "Response", true));
}


/**
    Opens a file save dialog

    See: https://flatpak.github.io/xdg-desktop-portal/#gdbus-method-org-freedesktop-portal-FileChooser.SaveFile
*/
Promise dpFileChooserSaveFile(string parentWindow, string title, FileSaveOptions options = FileSaveOptions.init) {
    PathIface obj = new PathIface(
        dpConn,
        busName("org.freedesktop.portal.Desktop"), 
        ObjectPath("/org/freedesktop/portal/desktop"), 
        interfaceName("org.freedesktop.portal.FileChooser"), 
    );

    Variant!DBusAny[string] optionsKV;
    if (!options.handleToken.empty) optionsKV["handle_token"] = variant(DBusAny(options.handleToken));
    if (!options.acceptLabel.empty) optionsKV["accept_label"] = variant(DBusAny(options.acceptLabel));
    optionsKV["modal"] = variant(DBusAny(options.modal));
    if (!options.filters.empty) optionsKV["filters"] = variant(DBusAny(options.filters));
    if (options.currentFilter) optionsKV["current_filter"] = variant(DBusAny(*options.currentFilter));
    if (!options.choices.empty) optionsKV["choices"] = variant(DBusAny(options.choices));
    if (!options.currentName.empty) optionsKV["current_name"] = variant(DBusAny(options.currentName));
    if (!options.currentFolder.empty) optionsKV["current_folder"] = variant(DBusAny(cast(ubyte[])(options.currentFolder~"\0")));
    if (!options.currentFile.empty) optionsKV["current_file"] = variant(DBusAny(cast(ubyte[])(options.currentFile~"\0")));

    ObjectPath path = obj.call!ObjectPath("SaveFile", parentWindow, title, optionsKV);
    return new Promise(MessagePattern(path, interfaceName("org.freedesktop.portal.Request"), "Response", true));
}
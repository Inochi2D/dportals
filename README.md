# xdg-desktop-portal for D
This D library allows you to interface with XDG Desktop Portals when
you aren't using GTK or Qt.



## Example
```d
module app;
import dportals;
import std.stdio;

void main() {
    
    // Initialize Desktop Portals support
    // This will live for the *entire* application lifetime.
    dpInit();

    // Open a File Open Dialog with some options set.
    // A Promise type is returned which you can await.
    // If you want your application to be non-blocking
    // you will have to continually call dpUpdate
    // then check the success value of the response
    // before getting the value.
    auto promise = dpFileChooserOpenFile(
        "", 
        "Open File", 

        // See FileOpenOptions for API
        FileOpenOptions(
            "",
            "UwU",
            false,
            true,
            false,
            [FileFilter("PNG", [FileFilterItem(0, "*.png")])],
            new FileFilter("PNG", [FileFilterItem(0, "*.png")]),
            [FileChoice("mangle", "Mangle File", [], "")]
        )
    );

    // Await the response.
    // This will continually in a loop call dpUpdate
    // until the dialog closes for some reason.
    promise.await();

    // Print useful info about selected file
    write(promise.success(), " ");
    if (promise.success) write(promise.value());
    else write("null");
    write("\n");
}
```
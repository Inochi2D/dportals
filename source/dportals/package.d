module dportals;
import ddbus;

public import dportals.filechooser;

package(dportals) {
    Connection dpConn;
    __gshared MessageRouter dpRouter;
}

/**
    Initalizes the d-portals interface
*/
void dpInit() {
    dpConn = connectToBus();
    dpRouter = new MessageRouter();
    registerRouter(dpConn, dpRouter);
}

/**
    Updates the d-portals interface
*/
bool dpUpdate() {
    return dpConn.tick;
}
module dportals.promise;
import dportals;
import ddbus;

/**
    Response code
*/
enum ResponseCode {
    NONE = -1,

    /**
        Success, the request is carried out
    */
    Success = 0,

    /**
        The user cancelled the interaction
    */
    UserCancelled = 1,

    /**
        The user interaction was ended in some other way
    */
    EndedOther = 2
}

class Promise {
private:
    bool signalRecv;
    MessagePattern pattern;

    ResponseCode retStatus = ResponseCode.NONE;
    Variant!DBusAny[string] retVal;

public:
    ~this() {
        dpRouter.callTable.remove(pattern);
    }

    this(MessagePattern pattern) {
        this.pattern = pattern;
        dpRouter.setHandler!void(pattern, (uint response, Variant!DBusAny[string] results) {
            this.signalRecv = true;
            this.retStatus = cast(ResponseCode)response;

            if (this.success) {
                this.retVal = results;
            }
        });
    }

    /**
        Cancels the promise, closing the event
    */
    final
    void close() {
        PathIface obj = new PathIface(
            dpConn,
            busName("org.freedesktop.portal.Desktop"), 
            pattern.path, 
            pattern.iface, 
        );
        obj.call!DBusAny("Close");
    }

    /**
        Gets whether the Promise is alive
    */
    final
    bool alive() { return !signalRecv; }

    /**
        Gets whether the Promise completed successfully
    */
    final
    bool success() { return signalRecv && (retStatus == ResponseCode.Success); }

    /**
        Returns the status of the promise
    */
    final
    ResponseCode status() {
        return retStatus;
    }

    /**
        Awaits the completion of the promise
    */
    final
    void await() {
        while(alive) { dpUpdate(); }
    }

    /**
        Gets the value of the Promise
    */
    final
    ref Variant!DBusAny[string] value() {
        if (!success || retVal.length == 0) throw new Exception("Promise not fulfilled.");
        return retVal;
    }
}
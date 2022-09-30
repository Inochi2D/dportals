module dportals.promise;
import dportals;
import ddbus;

struct DPResponse {
    uint response;
    Variant!DBusAny[string] results;
}

class Promise {
private:
    bool signalRecv;
    MessagePattern pattern;

    int retStatus;
    DPResponse* retVal;

public:
    ~this() {
        dpRouter.callTable.remove(pattern);
    }

    this(MessagePattern pattern) {
        this.pattern = pattern;
        dpRouter.setHandler!void(pattern, (uint response, Variant!DBusAny[string] results) {
            this.signalRecv = true;
            this.retStatus = response;

            if (this.success) {
                this.retVal = new DPResponse(response, results);
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
    bool success() { return signalRecv && (retStatus == 0); }

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
    ref DPResponse value() {
        if (!success || !retVal) throw new Exception("Promise not fulfilled.");
        return *retVal;
    }
}
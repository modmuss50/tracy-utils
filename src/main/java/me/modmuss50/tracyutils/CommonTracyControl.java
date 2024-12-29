package me.modmuss50.tracyutils;

import com.mojang.jtracy.TracyClient;
import me.modmuss50.tracyutils.mixin.TracyClientAccessor;

public abstract class CommonTracyControl {
    public void start() {
        TracyClient.load();
    }

    public void stop() {
        TracyClientAccessor.setLoaded(false);
    }
}

package me.modmuss50.tracyutils;

import me.modmuss50.tracyutils.mixin.TracyClientAccessor;

public class TracyClientExtension {

    public static boolean isConnected(){
        if (!TracyClientAccessor.isLoaded()) {
            return TracyBindingsExtension.isConnected();
        } else {
            return false;
        }
    };
}

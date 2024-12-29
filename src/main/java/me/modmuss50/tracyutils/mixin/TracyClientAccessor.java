package me.modmuss50.tracyutils.mixin;

import com.mojang.jtracy.TracyClient;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.gen.Accessor;

@Mixin(TracyClient.class)
public interface TracyClientAccessor {
    // Only use this to unload
    @Accessor
    static void setLoaded(boolean loaded) {
        throw new IllegalStateException();
    }

    @Accessor
    static boolean isLoaded() {
        throw new IllegalStateException();
    }
}

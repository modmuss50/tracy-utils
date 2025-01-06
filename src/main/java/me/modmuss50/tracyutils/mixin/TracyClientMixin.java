package me.modmuss50.tracyutils.mixin;

import com.llamalad7.mixinextras.injector.ModifyExpressionValue;
import com.llamalad7.mixinextras.injector.wrapoperation.Operation;
import com.llamalad7.mixinextras.injector.wrapoperation.WrapOperation;
import com.mojang.jtracy.TracyClient;
import me.modmuss50.tracyutils.TracyClientExtension;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.Unique;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Coerce;

@Mixin(TracyClient.class)
public class TracyClientMixin {
    @Shadow private static boolean loaded;
    @Unique
    private static final Logger LOGGER = LoggerFactory.getLogger("TracyClientMixin");

    @Unique
    private static boolean loadedNatives = false;

    @ModifyExpressionValue(method = "beginZone*", at = @At(value = "FIELD", target = "Lcom/mojang/jtracy/TracyClient;loaded:Z"))
    private static boolean beginZone(boolean original){
        // don't begin Zone if not connected to server, to prevent ending zones that were started before connection
        return (original && TracyClientExtension.isConnected());
    }

    @WrapOperation(method = "load", at = @At(value = "INVOKE", target = "Lcom/mojang/jtracy/Loader;load()V"))
    private static void load(@Coerce Object instance, Operation<Void> original) {
        // Allow multiple calls to load(), but only load the natives once.
        if (!loadedNatives) {
            try {
                LOGGER.info("Loading Tracy natives");
                original.call(instance);
                loaded = true;

                // This is mostly a test to ensure that the natives have been loaded.
                TracyClient.message("Loaded Tracy natives");
                LOGGER.info("Loaded Tracy natives");
                loadedNatives = true;
            } catch (Exception e) {
                LOGGER.error("Failed to load Tracy natives", e);
            }
        }
    }
}

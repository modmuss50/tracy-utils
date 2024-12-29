package me.modmuss50.tracyutils.mixin.client;

import net.minecraft.client.MinecraftClient;
import net.minecraft.client.util.tracy.TracyFrameCapturer;
import org.spongepowered.asm.mixin.Final;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Mutable;
import org.spongepowered.asm.mixin.gen.Accessor;

@Mixin(MinecraftClient.class)
public interface MinecraftClientAccessor {
    @Accessor
    @Final
    @Mutable
    void setTracyFrameCapturer(TracyFrameCapturer tracyFrameCapturer);
}

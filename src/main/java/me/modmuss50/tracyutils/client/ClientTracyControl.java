package me.modmuss50.tracyutils.client;

import me.modmuss50.tracyutils.CommonTracyControl;
import me.modmuss50.tracyutils.mixin.client.MinecraftClientAccessor;
import net.minecraft.client.MinecraftClient;
import net.minecraft.client.util.tracy.TracyFrameCapturer;

public class ClientTracyControl extends CommonTracyControl {
    public final static ClientTracyControl INSTANCE = new ClientTracyControl();

    private final MinecraftClientAccessor minecraftClientAccessor;

    private ClientTracyControl() {
        minecraftClientAccessor = (MinecraftClientAccessor) MinecraftClient.getInstance();
    }

    @Override
    public void start() {
        super.start();
        minecraftClientAccessor.setTracyFrameCapturer(new TracyFrameCapturer());
    }

    @Override
    public void stop() {
        super.stop();
        minecraftClientAccessor.setTracyFrameCapturer(null);
    }
}

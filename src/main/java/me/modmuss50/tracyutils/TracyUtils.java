package me.modmuss50.tracyutils;

import net.fabricmc.loader.api.FabricLoader;
import net.fabricmc.loader.api.ModContainer;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Optional;

public class TracyUtils {
    public static final String MOD_ID = "tracy-utils";

    public static ModContainer getModContainer() {
        return FabricLoader.getInstance().getModContainer(MOD_ID).orElseThrow();
    }


}

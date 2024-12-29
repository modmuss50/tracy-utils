package me.modmuss50.tracyutils.client;

import com.mojang.brigadier.context.CommandContext;
import com.mojang.brigadier.exceptions.CommandSyntaxException;
import me.modmuss50.tracyutils.NativeLocator;
import me.modmuss50.tracyutils.mixin.TracyClientAccessor;
import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.fabric.api.client.command.v2.ClientCommandManager;
import net.fabricmc.fabric.api.client.command.v2.ClientCommandRegistrationCallback;
import net.fabricmc.fabric.api.client.command.v2.FabricClientCommandSource;
import net.minecraft.text.Text;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Optional;
import java.util.UUID;

public class TracyUtilsClient implements ClientModInitializer {
    @Override
    public void onInitializeClient() {
        ClientCommandRegistrationCallback.EVENT.register((dispatcher, registryAccess) -> dispatcher.register(
                ClientCommandManager.literal("tracyclient")
                        .then(ClientCommandManager.literal("start").executes(TracyUtilsClient::executeStart))
                        .then(ClientCommandManager.literal("stop").executes(TracyUtilsClient::executeStop))
        ));
    }

    private static int executeStart(CommandContext<FabricClientCommandSource> ctx) throws CommandSyntaxException {
        if (TracyClientAccessor.isLoaded()) {
            ctx.getSource().sendError(Text.literal("Tracy is already running"));
            return 1;
        }

        ClientTracyControl.INSTANCE.start();

        try {
            boolean supported = runProfilerUI();
            if (!supported) {
                ctx.getSource().sendFeedback(Text.literal("Tracy profiler UI is not supported on this platform"));
                return 0;
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        return 0;
    }

    private static int executeStop(CommandContext<FabricClientCommandSource> ctx) throws CommandSyntaxException {
        if (!TracyClientAccessor.isLoaded()) {
            ctx.getSource().sendError(Text.literal("Tracy is not running"));
            return 1;
        }

        ClientTracyControl.INSTANCE.stop();

        return 0;
    }

    private static boolean runProfilerUI() throws IOException {
        Optional<Path> executable = NativeLocator.getTracyProfiler();
        if (executable.isEmpty()) {
            return false;
        }

        Path tempDir = Path.of(System.getProperty("java.io.tmpdir")).resolve("tracy-utils-" + UUID.randomUUID());
        Files.createDirectories(tempDir);
        Path finalPath = tempDir.resolve(executable.get().getFileName());
        Files.copy(executable.get(), finalPath, StandardCopyOption.REPLACE_EXISTING);

        // Run the profiler
        ProcessBuilder processBuilder = new ProcessBuilder();
        processBuilder.directory(tempDir.toFile());
        processBuilder.command(finalPath.toAbsolutePath().toString(), "-a", "127.0.0.1");
        processBuilder.start();

        return true;
    }
}

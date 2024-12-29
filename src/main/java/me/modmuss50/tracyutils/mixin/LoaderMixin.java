package me.modmuss50.tracyutils.mixin;

import me.modmuss50.tracyutils.NativeLocator;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.Redirect;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Optional;

@Mixin(targets = "com.mojang.jtracy.Loader")
public class LoaderMixin {
    @Redirect(method = "<init>", at = @At(value = "INVOKE", target = "Ljava/lang/String;contains(Ljava/lang/CharSequence;)Z", ordinal = 0))
    private boolean allowAllArches(String instance, CharSequence s) {
        // Skip the 64bitness check.
        return true;
    }

    @Inject(method = "unpackLibrary", at = @At("HEAD"), cancellable = true)
    private void unpackLibrary(Path root, CallbackInfoReturnable<Path> cir) throws IOException {
        Optional<Path> jtracy = NativeLocator.getJtracy();

        if (jtracy.isEmpty()) {
            throw new UnsupportedOperationException("Failed to locate jtracy library for " + NativeLocator.OS_ID);
        }

        final Path path = Files.createTempFile(root, "jtracy-tracy-utils", null);
        Files.copy(jtracy.get(), path, StandardCopyOption.REPLACE_EXISTING);
        cir.setReturnValue(path);
    }
}


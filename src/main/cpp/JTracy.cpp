#include <jni.h>
#include <tracy/Tracy.hpp>
#include <tracy/TracyC.h>

namespace {
TracyCZoneCtx _unwrapZoneContext(jint id) {
  return TracyCZoneCtx{static_cast<uint32_t>(id), 1};
}
} // namespace

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_startup(JNIEnv *,
                                                                    jclass) {
  // Not implemented in the original dll
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_shutdown(JNIEnv *,
                                                                     jclass) {
  // Not implemented in the original dll
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_markFrame(JNIEnv *,
                                                                      jclass,
                                                                      jlong) {
  FrameMark;
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_markFrameStart(
    JNIEnv *, jclass, jlong namePtr) {
  auto name = reinterpret_cast<const char *>(namePtr);
  FrameMarkStart(name);
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_markFrameEnd(
    JNIEnv *, jclass, jlong namePtr) {
  auto name = reinterpret_cast<const char *>(namePtr);
  FrameMarkEnd(name);
}

extern "C" JNIEXPORT jint JNICALL Java_com_mojang_jtracy_TracyBindings_beginZone(
    JNIEnv *env, jclass, jstring jName, jstring jFunction, jstring jFile,
    jint line) {
  auto name = env->GetStringUTFChars(jName, nullptr);
  auto function = env->GetStringUTFChars(jFunction, nullptr);
  auto file = env->GetStringUTFChars(jFile, nullptr);

  auto nameLen = static_cast<size_t>(env->GetStringUTFLength(jName));
  auto functionLen = static_cast<size_t>(env->GetStringUTFLength(jFunction));
  auto fileLen = static_cast<size_t>(env->GetStringUTFLength(jFile));

  uint64_t srcloc =
      ___tracy_alloc_srcloc_name(static_cast<uint32_t>(line), file, fileLen,
                                 function, functionLen, name, nameLen, 0);

  env->ReleaseStringUTFChars(jName, name);
  env->ReleaseStringUTFChars(jFunction, function);
  env->ReleaseStringUTFChars(jFile, file);

  auto ctx = ___tracy_emit_zone_begin_alloc(srcloc, 1);
  return ctx.id;
}

extern "C" JNIEXPORT jint JNICALL Java_com_mojang_jtracy_TracyBindings_frameImage(
    JNIEnv *env, jclass, jobject image, jint width, jint height, jint offset,
    jboolean flip) {
  void *bufferAddress =
      reinterpret_cast<void *>(env->GetDirectBufferAddress(image));
  TracyCFrameImage(bufferAddress, static_cast<uint16_t>(width),
                   static_cast<uint16_t>(height), static_cast<uint8_t>(offset),
                   static_cast<int>(flip));
  return 0;
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_endZone(JNIEnv *,
                                                                    jclass,
                                                                    jint id) {
  auto ctx = _unwrapZoneContext(id);
  TracyCZoneEnd(ctx);
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_addZoneText(
    JNIEnv *env, jclass, jint id, jstring jText) {
  auto ctx = _unwrapZoneContext(id);
  auto text = env->GetStringUTFChars(jText, nullptr);
  auto textLen = static_cast<size_t>(env->GetStringUTFLength(jText));
  TracyCZoneText(ctx, text, textLen);
  env->ReleaseStringUTFChars(jText, text);
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_setZoneColor(
    JNIEnv *, jclass, jint id, jint color) {
  auto ctx = _unwrapZoneContext(id);
  TracyCZoneColor(ctx, static_cast<uint32_t>(color));
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_addZoneValue(
    JNIEnv *, jclass, jint id, jlong value) {
  auto ctx = _unwrapZoneContext(id);
  TracyCZoneValue(ctx, value);
}

extern "C" JNIEXPORT jlong JNICALL Java_com_mojang_jtracy_TracyBindings_mallocNamed(
    JNIEnv *, jclass, jlong pool, jlong pointer, jint size) {
  TracyCAllocN(reinterpret_cast<void *>(pointer), static_cast<size_t>(size),
               reinterpret_cast<const char *>(pool));
  return 0;
}

extern "C" JNIEXPORT jlong JNICALL Java_com_mojang_jtracy_TracyBindings_freeNamed(
    JNIEnv *, jclass, jlong pool, jlong pointer) {
  TracyCFreeN(reinterpret_cast<void *>(pointer),
              reinterpret_cast<const char *>(pool));
  return 0;
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_setThreadName(
    JNIEnv *env, jclass, jstring name, jint group) {
  auto chars = env->GetStringUTFChars(name, nullptr);
  tracy::SetThreadNameWithHint(chars, static_cast<int32_t>(group));
  env->ReleaseStringUTFChars(name, chars);
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_plotValue(
    JNIEnv *, jclass, jlong handle, jdouble value) {
  TracyCPlot(reinterpret_cast<const char *>(handle), value);
}

extern "C" JNIEXPORT jlong JNICALL Java_com_mojang_jtracy_TracyBindings_leakName(
    JNIEnv *env, jclass, jstring str) {
  return reinterpret_cast<jlong>(env->GetStringUTFChars(str, nullptr));
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_appInfo(
    JNIEnv *env, jclass, jstring text) {
  const char *chars = env->GetStringUTFChars(text, nullptr);
  jsize length = static_cast<size_t>(env->GetStringUTFLength(text));
  TracyCAppInfo(chars, length);
  env->ReleaseStringUTFChars(text, chars);
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_message(
    JNIEnv *env, jclass, jstring text) {
  const char *chars = env->GetStringUTFChars(text, nullptr);
  jsize length = static_cast<size_t>(env->GetStringUTFLength(text));
  TracyCMessage(chars, length);
  env->ReleaseStringUTFChars(text, chars);
}

extern "C" JNIEXPORT void JNICALL Java_com_mojang_jtracy_TracyBindings_messageColored(
    JNIEnv *env, jclass, jstring text, jint color) {
  const char *chars = env->GetStringUTFChars(text, nullptr);
  jsize length = static_cast<size_t>(env->GetStringUTFLength(text));
  TracyCMessageC(chars, length, static_cast<uint32_t>(color));
  env->ReleaseStringUTFChars(text, chars);
}

extern "C" JNIEXPORT jboolean JNICALL Java_me_modmuss50_tracyutils_TracyBindingsExtension_isConnected(
    JNIEnv *, jclass) {
  return static_cast<jboolean>(TracyCIsConnected != 0);
}
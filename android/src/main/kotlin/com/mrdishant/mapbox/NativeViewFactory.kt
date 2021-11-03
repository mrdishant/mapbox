package com.example.platform_view

import android.content.Context
import com.mrdishant.mapbox.NativeView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView

class NativeViewFactory(private val messenger: BinaryMessenger)  //    @NonNull private final BinaryMessenger messenger;
//    @NonNull private final View containerView;
//
//    NativeViewFactory(@NonNull BinaryMessenger messenger, @NonNull View containerView) {
//        super(StandardMessageCodec.INSTANCE);
//        this.messenger = messenger;
//        this.containerView = containerView;
//    }
    : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any? ): PlatformView {
        val creationParams = args as Map<String, Any>?
        return NativeView(context,messenger, id, creationParams)
    }
}
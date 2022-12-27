package com.mikeasoft.baby_elephant

import android.view.MotionEvent
import androidx.annotation.NonNull
import com.samsung.wearable_rotary.WearableRotaryPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.wearable.CapabilityClient
import com.google.android.gms.wearable.CapabilityInfo
import com.google.android.gms.wearable.Node
import com.google.android.gms.wearable.Wearable
import android.content.Intent
import android.util.Log
import android.net.Uri
import androidx.wear.phone.interactions.PhoneTypeHelper
import androidx.wear.remote.interactions.RemoteActivityHelper
import androidx.wear.widget.ConfirmationOverlay
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.guava.await
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.runBlocking


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.mikeasoft.baby_elephant/native"
    private val dataClient by lazy { Wearable.getDataClient(this) }
    private val messageClient by lazy { Wearable.getMessageClient(this) }
    private val capabilityClient by lazy { Wearable.getCapabilityClient(this) }
    private val remoteActivityHelper by lazy {RemoteActivityHelper(this) }
    private var androidPhoneNodeWithApp: Node? = null

    override fun onGenericMotionEvent(event: MotionEvent?): Boolean {
        return when {
            WearableRotaryPlugin.onGenericMotionEvent(event) -> true
            else -> super.onGenericMotionEvent(event)
        }
    }

    @ExperimentalStdlibApi
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler{
            call, result ->
            when {
                call.method.equals("triggerAuth") -> {
                    triggerAuth(call, result);
                }
            }
        }
    }

    private fun triggerAuth(call: MethodCall, result: MethodChannel.Result) {

        runBlocking() {
            checkIfPhoneHasApp(this)
        }

        if (androidPhoneNodeWithApp == null) {
            openAppInStoreOnPhone();
        }

        result.success("WHAT");
    }

    private fun checkIfPhoneHasApp(scope: CoroutineScope) = scope.launch {
        Log.d(TAG, "checkIfPhoneHasApp()")

        try {
            val capabilityInfo = capabilityClient
                .getCapability(CAPABILITY_PHONE_APP, CapabilityClient.FILTER_ALL)
                .await()

            Log.d(TAG, "Capability request succeeded.")
            androidPhoneNodeWithApp = capabilityInfo.nodes.firstOrNull()
        } catch (cancellationException: CancellationException) {
            // Request was cancelled normally
        } catch (throwable: Throwable) {
            Log.d(TAG, "Capability request failed to return any results.")
        }
    }

    private fun openAppInStoreOnPhone() {
        Log.d(TAG, "openAppInStoreOnPhone()")

        val intent = when (PhoneTypeHelper.getPhoneDeviceType(applicationContext)) {
            PhoneTypeHelper.DEVICE_TYPE_ANDROID -> {
                Log.d(TAG, "\tDEVICE_TYPE_ANDROID")
                // Create Remote Intent to open Play Store listing of app on remote device.
                Intent(Intent.ACTION_VIEW)
                    .addCategory(Intent.CATEGORY_BROWSABLE)
                    .setData(Uri.parse(ANDROID_MARKET_APP_URI))
            } else -> {
                Log.d(TAG, "\tDEVICE_TYPE_ERROR_UNSUPPORTED")
                return
            }
        }
        
        try {
            remoteActivityHelper.startRemoteActivity(intent)
            ConfirmationOverlay().showOn(this@MainActivity)
        } catch (cancellationException: CancellationException) {
            // Request was cancelled normally
            throw cancellationException
        } catch (throwable: Throwable) {
            ConfirmationOverlay()
                .setType(ConfirmationOverlay.FAILURE_ANIMATION)
                .showOn(this@MainActivity)
        }
    }

    companion object {
        private const val TAG = "BabyElephantMainActivity"
        private const val CAPABILITY_PHONE_APP = "baby_elephant_auth"
        private const val ANDROID_MARKET_APP_URI = "market://details?id=com.mikeasoft.baby_elephant"
    }
}

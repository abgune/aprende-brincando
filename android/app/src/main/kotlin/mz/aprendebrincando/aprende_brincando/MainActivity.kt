package mz.aprendebrincando.aprende_brincando

import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var speech: TextToSpeech? = null
    private var channel: MethodChannel? = null
    private var ready = false
    private val pending = mutableListOf<MethodChannel.Result>()
    private var currentId: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mz.aprendebrincando/speech")
        channel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "prepare" -> prepare(result)
                "speak" -> {
                    val text = call.argument<String>("text")
                    val id = call.argument<String>("id")
                    if (!ready || text.isNullOrBlank() || id == null) {
                        result.error("unavailable", "Offline Portuguese voice unavailable", null)
                    } else {
                        currentId = id
                        val status = speech!!.speak(text, TextToSpeech.QUEUE_FLUSH, null, id)
                        if (status == TextToSpeech.SUCCESS) result.success(null)
                        else { currentId = null; result.error("speech", "Speech failed", null) }
                    }
                }
                "stop" -> { speech?.stop(); currentId = null; result.success(null) }
                else -> result.notImplemented()
            }
        }
    }

    private fun prepare(result: MethodChannel.Result) {
        if (speech != null && pending.isEmpty()) {
            ready = runCatching { chooseVoice() }.getOrDefault(false)
            result.success(ready)
            return
        }
        pending.add(result)
        if (speech != null) return
        speech = TextToSpeech(applicationContext) { status ->
            runOnUiThread {
                ready = status == TextToSpeech.SUCCESS && runCatching { chooseVoice() }.getOrDefault(false)
                speech?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onStart(utteranceId: String?) {}
                    override fun onDone(utteranceId: String?) = finished(utteranceId, false)
                    @Deprecated("Android compatibility callback")
                    override fun onError(utteranceId: String?) = finished(utteranceId, true)
                    override fun onError(utteranceId: String?, errorCode: Int) = finished(utteranceId, true)
                })
                val results = pending.toList()
                pending.clear()
                results.forEach { it.success(ready) }
            }
        }
    }

    private fun chooseVoice(): Boolean {
        val engine = speech ?: return false
        val voices = engine.voices?.filter {
            it.locale.language == "pt" && !it.isNetworkConnectionRequired &&
                it.features?.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED) != true
        }?.sortedWith(compareBy({ if (it.locale.country == "MZ") 0 else if (it.locale.country == "PT") 1 else 2 }, { it.name })) ?: return false
        val voice = voices.firstOrNull() ?: return false
        if (engine.setVoice(voice) != TextToSpeech.SUCCESS) return false
        engine.setSpeechRate(0.85f)
        engine.setPitch(1.0f)
        return true
    }

    private fun finished(id: String?, failed: Boolean) {
        runOnUiThread {
            if (id != null && id == currentId) {
                currentId = null
                channel?.invokeMethod("finished", mapOf("id" to id, "failed" to failed))
            }
        }
    }

    override fun onPause() {
        speech?.stop()
        val id = currentId
        if (id != null) finished(id, false)
        super.onPause()
    }

    override fun onDestroy() {
        pending.forEach { it.success(false) }
        pending.clear()
        channel?.setMethodCallHandler(null)
        speech?.stop()
        speech?.shutdown()
        speech = null
        super.onDestroy()
    }
}

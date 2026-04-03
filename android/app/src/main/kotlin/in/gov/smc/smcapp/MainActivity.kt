package `in`.gov.smc.smcapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    
    private val TAG = "SMC_MainActivity"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "MainActivity onCreate() called")
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "Flutter engine configured")
    }
    
    override fun onDestroy() {
        Log.d(TAG, "MainActivity onDestroy() called")
        super.onDestroy()
    }
}
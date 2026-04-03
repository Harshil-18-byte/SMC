package `in`.gov.smc.smcapp

import androidx.multidex.MultiDexApplication
import android.util.Log

class MyApplication : MultiDexApplication() {
    
    override fun onCreate() {
        super.onCreate()
        Log.d("SMC_APP", "Application onCreate() called")
        
        // Add any global initialization here
        // DO NOT initialize Firebase here - let Flutter handle it
    }
    
    override fun onTerminate() {
        super.onTerminate()
        Log.d("SMC_APP", "Application onTerminate() called")
    }
}

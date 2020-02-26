package com.example.mpass

import android.app.UiModeManager
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.DisplayMetrics
import com.redfast.promotion.PromotionManager

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        PromotionManager.initPromotion("74f72649-0327-4911-bd21-a4cd533cec1c", "123")
        val uiModeManager = getSystemService(UI_MODE_SERVICE) as UiModeManager
        if (uiModeManager.currentModeType != Configuration.UI_MODE_TYPE_TELEVISION && !isTablet())
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        setContentView(R.layout.activity_main)
    }

    fun isTablet(): Boolean {
        val dm = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(dm)
        val width = resources.displayMetrics.widthPixels
        val height = resources.displayMetrics.heightPixels
        val wi = width.toDouble() / dm.xdpi.toDouble()
        val hi = height.toDouble() / dm.ydpi.toDouble()
        val x = Math.pow(wi, 2.0)
        val y = Math.pow(hi, 2.0)
        val screenInches = Math.sqrt(x + y)
        return screenInches > 7
    }
}

package com.redfast.mpass

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.redfast.promotion.PromotionManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        PromotionManager.initPromotion(this, "8825eb66-9f8a-414c-aa37-ed18d08fe954", "123") {
            GlobalScope.launch(Dispatchers.Main) {
                val fragmentManager = supportFragmentManager
                val fragmentTransaction = fragmentManager.beginTransaction()
                val fragment = MainFragment()
                fragmentTransaction.add(R.id.container, fragment, "Home")
                fragmentTransaction.commit()
            }
        }
    }
}

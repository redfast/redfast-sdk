package com.redfast.mpass

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.redfast.mpass.databinding.FragmentMovieBinding
import com.redfast.promotion.PromotionManager

class MovieFragment : Fragment() {
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val binding =
            FragmentMovieBinding.inflate(inflater, container, false)
        binding.fragment = this
        PromotionManager.setScreenName(binding.root, "Movie Detail") {}
        return binding.root
    }
}

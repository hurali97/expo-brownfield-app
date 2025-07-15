package com.example.mylibrary

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.activity.OnBackPressedCallback
import androidx.fragment.app.Fragment
import com.facebook.react.ReactFragment

class RNFragment: Fragment() {
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return this.context?.let { RNViewFactory.createFrameLayout(it, requireActivity(), ) }
    }
}